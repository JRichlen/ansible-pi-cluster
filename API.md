# 📚 API Reference - Task Runner Commands

## 🎯 Overview

Complete reference for all available task commands, parameters, and usage patterns in the ansible-pi-cluster project.

## 🚀 Core Commands

### `task` (default)
**Purpose**: Show help and available commands  
**Usage**: `task` or `task default`  
**Output**: Dynamic list of available tasks and playbooks

**Example**:
```bash
$ task
📋 Available Tasks

Core Tasks:
  task install     - Install project dependencies
  task test        - Test connectivity to all hosts
  task all         - Run all playbooks in sequence
  task clean       - Clean up temporary files
  task list        - Show this help

Playbook Tasks:
  task playbook -- <n>  - Run specific playbook with intelligent workflow
```

### `task install`
**Purpose**: Install all project dependencies  
**Dependencies**: Installs Ansible collections, roles, and requirements  
**Usage**: `task install`  
**Interactive**: No  
**Prerequisites**: Ansible installed

**What gets installed**:
- `kubernetes.core` - Kubernetes management collection
- `community.general` - General purpose modules
- `ansible.posix` - POSIX system modules
- Additional collections from `requirements.yml`

**Example**:
```bash
$ task install
Installing Ansible dependencies...
✓ Collection kubernetes.core installed
✓ Collection community.general installed
✓ All dependencies installed successfully
```

### `task test`
**Purpose**: Test connectivity to all hosts  
**Usage**: `task test`  
**Interactive**: No  
**Output**: Connectivity status for all inventory hosts

**Example**:
```bash
$ task test
Testing connectivity to hosts...
✓ Connectivity test completed
✓ Reachable hosts: ubuntu-1.local ubuntu-2.local ubuntu-4.local  
✓ SSH key authentication: ubuntu-1.local ubuntu-2.local ubuntu-4.local
```

### `task clean`
**Purpose**: Clean up temporary files and cached results  
**Usage**: `task clean`  
**Interactive**: No  
**Cleans**:
- `/tmp/ansible_connectivity_results/`
- Ansible temporary files
- Cached authentication results

### `task list`
**Purpose**: Show all available tasks (alias for default)  
**Usage**: `task list`  
**Interactive**: No

## 🎮 Playbook Execution

### `task playbook`
**Purpose**: Run specific playbook with intelligent workflow  
**Usage**: `task playbook -- <playbook-identifier>`  
**Interactive**: Yes (when password authentication needed)  
**Aliases**: `task play`

#### Playbook Identifiers
Playbooks can be referenced by:
- **Number**: `task playbook -- 1`
- **Name**: `task playbook -- deploy-ssh-key`
- **Full filename**: `task playbook -- 1_deploy-ssh-key`

#### Available Playbooks

| Number | Name | Description | Dependencies |
|--------|------|-------------|--------------|
| 0 | test-connectivity | Silent connectivity and auth testing | None |
| 1 | deploy-ssh-key | SSH key deployment and security setup | None |
| 2 | test-master-connectivity | Master node SSH validation | Playbook 1 |
| 3 | update-packages | System updates and development tools | None |
| 4 | install-tailscale | Tailscale VPN mesh networking | None |
| 5 | prepare-kubernetes | Kubernetes preparation and runtime | Playbook 1 |
| 6 | deploy-kubernetes | Full Kubernetes cluster deployment | Playbooks 1, 5 |
| 7 | verify-kubernetes | Cluster health verification | Playbook 6 |

#### Examples
```bash
# By number
task playbook -- 1
task playbook -- 5

# By name  
task playbook -- deploy-ssh-key
task playbook -- install-tailscale

# By full filename
task playbook -- 1_deploy-ssh-key
task playbook -- 4_install-tailscale
```

### `task all`
**Purpose**: Run all playbooks in sequential order  
**Usage**: `task all`  
**Interactive**: Yes (may prompt for passwords)  
**Execution Order**: 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7

**Example**:
```bash
$ task all
Running all playbooks in sequence...
✓ Running playbook 0: test-connectivity
✓ Running playbook 1: deploy-ssh-key
✓ Running playbook 2: test-master-connectivity
...
```

## 🔧 Advanced Usage Patterns

