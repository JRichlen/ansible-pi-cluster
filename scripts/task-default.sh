#!/bin/bash

PLAYBOOKS_DIR="playbooks"

echo "🚀 Ansible Pi Cluster Management (Task)"
echo ""
echo "Static commands:"
echo "  task install       - Install dependencies"
echo "  task test          - Run tests"
echo "  task all           - Run all playbooks in order"
echo "  task clean         - Cleanup temporary files"
echo "  task list          - List available playbooks"
echo ""
echo "Dynamic playbooks (run any by number or name):"
echo "  task playbook -- <number|name> [ansible-options]"
echo ""

echo "Numbered playbooks (main workflow - runs in sequence with 'task all'):"
for playbook in "$PLAYBOOKS_DIR"/[0-9]_*.yml; do
  if [ -f "$playbook" ]; then
    basename_playbook=$(basename "$playbook" .yml)
    number=$(echo "$basename_playbook" | cut -d'_' -f1)
    name=$(echo "$basename_playbook" | cut -d'_' -f2-)
    echo "  task playbook -- $number         # $name"
    echo "  task playbook -- $name     # $name (by name)"
  fi
done

echo ""
echo "Utility playbooks (special purpose - call by name only):"
for playbook in "$PLAYBOOKS_DIR"/*.yml; do
  if [ -f "$playbook" ]; then
    basename_playbook=$(basename "$playbook" .yml)
    if ! echo "$basename_playbook" | grep -q '^[0-9]_'; then
      echo "  task playbook -- $basename_playbook # $basename_playbook"
    fi
  fi
done

echo ""
echo "✅ Interactive playbooks work perfectly with task!"
