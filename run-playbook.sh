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

# Function to run a playbook
run_playbook() {
    local playbook=$1
    local playbook_name=$(basename "$playbook" .yml)
    
    echo -e "${GREEN}Running playbook: ${playbook}${NC}"
    case "$playbook_name" in
        deploy-ssh-key)
            echo -e "${YELLOW}Deploying SSH key: prompting for SSH password and using sudo.${NC}"
                ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOKS_DIR/$playbook" \
                --ask-pass \
                --become \
                --ask-become-pass \
                -v
            ;;
        test-connection)
            echo -e "${YELLOW}Testing SSH connectivity without credentials.${NC}"
            ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOKS_DIR/$playbook" \
                -v
            ;;
        *)
            echo -e "${YELLOW}Running playbook using SSH key and passwordless sudo.${NC}"
            ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOKS_DIR/$playbook" \
                --become \
                -v
            ;;
    esac
}

# Interactive mode if no arguments provided
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Available playbooks:${NC}"
    
    # Get list of playbooks without .yml extension
    playbooks=($(ls -1 "$PLAYBOOKS_DIR"/*.yml 2>/dev/null | sed 's|.*/||' | sed 's|\.yml||' | sort))
    
    if [ ${#playbooks[@]} -eq 0 ]; then
        echo -e "${RED}No playbooks found in $PLAYBOOKS_DIR/${NC}"
        exit 1
    fi
    
    # Display numbered list
    for i in "${!playbooks[@]}"; do
        echo "  $((i+1)). ${playbooks[i]}"
    done
    echo
    
    # Prompt for selection
    while true; do
        echo -e "${BLUE}Select a playbook to run (1-${#playbooks[@]}) or 'q' to quit:${NC}"
        read -p "> " choice
        
        # Check for quit
        if [ "$choice" = "q" ] || [ "$choice" = "Q" ]; then
            echo "Exiting..."
            exit 0
        fi
        
        # Validate numeric input
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#playbooks[@]} ]; then
            selected_playbook="${playbooks[$((choice-1))]}"
            echo
            echo -e "${GREEN}Selected: $selected_playbook${NC}"
            break
        else
            echo -e "${RED}Invalid selection. Please enter a number between 1 and ${#playbooks[@]} or 'q' to quit.${NC}"
        fi
    done
    
    PLAYBOOK="$selected_playbook.yml"
else
    PLAYBOOK="$1.yml"
fi

# Check if playbook exists
if [ ! -f "$PLAYBOOKS_DIR/$PLAYBOOK" ]; then
    echo -e "${RED}Error: Playbook '$PLAYBOOK' not found in $PLAYBOOKS_DIR/${NC}"
    echo -e "${YELLOW}Available playbooks:${NC}"
    ls -1 "$PLAYBOOKS_DIR"/*.yml | sed 's|.*/||' | sed 's|\.yml||'
    exit 1
fi

# Special handling for SSH key deployment
playbook_name=$(basename "$PLAYBOOK" .yml)
if [ "$playbook_name" = "deploy-ssh-key" ]; then
    echo -e "${YELLOW}Note: SSH key deployment requires password authentication initially.${NC}"
    echo -e "${YELLOW}After successful deployment, other playbooks can use key authentication.${NC}"
    echo
fi

run_playbook "$PLAYBOOK"