### Environment Variables

#### Tailscale Configuration
```bash
# Set auth key for automatic Tailscale setup
export TAILSCALE_AUTH_KEY="tskey-auth-xxxxxxxxxxxx"
task playbook -- 4_install-tailscale
```

#### Ansible Configuration
```bash
# Custom inventory file
export ANSIBLE_INVENTORY="custom-inventory.yml"
task playbook -- 1

# Verbose output
export ANSIBLE_VERBOSITY="2"
task playbook -- deploy-ssh-key
```

### Workflow Patterns

#### Initial Cluster Setup
```bash
# Essential foundation
task playbook -- 1_deploy-ssh-key    # Required for all subsequent operations
task playbook -- 3_update-packages   # Recommended for security

# Optional networking
task playbook -- 4_install-tailscale # VPN mesh (requires auth key)
```

#### Kubernetes Deployment
```bash
# Prerequisites
task playbook -- 1_deploy-ssh-key    # Required for inter-node communication
task playbook -- 3_update-packages   # Recommended for latest packages

# Kubernetes deployment
task playbook -- 5_prepare-kubernetes  # Container runtime and K8s packages
task playbook -- 6_deploy-kubernetes   # Full cluster deployment
task playbook -- 7_verify-kubernetes   # Health verification
```

#### Development Workflow
```bash
# Test connectivity before making changes
task test

# Clean cached results
task clean

# Test specific functionality
task playbook -- 0_test-connectivity
```

## 🎨 Interactive Behaviors

### SSH Authentication Prompts
When hosts require password authentication:

```bash
$ task playbook -- 1_deploy-ssh-key
Testing connectivity to hosts...
✓ Connectivity test completed
✓ Reachable hosts: ubuntu-1.local ubuntu-2.local ubuntu-4.local
✓ SSH key authentication: ubuntu-1.local
⚠ Need password authentication: ubuntu-2.local ubuntu-4.local

Some hosts require password authentication.
Do you want to proceed with password authentication? (y/N): y
```

### Tailscale Auth Key Prompts
When `TAILSCALE_AUTH_KEY` environment variable is not set:

```bash
$ task playbook -- 4_install-tailscale
Please enter your Tailscale auth key: [secure input]
```

## 🔍 Output Formats

### Status Indicators
- ✅ **Success**: Green checkmark for completed operations
- ⚠️ **Warning**: Yellow warning for attention-needed items
- ❌ **Error**: Red X for failures
- 📋 **Info**: Blue information icon for details
- 🔄 **Progress**: Spinner or progress indicators

### Color Coding
- **Green**: Successful operations, SSH key authentication
- **Yellow**: Warnings, password authentication required
- **Red**: Errors, unreachable hosts
- **Blue**: Information, neutral status
- **White**: Normal text and prompts

## 🛠️ Troubleshooting Commands

### Connectivity Issues
```bash
# Test connectivity only
task playbook -- 0_test-connectivity

# Check cached results
ls -la /tmp/ansible_connectivity_results/
cat /tmp/ansible_connectivity_results/*.env
```

### Clean State Reset
```bash
# Clean all cached data
task clean

# Reinstall dependencies
task install

# Test from scratch
task test
```

### Verbose Execution
```bash
# Add Ansible verbosity
ANSIBLE_VERBOSITY=2 task playbook -- <playbook>

# Debug mode
ANSIBLE_VERBOSITY=3 task playbook -- <playbook>
```

## 🔒 Security Considerations

### SSH Key Handling
- Keys are never logged or displayed in plaintext
- Automatic detection of available key types (ed25519, rsa, ecdsa)
- Secure permissions applied automatically (600 for private keys, 644 for public)

### Password Security
- Password prompts use secure input (no echo)
- Passwords never stored or cached
- TTY allocation ensures proper security context

### Network Security
- Tailscale integration for secure mesh networking
- SSH connection validation before sensitive operations
- StrictHostKeyChecking disabled only for initial setup

## 📚 Related Documentation

- [README.md](README.md) - Quick start and feature overview
- [WORKFLOW.md](WORKFLOW.md) - Architecture and execution flow
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Problem resolution guide
- [DEPLOYMENT.md](DEPLOYMENT.md) - Production deployment considerations