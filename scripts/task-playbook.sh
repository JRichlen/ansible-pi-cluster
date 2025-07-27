#!/bin/bash

# Ansible Pi Cluster - Task Playbook Runner
# Consolidates user-friendly task interface with intelligent playbook execution
# Provides smart playbook resolution and SSH authentication detection

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script and project paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PLAYBOOKS_DIR="$PROJECT_DIR/playbooks"
INVENTORY_PATH="$PROJECT_DIR/inventories/hosts.yml"
RESULTS_DIR="/tmp/ansible_connectivity_results"

# Function to display help and available playbooks
show_help() {
  echo -e "${RED}❌ Please specify a playbook name${NC}"
  echo ""
  echo "Usage: task playbook -- <playbook-identifier> [ansible-options]"
  echo ""
  echo "You can specify the playbook by:"
  echo "  • Number (e.g., '1' for playbook starting with '1_')"
  echo "  • Name (e.g., 'deploy-ssh-key' for playbook ending with '_deploy-ssh-key')"
  echo "  • Full filename without .yml (e.g., '1_deploy-ssh-key')"
  echo ""
  echo "Examples:"
  echo "  task playbook -- 1                    # Run playbook 1"
  echo "  task playbook -- deploy-ssh-key       # Run by name"
  echo "  task playbook -- 1_deploy-ssh-key     # Run by full name"
  echo "  task playbook -- 1 --check            # Dry run"
  echo "  task playbook -- 1 --limit pi-node-01 # Target specific host"
  echo ""
  echo "Available numbered playbooks (main workflow):"
  for playbook in "$PLAYBOOKS_DIR"/[0-9]_*.yml; do
    if [ -f "$playbook" ]; then
      basename_playbook=$(basename "$playbook" .yml)
      number=$(echo "$basename_playbook" | cut -d'_' -f1)
      name=$(echo "$basename_playbook" | cut -d'_' -f2-)
      echo "  $number - $name ($basename_playbook.yml)"
    fi
  done
  
  echo ""
  echo "Available utility playbooks (call by name):"
  for playbook in "$PLAYBOOKS_DIR"/*.yml; do
    if [ -f "$playbook" ]; then
      basename_playbook=$(basename "$playbook" .yml)
      if ! echo "$basename_playbook" | grep -q '^[0-9]_'; then
        echo "  $basename_playbook ($basename_playbook.yml)"
      fi
    fi
  done
}

# Function to resolve playbook name from various input formats
resolve_playbook_name() {
  local input="$1"
  
  # If input is just a number, find the playbook starting with that number
  if [[ "$input" =~ ^[0-9]+$ ]]; then
    for playbook in "$PLAYBOOKS_DIR"/${input}_*.yml; do
      if [ -f "$playbook" ]; then
        basename "$playbook" .yml
        return 0
      fi
    done
  fi
  
  # If input doesn't contain underscore, try to find by name part
  if [[ "$input" != *_* ]]; then
    for playbook in "$PLAYBOOKS_DIR"/*_${input}.yml; do
      if [ -f "$playbook" ]; then
        basename "$playbook" .yml
        return 0
      fi
    done
  fi
  
  # Try exact match (full filename without .yml)
  if [ -f "$PLAYBOOKS_DIR/${input}.yml" ]; then
    echo "$input"
    return 0
  fi
  
  # No match found
  return 1
}

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
    local local_hosts=()
    local tailnet_hosts=()
    
    # Handle case where no connectivity results exist
    if [ ! -d "$RESULTS_DIR" ]; then
        echo -e "${YELLOW}No connectivity results found. Will attempt with SSH keys first.${NC}"
        return 0
    fi
    
    # Parse enhanced connectivity results for each host
    for result_file in "$RESULTS_DIR"/*.env; do
        if [ -f "$result_file" ]; then
            # Reset variables and source the result file
            unset NETWORK_REACHABLE SSH_KEYS_WORK HOST ANSIBLE_USER TEST_TIMESTAMP SUCCESSFUL_ADDRESS USED_FALLBACK
            # shellcheck source=/dev/null
            . "$result_file"
            
            # Categorize hosts based on connectivity results
            if [ "$NETWORK_REACHABLE" = "true" ]; then
                reachable_hosts+=("$HOST")
                
                # Categorize by address type used
                if [ "$USED_FALLBACK" = "true" ]; then
                    tailnet_hosts+=("$HOST")
                else
                    local_hosts+=("$HOST")
                fi
                
                # Categorize by authentication method
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
    
    # Display enhanced summary of connectivity analysis
    if [ ${#local_hosts[@]} -gt 0 ]; then
        echo -e "${GREEN}✓ Reachable hosts (local): ${local_hosts[*]}${NC}"
    fi
    
    if [ ${#tailnet_hosts[@]} -gt 0 ]; then
        echo -e "${YELLOW}✓ Reachable hosts (tailnet): ${tailnet_hosts[*]}${NC}"
        echo -e "${YELLOW}⚠ Fallback network used for: ${tailnet_hosts[*]}${NC}"
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

# Function to generate dynamic host addresses based on connectivity results
generate_dynamic_host_vars() {
    local temp_inventory="/tmp/ansible_dynamic_inventory.yml"
    
    # Handle case where no connectivity results exist
    if [ ! -d "$RESULTS_DIR" ]; then
        echo ""
        return
    fi
    
    # Check if we need to create a dynamic inventory
    local has_overrides=false
    for result_file in "$RESULTS_DIR"/*.env; do
        if [ -f "$result_file" ]; then
            # shellcheck source=/dev/null
            . "$result_file"
            if [ "$NETWORK_REACHABLE" = "true" ] && [ -n "$SUCCESSFUL_ADDRESS" ]; then
                has_overrides=true
                break
            fi
        fi
    done
    
    # If no overrides needed, return empty
    if [ "$has_overrides" = false ]; then
        echo ""
        return
    fi
    
    # Create dynamic inventory based on original but with updated ansible_host values
    echo "---" > "$temp_inventory"
    echo "ubuntu:" >> "$temp_inventory"
    echo "  hosts:" >> "$temp_inventory"
    
    # Parse connectivity results and create new inventory
    for result_file in "$RESULTS_DIR"/*.env; do
        if [ -f "$result_file" ]; then
            # Reset variables and source the result file
            unset NETWORK_REACHABLE SUCCESSFUL_ADDRESS HOST
            # shellcheck source=/dev/null
            . "$result_file"
            
            if [ "$NETWORK_REACHABLE" = "true" ] && [ -n "$SUCCESSFUL_ADDRESS" ]; then
                # Convert ubuntu-X.local to ubuntu-X for inventory
                local inventory_host
                inventory_host="${HOST%.local}"
                echo "    ${inventory_host}:" >> "$temp_inventory"
                echo "      ansible_host: ${SUCCESSFUL_ADDRESS}" >> "$temp_inventory"
                echo "      tailnet_fallback: ${SUCCESSFUL_ADDRESS}" >> "$temp_inventory"
            fi
        fi
    done
    
    # Add group vars from original inventory
    echo "" >> "$temp_inventory"
    echo "  vars:" >> "$temp_inventory"
    echo "    ansible_user: \"{{ lookup('env','USER') }}\"" >> "$temp_inventory"
    echo "    ansible_ssh_common_args: >-" >> "$temp_inventory"
    echo "      -o ControlMaster=auto -o ControlPersist=60s" >> "$temp_inventory"
    echo "      -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" >> "$temp_inventory"
    
    echo "$temp_inventory"
}

# Function to run the actual playbook with proper TTY handling
run_playbook() {
    local playbook_name="$1"
    local use_password="$2"
    shift 2  # Remove the first two arguments
    local ansible_args=()
    
    # Add password authentication flag if needed
    if [ "$use_password" = "true" ]; then
        ansible_args+=("--ask-pass")
    fi
    
    # Generate dynamic host addresses based on connectivity results
    local dynamic_inventory
    dynamic_inventory=$(generate_dynamic_host_vars)
    
    # Determine which inventory to use
    local inventory_path="$INVENTORY_PATH"
    if [ -n "$dynamic_inventory" ]; then
        inventory_path="$dynamic_inventory"
    fi
    
    # Add any additional arguments passed to the script
    ansible_args+=("$@")
    
    local playbook_path="$PROJECT_DIR/playbooks/$playbook_name.yml"
    
    echo
    echo -e "${BLUE}Running playbook: $playbook_name${NC}"
    echo "Playbook path: $playbook_path"
    echo "Inventory path: $inventory_path"
    if [ -n "$dynamic_inventory" ]; then
        echo -e "${YELLOW}Using dynamic inventory with tailnet addresses${NC}"
    fi
    
    # Use script command to ensure proper TTY allocation for interactive prompts
    # This is critical for password prompts and other interactive elements
    script -q /dev/null \
        ansible-playbook \
        -i "$inventory_path" \
        "$playbook_path" \
        "${ansible_args[@]}"
}

# Main execution flow
main() {
    # Check if playbook identifier is provided
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi
    
    # Parse the first argument as playbook identifier
    playbook_input="$1"
    shift
    
    # Resolve the actual playbook name
    if ! resolved_name=$(resolve_playbook_name "$playbook_input"); then
        echo -e "${RED}❌ Could not find playbook matching: $playbook_input${NC}"
        echo ""
        echo "Available numbered playbooks (main workflow):"
        for playbook in "$PLAYBOOKS_DIR"/[0-9]_*.yml; do
            if [ -f "$playbook" ]; then
                basename_playbook=$(basename "$playbook" .yml)
                number=$(echo "$basename_playbook" | cut -d'_' -f1)
                name=$(echo "$basename_playbook" | cut -d'_' -f2-)
                echo "  $number - $name ($basename_playbook.yml)"
            fi
        done
        
        echo ""
        echo "Available utility playbooks (call by name):"
        for playbook in "$PLAYBOOKS_DIR"/*.yml; do
            if [ -f "$playbook" ]; then
                basename_playbook=$(basename "$playbook" .yml)
                if ! echo "$basename_playbook" | grep -q '^[0-9]_'; then
                    echo "  $basename_playbook ($basename_playbook.yml)"
                fi
            fi
        done
        exit 1
    fi
    
    echo -e "${GREEN}🚀 Running playbook: $resolved_name${NC}"
    
    # Skip connectivity test for the connectivity test playbook itself
    if [ "$resolved_name" = "0_test-connectivity" ]; then
        run_playbook "$resolved_name" false "$@"
        return
    fi
    
    # Run connectivity test
    run_connectivity_test
    
    # Analyze results and determine if password is needed
    if analyze_connectivity; then
        # SSH keys work for all reachable hosts
        run_playbook "$resolved_name" false "$@"
    else
        # Some hosts need password authentication
        if prompt_for_password; then
            run_playbook "$resolved_name" true "$@"
        fi
    fi
}

# Run main function
main "$@"
