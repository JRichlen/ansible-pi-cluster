# Scripts Directory

This directory contains utility scripts for the Ansible Pi Cluster project.

## run-playbook.sh

**Purpose**: A wrapper script for running Ansible playbooks with intelligent playbook discovery and execution handling.

**Location**: `scripts/run-playbook.sh`

### Features

- **Dynamic Playbook Discovery**: Automatically finds playbooks by number (e.g., `1`, `2`) or name (e.g., `deploy-ssh-key`, `update-packages`)
- **Interactive Mode**: When run without arguments, displays available playbooks and prompts for selection
- **Specialized Handling**: Different execution modes for different playbook types:
  - SSH key deployment playbooks: Interactive password prompts, disabled host key checking
  - Test connection playbooks: No credential requirements
  - Standard playbooks: SSH key authentication with sudo

### Usage

```bash
# Interactive mode - shows available playbooks and prompts for selection
./scripts/run-playbook.sh

# Direct execution by number
./scripts/run-playbook.sh 1

# Direct execution by name
./scripts/run-playbook.sh deploy-ssh-key

# With additional Ansible options (when called via task runner)
task playbook -- 1 --check                    # Dry run
task playbook -- 1 --limit pi-node-01         # Target specific host
task playbook -- deploy-ssh-key --verbose     # Verbose output
```

### Playbook Discovery Logic

1. **Number Input**: Looks for files matching pattern `{number}_*.yml` (e.g., `1_deploy-ssh-key.yml`)
2. **Name Input**: 
   - First tries `*_{name}.yml` pattern (e.g., `1_deploy-ssh-key.yml` for input `deploy-ssh-key`)
   - Falls back to exact filename match `{name}.yml`

### Execution Modes

#### SSH Key Deployment (`*deploy-ssh-key*`)
- Uses interactive mode (`exec < /dev/tty`)
- Disables host key checking (`ANSIBLE_HOST_KEY_CHECKING=False`)
- Uses default stdout callback for better password prompt visibility
- Enables sudo with verbose output

#### Test Connection (`*test-connection*`)
- Minimal execution, no sudo or credentials required
- Used for connectivity testing

#### Standard Playbooks (all others)
- Uses SSH key authentication
- Enables sudo (assumes passwordless sudo is configured)
- Verbose output enabled

### Environment Variables

The script sets the following Ansible environment variables when needed:

- `ANSIBLE_HOST_KEY_CHECKING=False` - For initial SSH key deployment
- `ANSIBLE_STDOUT_CALLBACK=default` - For better interactive prompt display

### Dependencies

- Ansible (ansible-playbook command)
- Valid inventory file at `inventories/hosts.yml`
- Playbooks directory at `playbooks/`

### Integration

This script is designed to work with:
- **Task Runner**: Called via `task playbook -- <args>`
- **Direct Execution**: Can be run standalone
- **Interactive Shell**: Supports both scripted and interactive use cases

### Error Handling

- Validates playbook existence before execution
- Lists available playbooks when invalid input is provided
- Provides clear error messages with colored output
- Graceful handling of missing directories or files
