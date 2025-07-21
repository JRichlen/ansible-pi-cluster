#!/bin/bash

PLAYBOOKS_DIR="playbooks"

echo "🏗️ Running complete Pi cluster setup workflow..."
echo "⚠️ This will run ALL numbered playbooks including interactive ones"
echo "Press Ctrl+C within 5 seconds to cancel..."
sleep 5

for playbook in "$PLAYBOOKS_DIR"/[0-9]_*.yml; do
  if [ -f "$playbook" ]; then
    number=$(basename "$playbook" | cut -d'_' -f1)
    echo ""
    echo "📋 Running playbook $number..."
    ./scripts/task-playbook.sh "$number"
  fi
done

echo "✅ Complete Pi cluster setup finished!"
