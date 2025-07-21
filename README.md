# Ansible Pi Cluster

Infrastructure automation for Raspberry Pi clusters using Ansible with multiple task runner options.

## Project Structure

```
ansible-pi-cluster/
├── scripts/                  # Utility scripts
│   ├── run-playbook.sh      #   Ansible playbook execution wrapper
│   └── README.md            #   Scripts documentation
├── inventories/             # Ansible inventory files
│   └── hosts.yml           #   Host definitions
├── playbooks/              # Ansible playbooks (numbered by execution order)
│   ├── 1_deploy-ssh-key.yml #   SSH key deployment & system setup
│   └── 2_update-packages.yml#   System updates & package installation
├── roles/                  # Ansible roles
├── Taskfile.yml            # Go-task configuration (main interface)
└── README.md               # This file
```

## Quick Start

### 1. Install Dependencies

```bash
# Using go-task (recommended)
task install

# Manual installation
brew install ansible yamllint ansible-lint sshpass go-task/tap/go-task
ansible-galaxy collection install community.general --force
ansible-galaxy collection install ansible.posix --force
```

### 2. Set Up Your Inventory

Edit `inventories/hosts.yml` to define your Pi cluster nodes:

```yaml
all:
  children:
    pi_cluster:
      hosts:
        pi-node-01:
          ansible_host: 192.168.1.100
        pi-node-02:
          ansible_host: 192.168.1.101
        pi-node-03:
          ansible_host: 192.168.1.102
```

### 3. Cluster Setup Workflow

```bash
```bash
# Complete setup workflow (runs all numbered playbooks in order)
task all                    # Run all playbooks

# Individual playbooks
task playbook -- 1                    # Deploy SSH keys & configure system access
task playbook -- deploy-ssh-key       # Same as above, by name
task playbook -- 2                    # Update packages & install dependencies
task playbook -- update-packages      # Same as above, by name

# With Ansible options
task playbook -- 1 --check            # Dry run
task playbook -- 1 --limit pi-node-01 # Target specific host
task playbook -- 1 --verbose          # Verbose output
```

## Task Runner

This project uses **Go-task** as the modern, clean task runner with excellent interactive support:

```bash
task                          # Show help and list all available playbooks
task playbook -- 1           # Run playbook 1 (SSH key deployment)
task playbook -- deploy-ssh-key # Same playbook by name
task playbook -- 1 --check   # Dry run
task playbook -- 1 --limit pi-node-01 # Target specific host
task list                    # List all discovered playbooks
task all                     # Run all playbooks in order
task test                    # Run syntax tests
task clean                   # Cleanup temporary files
```

**Features:**
- ✅ **Perfect interactive support** - handles password prompts flawlessly
- ✅ **Dynamic playbook discovery** - automatically finds all playbooks
- ✅ **Unified command interface** - single `playbook` command for everything
- ✅ **Ansible argument passthrough** - supports all ansible-playbook options
- ✅ **Modern and maintainable** - clean YAML configuration
```

## Task Runners

This project provides **two task runners** optimized for interactive Ansible playbooks:

### 1. 🚀 **Go-task (`task`)** - Recommended

**Modern, clean task runner with excellent interactive support:**

```bash
task                          # Show help and list all available playbooks
task playbook -- 1           # Run playbook 1 (SSH key deployment)
task playbook -- deploy-ssh-key # Same playbook by name
task playbook -- 1 --check   # Dry run
task playbook -- 1 --limit pi-node-01 # Target specific host
task list                    # List all discovered playbooks
task all                     # Run all playbooks in order
task test                    # Run syntax tests
task clean                   # Cleanup temporary files
```

### 2. 🔧 **Bash Script (`./tasks.sh`)** - Alternative

**Features:**
**Bash script with traditional playbook discovery and execution:**

```bash
./tasks.sh                  # Show help and list all available playbooks
./tasks.sh 1               # Run playbook 1 (SSH key deployment)
./tasks.sh deploy-ssh-key  # Same playbook by name
./tasks.sh list           # List all discovered playbooks
./tasks.sh all            # Run all playbooks in order
./tasks.sh test           # Run syntax tests
./tasks.sh clean          # Cleanup temporary files
```

