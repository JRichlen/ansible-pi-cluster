# Ansible Playbook Workflow

This project now features a robust, interactive workflow for running Ansible playbooks with intelligent SSH authentication detection and clean terminal output.

## Architecture Overview

The new workflow separates concerns into three layers:

1. **Connectivity Testing** (in playbook): Tests network reachability and SSH key authentication
2. **Authentication Method Detection** (in script): Analyzes test results and determines the authentication method
3. **User Interaction** (in script): Prompts for passwords only when needed, with proper TTY handling

## Workflow Flow

### 1. Connectivity Test Phase (Silent)
```
playbooks/0_test-connectivity.yml
├── Test basic network connectivity (port 22)
├── Test SSH key authentication (BatchMode=yes, no password fallback)
└── Store results in /tmp/ansible_connectivity_results/
```

### 2. Analysis Phase (Script)
```
scripts/run-playbook.sh
├── Parse connectivity results
├── Categorize hosts: reachable, unreachable, ssh-key-auth, password-auth
└── Display clean summary to user
```

### 3. Authentication Decision (Script)
```
If all reachable hosts support SSH keys:
  → Run playbook without password prompt
  
If some hosts need password authentication:
  → Prompt user: "Do you want to proceed with password authentication? (y/N)"
  → If yes: Run playbook with --ask-pass
  → If no: Exit gracefully
```

### 4. Playbook Execution (With TTY)
```
script -q /dev/null ansible-playbook ...
├── Ensures proper TTY allocation
├── Makes prompts visible and interactive
└── Preserves all terminal functionality
```

## Task Runner Integration

### Available Tasks
```bash
# Run any playbook with the smart workflow
task playbook -- <playbook-name>

# Examples:
task playbook -- 0_test-connectivity    # Test connectivity only
task playbook -- 1_deploy-ssh-key       # Deploy SSH keys
task playbook -- 2_update-packages      # Update system packages

# Other tasks remain unchanged:
task install     # Install project dependencies
task test        # Test connectivity
task all         # Run all playbooks in sequence
task list        # List available tasks
task clean       # Clean up temporary files
```

### What You'll See

#### All SSH Keys Working
```
Testing connectivity to hosts...
✓ Connectivity test completed
✓ Reachable hosts: ubuntu-1.local ubuntu-2.local ubuntu-4.local
✓ SSH key authentication: ubuntu-1.local ubuntu-2.local ubuntu-4.local

Running playbook: 1_deploy-ssh-key
[Playbook runs automatically without prompts]
```

#### Mixed Authentication Methods
```
Testing connectivity to hosts...
✓ Connectivity test completed
✓ Reachable hosts: ubuntu-1.local ubuntu-2.local ubuntu-4.local
✓ SSH key authentication: ubuntu-1.local
⚠ Need password authentication: ubuntu-2.local ubuntu-4.local

Some hosts require password authentication.
Do you want to proceed with password authentication? (y/N): y
[Playbook runs with --ask-pass, prompts for passwords as needed]
```

#### Some Hosts Unreachable
```
Testing connectivity to hosts...
✓ Connectivity test completed
✓ Reachable hosts: ubuntu-1.local ubuntu-2.local
✓ SSH key authentication: ubuntu-1.local ubuntu-2.local
✗ Unreachable hosts: ubuntu-3.local

[Playbook runs on reachable hosts only]
```

## Benefits

### 🎯 **Smart Authentication**
- Automatically detects which hosts need passwords vs SSH keys
- Only prompts for passwords when actually needed
- Graceful handling of unreachable hosts

### 🔇 **Clean Output**
- Connectivity tests run silently (no terminal pollution)
- Clear, color-coded summaries
- Only shows relevant information to the user

### 💻 **Perfect TTY Handling**
- All password prompts are visible and interactive
- No more hanging playbooks or invisible prompts
- Uses `script` command to ensure proper TTY allocation

### 🔒 **Separation of Concerns**
- Connectivity logic stays in Ansible (where it belongs)
- User interaction logic stays in shell scripts (where it works best)
- Clean, maintainable architecture

### ⚡ **Efficient Workflow**
- Connectivity test results are cached between runs
- Skip unnecessary steps when SSH keys are already working
- Fast, responsive user experience

## Files Changed

### New Files
- `playbooks/0_test-connectivity.yml` - Silent connectivity and SSH method testing
- `scripts/simulate-mixed-connectivity.sh` - Testing utility for different scenarios

### Updated Files
- `scripts/run-playbook.sh` - Complete rewrite with intelligent authentication detection
- `playbooks/1_deploy-ssh-key.yml` - Simplified, focused on key deployment only
- `scripts/task-playbook.sh` - Updated to work with simplified script interface
- `Taskfile.yml` - Already configured with `interactive: true` for proper TTY handling

### Architecture Principles

1. **Playbooks handle logic** - Network tests, SSH authentication tests, system configuration
2. **Scripts handle interaction** - User prompts, authentication method selection, TTY management
3. **Clean separation** - No business logic in shell scripts, no user interaction in playbooks
4. **Robust error handling** - Graceful degradation when hosts are unreachable
5. **User-friendly** - Clear feedback, minimal noise, intelligent defaults

This new architecture provides a professional, user-friendly experience while maintaining all the power and flexibility of Ansible automation.
