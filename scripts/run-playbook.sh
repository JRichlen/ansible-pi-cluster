#!/bin/bash

# Ansible Pi Cluster Management Script
# This script helps run playbooks with SSH key preference and password fallback

INVENTORY_FILE="inventories/hosts.yml"
PLAYBOOKS_DIR="playbooks"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Ansible Pi Cluster Management ===${NC}"
echo

# Function to find playbook by number or name
find_playbook() {
    local input=$1
    local playbook_file=""
    
    # Check if input is a number (e.g., "1", "2")
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        # Find playbook by number prefix
        playbook_file=$(find "$PLAYBOOKS_DIR" -name "${input}_*.yml" | head -1)
    else
        # Find playbook by name (with or without number prefix)
        # First try exact match with number prefix
        playbook_file=$(find "$PLAYBOOKS_DIR" -name "*_${input}.yml" | head -1)
        
        # If not found, try exact filename match
        if [[ -z "$playbook_file" ]]; then
            playbook_file=$(find "$PLAYBOOKS_DIR" -name "${input}.yml" | head -1)
        fi
    fi
    
    echo "$playbook_file"
}

# Function to run a playbook
run_playbook() {
    local playbook_input=$1
    local playbook_file=$(find_playbook "$playbook_input")
    
    if [[ -z "$playbook_file" ]]; then
        echo -e "${RED}Error: Playbook not found for input: $playbook_input${NC}"
        echo -e "${YELLOW}Available playbooks:${NC}"
        ls -1 "$PLAYBOOKS_DIR"/*.yml 2>/dev/null | sed 's|.*playbooks/||' | sed 's|\.yml||'
        exit 1
    fi
    
    local playbook_name=$(basename "$playbook_file" .yml)
    local playbook_basename=$(basename "$playbook_file")
    
    echo -e "${GREEN}Running playbook: ${playbook_basename}${NC}"
    
    # Determine playbook type by checking the actual filename
    case "$playbook_name" in
        *deploy-ssh-key*)
            echo -e "${YELLOW}SSH Key Deployment: Will prompt for password only if needed.${NC}"
            # Ensure interactive mode and disable host key checking for initial setup
            export ANSIBLE_HOST_KEY_CHECKING=False
            export ANSIBLE_STDOUT_CALLBACK=default
            exec < /dev/tty
            ansible-playbook -i "$INVENTORY_FILE" "$playbook_file" \
                --become \
                -v
            ;;
        *test-connection*)
            echo -e "${YELLOW}Testing SSH connectivity without credentials.${NC}"
            ansible-playbook -i "$INVENTORY_FILE" "$playbook_file" \
                -v
            ;;
        *)
            echo -e "${YELLOW}Running playbook using SSH key and passwordless sudo.${NC}"
            ansible-playbook -i "$INVENTORY_FILE" "$playbook_file" \
                --become \
                -v
            ;;
    esac
}

# Main execution
if [ $# -eq 0 ]; then
    # Interactive mode - show available playbooks
    echo -e "${YELLOW}Available playbooks:${NC}"
    
    # Get numbered playbooks and display them nicely
    playbooks=($(ls -1 "$PLAYBOOKS_DIR"/*.yml 2>/dev/null | sort))
    
    if [ ${#playbooks[@]} -eq 0 ]; then
        echo -e "${RED}No playbooks found in $PLAYBOOKS_DIR/${NC}"
        exit 1
    fi
    
    # Display playbooks with both number and name options
    for playbook in "${playbooks[@]}"; do
        basename_playbook=$(basename "$playbook" .yml)
        if [[ "$basename_playbook" =~ ^([0-9]+)_(.+)$ ]]; then
            number="${BASH_REMATCH[1]}"
            name="${BASH_REMATCH[2]}"
            echo "  $number. $name (run with: make $number or make $name)"
        else
            echo "  - $basename_playbook (run with: make $basename_playbook)"
        fi
    done
    echo
    
    # Prompt for selection
    while true; do
        echo -e "${BLUE}Enter playbook number, name, or 'q' to quit:${NC}"
        read -p "> " choice
        
        # Check for quit
        if [ "$choice" = "q" ] || [ "$choice" = "Q" ]; then
            echo "Exiting..."
            exit 0
        fi
        
        # Try to find the playbook
        if [ -n "$choice" ]; then
            selected_playbook=$(find_playbook "$choice")
            if [ -n "$selected_playbook" ]; then
                echo
                echo -e "${GREEN}Selected: $(basename "$selected_playbook")${NC}"
                run_playbook "$choice"
                exit 0
            else
                echo -e "${RED}Invalid selection: $choice${NC}"
            fi
        fi
    done
else
    # Direct execution with argument
    run_playbook "$1"
fi
