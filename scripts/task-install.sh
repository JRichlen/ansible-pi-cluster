#!/bin/bash

echo "🍺 Installing dependencies..."
brew install ansible yamllint ansible-lint sshpass go-task/tap/go-task

echo "📦 Installing Ansible collections and roles..."
# Install from requirements file
if [ -f "requirements.yml" ]; then
    echo "Installing from requirements.yml..."
    ansible-galaxy collection install -r requirements.yml --force
else
    echo "❌ Error: requirements.yml not found!"
    echo "Please ensure requirements.yml exists in the project root."
    exit 1
fi

echo "✅ Installation completed!"
