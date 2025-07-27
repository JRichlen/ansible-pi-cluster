#!/bin/bash

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Available Tasks${NC}"
echo ""

# Get script directory to find playbooks
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}Core Tasks:${NC}"
echo "  task install     - Install project dependencies"
echo "  task test        - Test connectivity to all hosts"  
echo "  task all         - Run all playbooks in sequence"
echo "  task clean       - Clean up temporary files"
echo "  task list        - Show this help"
echo ""

echo -e "${GREEN}Playbook Tasks:${NC}"
echo "  task playbook -- <name>  - Run specific playbook with intelligent workflow"
echo ""

echo -e "${YELLOW}Available numbered playbooks (main workflow):${NC}"
for playbook in "$SCRIPT_DIR/../playbooks"/[0-9]_*.yml; do
  if [ -f "$playbook" ]; then
    basename_playbook=$(basename "$playbook" .yml)
    number=$(echo "$basename_playbook" | cut -d'_' -f1)
    name=$(echo "$basename_playbook" | cut -d'_' -f2-)
    echo "  $number. $name (task playbook -- $number or task playbook -- $name)"
  fi
done

echo ""
echo -e "${YELLOW}Available utility playbooks (call by name):${NC}"
for playbook in "$SCRIPT_DIR/../playbooks"/*.yml; do
  if [ -f "$playbook" ]; then
    basename_playbook=$(basename "$playbook" .yml)
    if ! echo "$basename_playbook" | grep -q '^[0-9]_'; then
      echo "  - $basename_playbook (task playbook -- $basename_playbook)"
    fi
  fi
done
echo ""

echo -e "${YELLOW}Examples:${NC}"
echo "  task playbook -- 1_deploy-ssh-key    # Deploy SSH keys with smart auth"
echo "  task playbook -- 2_update-packages   # Update system packages"
echo "  task all                             # Run all playbooks in sequence"
