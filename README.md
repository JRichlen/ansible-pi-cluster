# Ansible Pi Cluster Management

A modern, interactive Ansible automation system for managing Raspberry Pi clusters with intelligent SSH authentication and robust error handling.

## ✨ Features

- **🎯 Smart Authentication**: Automatically detects SSH key vs password authentication needs
- **🔇 Clean Output**: Silent connectivity testing with clear, color-coded summaries  
- **💻 Perfect TTY Handling**: All prompts are visible and interactive, no hanging commands
- **⚡ Efficient Workflow**: Cached connectivity results, skip unnecessary steps
- **🔒 Robust Architecture**: Clean separation of playbook logic and user interaction

## 🚀 Quick Start

### Prerequisites
- [go-task](https://taskfile.dev/) installed
- Ansible installed
- SSH access to target hosts

### Run Any Playbook
```bash
# The intelligent workflow handles everything automatically:
task playbook -- <playbook-name>

# Examples:
task playbook -- 0_test-connectivity    # Test connectivity only
task playbook -- 1_deploy-ssh-key       # Deploy SSH keys with smart auth detection
task playbook -- 2_update-packages      # Update system packages
```

### What You'll Experience

#### All SSH Keys Working ✅
```
Testing connectivity to hosts...
✓ Connectivity test completed
✓ Reachable hosts: ubuntu-1.local ubuntu-2.local ubuntu-4.local  
✓ SSH key authentication: ubuntu-1.local ubuntu-2.local ubuntu-4.local

Running playbook: 1_deploy-ssh-key
[Playbook runs automatically without prompts]
```

#### Some Hosts Need Passwords ⚠️
```
Testing connectivity to hosts...
✓ Connectivity test completed
✓ Reachable hosts: ubuntu-1.local ubuntu-2.local ubuntu-4.local
✓ SSH key authentication: ubuntu-1.local
⚠ Need password authentication: ubuntu-2.local ubuntu-4.local

Some hosts require password authentication.
Do you want to proceed with password authentication? (y/N): 
```

## 📋 Available Tasks

```bash
task list                    # Show all available tasks
task install                 # Install project dependencies  
task test                    # Test connectivity to all hosts
task playbook -- <name>     # Run specific playbook with smart workflow
task all                     # Run all playbooks in sequence
task clean                   # Clean up temporary files
```

## 🏗️ Architecture

The system uses a three-layer approach:

1. **Connectivity Testing** (Ansible playbook) - Tests network and SSH authentication silently
2. **Analysis & Decision** (Shell script) - Parses results and determines authentication method  
3. **User Interaction** (Shell script) - Prompts for passwords only when needed

See [WORKFLOW.md](WORKFLOW.md) for detailed architecture documentation.

## 📁 Project Structure

```
├── Taskfile.yml              # Task runner configuration
├── inventories/
│   └── hosts.yml             # Ansible inventory
├── playbooks/
│   ├── 0_test-connectivity.yml    # Silent connectivity testing
│   ├── 1_deploy-ssh-key.yml      # SSH key deployment
│   └── 2_update-packages.yml     # System updates
├── scripts/
│   ├── task-playbook.sh      # Consolidated intelligent playbook runner
│   ├── task-*.sh            # Individual task implementations
│   └── simulate-*.sh        # Testing utilities
└── WORKFLOW.md              # Detailed architecture documentation
```

## 🔧 Configuration

### Inventory Setup
Edit `inventories/hosts.yml`:
```yaml
all:
  children:
    ubuntu:
      hosts:
        ubuntu-1.local:
        ubuntu-2.local:
        ubuntu-3.local:
        ubuntu-4.local:
      vars:
        ansible_user: jrichlen
        ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
```

### SSH Key Setup
The system automatically detects and uses SSH keys from:
- `~/.ssh/id_rsa.pub` (default)
- `~/.ssh/id_ed25519.pub` (fallback)
- `~/.ssh/id_ecdsa.pub` (fallback)

Generate a new key if needed:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

## 🛠️ Troubleshooting

### Connectivity Issues
```bash
# Test connectivity only
task playbook -- 0_test-connectivity

# Check results manually
ls -la /tmp/ansible_connectivity_results/
cat /tmp/ansible_connectivity_results/*.env
```

### Prompt Visibility Issues
The system uses `script -q /dev/null` to ensure proper TTY allocation. All prompts should be visible and interactive.

### SSH Key Authentication
If SSH keys aren't working, the system will automatically prompt for passwords when needed. No manual configuration required.

## 📝 Contributing

1. Follow the architecture principles in [WORKFLOW.md](WORKFLOW.md)
2. Keep playbook logic separate from user interaction
3. Ensure all prompts work with TTY allocation
4. Test with various connectivity scenarios

## 📄 License

MIT License - see LICENSE file for details.
