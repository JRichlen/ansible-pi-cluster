#!/bin/bash

# Ansible Pi Cluster - Intelligent Playbook Runner
# This script provides smart SSH authentication detection and clean user interaction
# for running Ansible playbooks with minimal output and maximum usability.

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if playbook name is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Please provide a playbook name.${NC}"
    echo "Usage: $0 <playbook-name> [ansible-args...]"
    exit 1
fi

# Store the playbook name and shift arguments
PLAYBOOK_NAME="$1"
shift

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PLAYBOOK_PATH="$PROJECT_DIR/playbooks/$PLAYBOOK_NAME.yml"
INVENTORY_PATH="$PROJECT_DIR/inventories/hosts.yml"
RESULTS_DIR="/tmp/ansible_connectivity_results"

# Check if playbook exists
if [ ! -f "$PLAYBOOK_PATH" ]; then
    echo -e "${RED}Error: Playbook '$PLAYBOOK_PATH' not found.${NC}"
    exit 1
fi

# Function to run connectivity test
run_connectivity_test() {
    # Skip if results already exist (useful for testing/development)
    if [ -d "$RESULTS_DIR" ] && [ "$(ls -A $RESULTS_DIR 2>/dev/null)" ]; then
        echo -e "${YELLOW}Using existing connectivity results...${NC}"
        return
    fi
    
    echo -e "${BLUE}Testing connectivity to hosts...${NC}"
    
    # Clean up any previous results
    rm -rf "$RESULTS_DIR"
    
    # Run connectivity test playbook silently to avoid terminal pollution
    if ansible-playbook \
        -i "$INVENTORY_PATH" \
        "$PROJECT_DIR/playbooks/0_test-connectivity.yml" \
        > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Connectivity test completed${NC}"
    else
        echo -e "${YELLOW}⚠ Some hosts may be unreachable (continuing with available hosts)${NC}"
    fi
}

# Function to analyze connectivity results and determine authentication method
analyze_connectivity() {
    local need_password=false
    local reachable_hosts=()
    local unreachable_hosts=()
    local ssh_key_hosts=()
    local password_hosts=()
    
    # Handle case where no connectivity results exist
    if [ ! -d "$RESULTS_DIR" ]; then
        echo -e "${YELLOW}No connectivity results found. Will attempt with SSH keys first.${NC}"
        return 0
    fi
    
    # Parse connectivity results for each host
    for result_file in "$RESULTS_DIR"/*.env; do
        if [ -f "$result_file" ]; then
            # Reset variables and source the result file
            unset NETWORK_REACHABLE SSH_KEYS_WORK HOST ANSIBLE_USER TEST_TIMESTAMP
            # shellcheck source=/dev/null
            . "$result_file"
            
            # Categorize hosts based on connectivity results
            if [ "$NETWORK_REACHABLE" = "true" ]; then
                reachable_hosts+=("$HOST")
                if [ "$SSH_KEYS_WORK" = "true" ]; then
                    ssh_key_hosts+=("$HOST")
                else
                    password_hosts+=("$HOST")
                    need_password=true
                fi
            else
                unreachable_hosts+=("$HOST")
            fi
        fi
    done
    
    # Display clean summary of connectivity analysis
    if [ ${#reachable_hosts[@]} -gt 0 ]; then
        echo -e "${GREEN}✓ Reachable hosts: ${reachable_hosts[*]}${NC}"
    fi
    
    if [ ${#ssh_key_hosts[@]} -gt 0 ]; then
        echo -e "${GREEN}✓ SSH key authentication: ${ssh_key_hosts[*]}${NC}"
    fi
    
    if [ ${#password_hosts[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠ Need password authentication: ${password_hosts[*]}${NC}"
    fi
    
    if [ ${#unreachable_hosts[@]} -gt 0 ]; then
        echo -e "${RED}✗ Unreachable hosts: ${unreachable_hosts[*]}${NC}"
    fi
    
    # Return whether we need password authentication
    [ "$need_password" != "true" ]
}

# Function to prompt for password if needed
prompt_for_password() {
    echo
    echo -e "${YELLOW}Some hosts require password authentication.${NC}"
    echo -e "Do you want to proceed with password authentication? (y/N): "
    read -r response
    
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            echo -e "${RED}Aborted by user.${NC}"
            exit 1
            ;;
    esac
}

# Function to run the actual playbook with proper TTY handling
run_playbook() {
    local use_password="$1"
    shift  # Remove the first argument
    local ansible_args=()
    
    # Add password authentication flag if needed
    if [ "$use_password" = "true" ]; then
        ansible_args+=("--ask-pass")
    fi
    
    # Add any additional arguments passed to the script
    ansible_args+=("$@")
    
    echo
    echo -e "${BLUE}Running playbook: $PLAYBOOK_NAME${NC}"
    echo "Playbook path: $PLAYBOOK_PATH"
    echo "Inventory path: $INVENTORY_PATH"
    
    # Use script command to ensure proper TTY allocation for interactive prompts
    # This is critical for password prompts and other interactive elements
    script -q /dev/null \
        ansible-playbook \
        -i "$INVENTORY_PATH" \
        "$PLAYBOOK_PATH" \
        "${ansible_args[@]}"
}

# Main execution flow
main() {
    # Skip connectivity test for the connectivity test playbook itself
    if [ "$PLAYBOOK_NAME" = "0_test-connectivity" ]; then
        run_playbook false "$@"
        return
    fi
    
    # Run connectivity test
    run_connectivity_test
    
    # Analyze results and determine if password is needed
    if analyze_connectivity; then
        # SSH keys work for all reachable hosts
        run_playbook false "$@"
    else
        # Some hosts need password authentication
        if prompt_for_password; then
            run_playbook true "$@"
        fi
    fi
}

# Run main function
main "$@"
