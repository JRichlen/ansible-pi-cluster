#!/bin/bash

echo "🍺 Installing dependencies..."
brew install ansible yamllint ansible-lint sshpass go-task/tap/go-task
ansible-galaxy collection install community.general --force
ansible-galaxy collection install ansible.posix --force
echo "✅ Installation completed!"
