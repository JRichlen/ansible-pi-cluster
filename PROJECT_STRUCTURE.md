# Project Structure

This document provides a comprehensive overview of the project organization and file purposes.

## 📁 Directory Structure

```
ansible-pi-cluster/
├── 📄 README.md                     # Main project documentation
├── 📄 WORKFLOW.md                   # Detailed workflow architecture
├── 📄 Taskfile.yml                  # Task runner configuration
├── 📄 .gitignore                    # Git ignore patterns
├── 📄 PROJECT_STRUCTURE.md          # This file
│
├── 📂 inventories/                  # Ansible inventory files
│   └── 📄 hosts.yml                 # Host definitions and variables
│
├── 📂 playbooks/                    # Ansible playbooks (ordered by number)
│   ├── 📄 0_test-connectivity.yml   # Silent connectivity testing
│   ├── 📄 1_deploy-ssh-key.yml      # SSH key deployment & system setup
│   └── 📄 2_update-packages.yml     # System updates & package management
│
├── 📂 scripts/                      # Shell scripts for task implementation
│   ├── 📄 README.md                 # Scripts documentation
│   ├── 🔧 run-playbook.sh          # Core intelligent playbook runner
│   ├── 🔧 task-all.sh              # Run all playbooks in sequence
│   ├── 🔧 task-clean.sh            # Clean up temporary files
│   ├── 🔧 task-default.sh          # Show help and available tasks
│   ├── 🔧 task-install.sh          # Install dependencies
│   ├── 🔧 task-list.sh             # List all available tasks
│   ├── 🔧 task-playbook.sh         # Playbook task wrapper
│   └── 🔧 task-test.sh             # Connectivity testing
│
├── 📂 roles/                        # Ansible roles (currently empty)
├── 📂 .vscode/                      # VS Code configuration
├── 📂 .github/                      # GitHub workflows and settings
└── 📂 .git/                         # Git repository data
```

## 🎯 File Purposes

### Core Configuration Files

- **`Taskfile.yml`**: Task runner configuration with all available commands
- **`README.md`**: Main project documentation with quick start guide
- **`WORKFLOW.md`**: Detailed technical architecture documentation
- **`.gitignore`**: Standard patterns for excluding temporary files

### Inventory & Configuration

- **`inventories/hosts.yml`**: Defines target hosts and connection parameters
  - Host definitions (IP addresses or hostnames)
  - Connection variables (username, SSH options)
  - Group variables and host-specific overrides

### Playbooks (Execution Order)

- **`0_test-connectivity.yml`**: 
  - Tests network connectivity (port 22)
  - Tests SSH key authentication
  - Stores results for intelligent decision making
  - Runs silently to avoid terminal pollution

- **`1_deploy-ssh-key.yml`**:
  - Deploys SSH public keys for passwordless authentication
  - Configures passwordless sudo
  - Installs essential packages
  - Sets up basic security (firewall)

- **`2_update-packages.yml`**:
  - Updates system packages
  - Installs common development tools
  - Configures security tools (fail2ban)
  - Checks for reboot requirements

### Scripts (Task Implementation)

#### Core Script
- **`run-playbook.sh`**: The heart of the intelligent workflow
  - Runs connectivity tests silently
  - Analyzes results to determine authentication method
  - Prompts for passwords only when needed
  - Ensures proper TTY handling for interactive prompts

#### Task Scripts
- **`task-all.sh`**: Runs all numbered playbooks in sequence
- **`task-clean.sh`**: Removes temporary files and cached results
- **`task-default.sh`**: Shows help and dynamically discovers playbooks
- **`task-install.sh`**: Installs Ansible and required collections
- **`task-list.sh`**: Lists all available tasks with descriptions
- **`task-playbook.sh`**: Wrapper for running individual playbooks
- **`task-test.sh`**: Tests connectivity using the intelligent workflow

## 🏗️ Architecture Principles

### 1. **Separation of Concerns**
- **Playbooks**: Handle Ansible logic, system configuration, testing
- **Scripts**: Handle user interaction, authentication decisions, TTY management
- **Task Runner**: Provides unified interface and command organization

### 2. **Intelligent Automation**
- Automatic SSH authentication method detection
- Silent connectivity testing with clean user feedback
- Graceful handling of unreachable hosts
- Minimal user prompts (only when actually needed)

### 3. **User Experience Focus**
- Clean, color-coded output
- Clear error messages and guidance
- Consistent command interface
- Self-documenting help system

### 4. **Maintainability**
- Modular script organization
- Clear naming conventions
- Comprehensive documentation
- Consistent error handling

## 🔄 Workflow Flow

1. **Task Execution** (`Taskfile.yml`) → 
2. **Script Wrapper** (`task-*.sh`) → 
3. **Intelligent Runner** (`run-playbook.sh`) →
4. **Connectivity Test** (`0_test-connectivity.yml`) →
5. **Analysis & Decision** (shell logic) →
6. **Playbook Execution** (target playbook) →
7. **Clean Results** (user feedback)

## 📝 Adding New Components

### New Playbook
1. Create `N_playbook-name.yml` in `playbooks/`
2. Follow existing naming convention with number prefix
3. Test with `task playbook -- N_playbook-name`

### New Task Script
1. Create `task-name.sh` in `scripts/`
2. Make executable with `chmod +x`
3. Add corresponding task in `Taskfile.yml`
4. Follow existing error handling patterns

### New Role
1. Create directory structure in `roles/`
2. Follow Ansible role conventions
3. Reference from playbooks as needed

## 🧹 Maintenance Tasks

### Regular Cleanup
```bash
task clean                          # Remove temporary files
rm -rf /tmp/ansible_connectivity_*  # Clear connectivity cache
```

### Dependency Updates
```bash
task install                        # Reinstall/update dependencies
ansible-galaxy collection install --upgrade
```

### Documentation Updates
- Update this file when adding new components
- Update `README.md` for user-facing changes  
- Update `WORKFLOW.md` for architecture changes
