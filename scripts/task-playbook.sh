#!/bin/bash

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$1" ]; then
  echo "❌ Please specify a playbook name"
  echo ""
  echo "Usage: task playbook -- <playbook-name> [ansible-options]"
  echo ""
  echo "Examples:"
  echo "  task playbook -- 1_deploy-ssh-key"
  echo "  task playbook -- 2_update-packages"
  echo "  task playbook -- 0_test-connectivity"
  echo ""
  echo "Available playbooks:"
  ls -1 "$SCRIPT_DIR/../playbooks"/*.yml 2>/dev/null | sed 's|.*/||' | sed 's|\.yml$||' | sed 's/^/  /'
  exit 1
fi

# Call the run-playbook.sh script with all arguments
exec "$SCRIPT_DIR/run-playbook.sh" "$@"
  echo "  task playbook -- 1                    # Run playbook 1"
  echo "  task playbook -- deploy-ssh-key       # Run by name"
  echo "  task playbook -- 1 --check            # Dry run"
  echo "  task playbook -- 1 --limit pi-node-01 # Target specific host"
  echo ""
  echo "Available playbooks:"
  for playbook in "$PLAYBOOKS_DIR"/*.yml; do
    if [ -f "$playbook" ]; then
      basename_playbook=$(basename "$playbook" .yml)
      if echo "$basename_playbook" | grep -q '^[0-9]_'; then
        number=$(echo "$basename_playbook" | cut -d'_' -f1)
        name=$(echo "$basename_playbook" | cut -d'_' -f2-)
        echo "  task playbook -- $number         # $name"
        echo "  task playbook -- $name # $name (by name)"
      else
        echo "  task playbook -- $basename_playbook # $basename_playbook"
      fi
    fi
  done
  exit 1
fi

# Parse the first argument as playbook identifier
playbook_input="$1"

echo "🚀 Running playbook: $playbook_input"

# Special handling for interactive playbooks
if echo "$playbook_input" | grep -q -E "(1|deploy-ssh-key)"; then
  echo "🔐 This playbook may prompt for passwords interactively..."
fi

# Pass all arguments to run-playbook.sh
./scripts/run-playbook.sh "$@"