**Features:**
- ✅ **Perfect interactive support** - no TTY issues
- ✅ **Dynamic playbook discovery** - automatically finds all playbooks
- ✅ **Number and name support** - run by number (1, 2) or name
- ✅ **Zero configuration** - works out of the box

**Both task runners provide the same functionality - choose based on your preference!**

## Playbooks

### `1_deploy-ssh-key.yml` - SSH Key Setup & System Configuration
**Comprehensive SSH key deployment with intelligent connection handling:**

- ✅ **Smart Connection Testing**: Tests basic connectivity and SSH key auth
- ✅ **Fail-Safe Deployment**: Only prompts for password when needed
- ✅ **SSH Key Management**: Finds and deploys SSH keys automatically  
- ✅ **System Configuration**: Sets up passwordless sudo
- ✅ **Final Validation**: Ensures SSH keys work before completing
- ✅ **Detailed Reporting**: Clear status for each host
- ✅ **Interactive Prompts**: Works perfectly with task runners (no hanging!)

**Usage:**
```bash
task playbook -- 1        # Interactive prompts work flawlessly
```

### `2_update-packages.yml` - System Updates & Package Installation  
**System maintenance and dependency installation:**

- Updates all system packages
- Installs common development tools
- Configures system services

**Usage:**
```bash
./tasks.sh 2              # Update and install packages
# or
task 2                    # Alternative
```

## Network Discovery

**Features:**
- **Dynamic Network Discovery**: Automatically detects your local network subnet
- **Multiple Scanning Methods**: 
  - nmap (detailed, requires sudo) - shows MAC addresses and vendors
  - ping sweep (basic, no sudo) - shows IP addresses and hostnames
- **Modular Design**: Separate utilities for different network operations
- **macOS Optimized**: Uses macOS-specific networking commands
- **User-Friendly Interface**: Clear output and helpful error messages

## Requirements

- macOS (current networking stack)  
- Bash shell
- Ansible
- Optional: `nmap` for detailed scans
- Optional: `sshpass` for password authentication
- Optional: `go-task` for the task alternative
- Optional: `sudo` privileges for MAC address detection

## Installation

```bash
# Install all dependencies using the task script
./tasks.sh install

# Or using go-task
task install

# Or manually
brew install ansible nmap yamllint ansible-lint sshpass go-task/tap/go-task
ansible-galaxy collection install community.general --force
ansible-galaxy collection install ansible.posix --force
```

## Configuration

1. **Update Inventory**: Edit `inventories/hosts.yml` with your Pi cluster IPs
2. **Customize Variables**: Modify playbook variables as needed
3. **SSH Keys**: Ensure you have SSH keys generated (`ssh-keygen`)

## Example Workflow

```bash
# 1. Discover your network
./tasks.sh scan

# 2. Update inventory with discovered IPs
# 3. Run complete setup
./tasks.sh all

# 4. Verify everything works
./tasks.sh test
```

## Testing & Validation

```bash
# Consolidated test command (escalating importance)
./tasks.sh test             # Run all essential tests in order:
                           #   1. YAML syntax validation
                           #   2. Ansible syntax validation  
                           #   3. Ansible lint (best practices)

# Using go-task
task test                  # Same tests
```

## Cleanup

```bash
./tasks.sh clean          # Remove temporary files and caches
# or
task clean                # Same cleanup
```

## Why Not Make?

Traditional `make` has issues with interactive prompts (like SSH password entry) that can cause hanging. Our task runners are specifically designed to handle interactive Ansible playbooks perfectly:

- ✅ **Interactive prompts work flawlessly**
- ✅ **No TTY/stdin redirection issues**
- ✅ **Better error handling**
- ✅ **Modern, readable syntax**

## Troubleshooting

- **SSH Key Issues**: The `deploy-ssh-key.yml` playbook provides detailed troubleshooting
- **Interactive Prompts**: Use `./tasks.sh` for best interactive support
- **Network Discovery**: See `scripts/README.md` for detailed network discovery help
- **Ansible Issues**: Check syntax with `./tasks.sh test`

## Next Steps

1. **Customize Playbooks**: Modify playbooks for your specific requirements
2. **Add Roles**: Create reusable roles in `roles/` directory  
3. **Extend Automation**: Add more playbooks - they'll be discovered automatically!

## Documentation

- [Network Discovery Scripts](scripts/README.md) - Detailed network discovery documentation
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html) - Official Ansible documentation
