# 🔄 Workflow Architecture

## 🎯 System Overview

This project implements a sophisticated three-layer architecture for Ansible automation with intelligent SSH authentication detection and user-friendly interaction patterns.

## 🏗️ Three-Layer Architecture

### Layer 1: Connectivity Testing (Ansible)
**Purpose**: Silent network and SSH authentication detection  
**Implementation**: `playbooks/0_test-connectivity.yml`  
**Characteristics**:
- Runs completely silently (no user prompts)
- Tests network reachability via multiple methods (direct IP, Tailnet fallback)
- Detects SSH key vs password authentication capabilities
- Generates machine-readable results in `/tmp/ansible_connectivity_results/`

### Layer 2: Analysis & Decision (Shell Script)
**Purpose**: Parse results and determine optimal authentication strategy  
**Implementation**: `scripts/task-playbook.sh`  
**Characteristics**:
- Parses connectivity test results from Layer 1
- Categorizes hosts by authentication method (SSH key vs password)
- Makes intelligent decisions about user prompts
- Prepares optimal Ansible execution strategy

### Layer 3: User Interaction (Shell Script)
**Purpose**: Present clear choices and handle user input gracefully  
**Implementation**: `scripts/task-playbook.sh` (user interaction portions)  
**Characteristics**:
- Clean, color-coded output with emoji indicators
- Interactive prompts only when necessary (password authentication needed)
- Perfect TTY handling using `script -q /dev/null`
- Graceful error handling and informative feedback

## 🔀 Workflow Execution Flow

```
User runs: task playbook -- <playbook-name>
     ↓
┌─────────────────────────────────────────────┐
│ Layer 1: Connectivity Testing              │
│ File: playbooks/0_test-connectivity.yml    │
│ • Silent connectivity check                 │
│ • SSH authentication detection             │
│ • Results stored in /tmp/                  │
└─────────────────────────────────────────────┘
     ↓
┌─────────────────────────────────────────────┐
│ Layer 2: Analysis & Decision               │
│ File: scripts/task-playbook.sh             │
│ • Parse connectivity results               │
│ • Categorize hosts by auth method          │
│ • Determine if user input needed           │
└─────────────────────────────────────────────┘
     ↓
┌─────────────────────────────────────────────┐
│ Layer 3: User Interaction                  │
│ File: scripts/task-playbook.sh             │
│ • Show clear status summary                │
│ • Prompt for passwords if needed           │
│ • Execute target playbook                  │
└─────────────────────────────────────────────┘
     ↓
┌─────────────────────────────────────────────┐
│ Target Playbook Execution                  │
│ File: playbooks/<selected-playbook>.yml    │
│ • Run automation tasks                     │
│ • Apply configurations                     │
│ • Report results                           │
└─────────────────────────────────────────────┘
```

## 🎨 User Experience Patterns

### All SSH Keys Working ✅
```
Testing connectivity to hosts...
✓ Connectivity test completed
✓ Reachable hosts: ubuntu-1.local ubuntu-2.local ubuntu-4.local  
✓ SSH key authentication: ubuntu-1.local ubuntu-2.local ubuntu-4.local

Running playbook: 1_deploy-ssh-key
[Playbook runs automatically without prompts]
```

### Mixed Authentication ⚠️
```
Testing connectivity to hosts...
✓ Connectivity test completed
✓ Reachable hosts: ubuntu-1.local ubuntu-2.local ubuntu-4.local
✓ SSH key authentication: ubuntu-1.local
⚠ Need password authentication: ubuntu-2.local ubuntu-4.local

Some hosts require password authentication.
Do you want to proceed with password authentication? (y/N): 
```

## 🔧 Technical Implementation Details

### TTY Handling
All interactive commands use `script -q /dev/null` to ensure proper TTY allocation:
```bash
script -q /dev/null ansible-playbook [options] playbook.yml
```

### Result Caching
Connectivity test results are cached in `/tmp/ansible_connectivity_results/` with format:
- `<hostname>.env` - Environment variables with connection status
- `REACHABLE_HOSTS` - Space-separated list of reachable hosts
- `SSH_KEY_HOSTS` - Hosts that accept SSH key authentication
- `PASSWORD_HOSTS` - Hosts requiring password authentication

### Error Handling
- Network failures are handled gracefully with Tailnet fallback
- SSH authentication failures fall back to password prompts
- All errors include helpful context and suggested solutions

## 🎯 Design Principles

### Separation of Concerns
- **Playbooks**: Pure automation logic, no user interaction
- **Scripts**: User interface and workflow orchestration
- **Task Runner**: Unified command interface

### User Experience First
- No hanging prompts or invisible interactions
- Clear status indicators with emoji and color coding
- Intelligent defaults that minimize user decisions
- Informative error messages with actionable guidance

### Robust Operation
- Multiple fallback mechanisms for connectivity
- Graceful degradation when SSH keys aren't available
- Comprehensive error handling and logging
- Cached results to avoid redundant operations

## 📚 Related Documentation

- [README.md](../README.md) - User-facing documentation and quick start
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design and component overview
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions
- [API.md](API.md) - Complete task runner command reference