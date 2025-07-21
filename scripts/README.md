# Scripts Directory

This directory contains all shell scripts that implement the intelligent Ansible workflow for the Pi Cluster project.

## 🔧 Core Scripts

### `task-playbook.sh` - Intelligent Task Playbook Runner
The consolidated heart of the project's intelligent workflow system that combines user-friendly task interface with smart execution.

**Key Features:**
- **Smart Playbook Resolution**: Handles numbers (1), names (deploy-ssh-key), or full names (1_deploy-ssh-key)
- **Smart Authentication Detection**: Tests SSH keys vs password needs automatically
- **Silent Connectivity Testing**: Runs connectivity tests without terminal pollution
- **Clean User Interface**: Color-coded summaries and minimal prompts
- **Perfect TTY Handling**: Ensures all password prompts are visible and interactive
- **Graceful Error Handling**: Handles unreachable hosts and failed connections elegantly

**Workflow:**
1. Resolves playbook name from various input formats
2. Runs `0_test-connectivity.yml` silently (except for connectivity playbook itself)
3. Analyzes results and categorizes hosts
4. Prompts for passwords only if needed
5. Executes target playbook with proper authentication

## 📋 Task Implementation Scripts

These scripts implement each task defined in `Taskfile.yml`:

| Script | Purpose | Interactive |
|--------|---------|-------------|
| `task-default.sh` | Show help and available commands | No |
| `task-install.sh` | Install project dependencies | No |
| `task-test.sh` | Run connectivity tests | No |
| `task-list.sh` | List all available tasks and playbooks | No |
| `task-clean.sh` | Clean up temporary files | No |
| `task-playbook.sh` | Consolidated intelligent playbook runner | Yes |
| `task-all.sh` | Run all playbooks in sequence | Yes |

## 🏗️ Architecture Principles

### Separation of Concerns
- **Task Scripts**: Handle argument parsing and validation
- **Core Runner**: `task-playbook.sh` implements intelligent workflow logic with user-friendly interface
- **Playbooks**: Handle all Ansible automation logic

### User Experience
- All scripts provide clean, color-coded output
- Consistent error handling and messaging
- Self-documenting help systems
- Minimal user interaction required

### Reliability
- Proper error handling with `set -e`
- TTY allocation for interactive prompts
- Graceful degradation for unreachable hosts
- Comprehensive logging for debugging

## 🔍 Script Details

### TTY Handling
All interactive scripts use `script -q /dev/null` to ensure proper TTY allocation. This is critical for:
- Password prompts visibility
- Interactive Ansible prompts
- Proper signal handling

### Color Coding
Scripts use consistent color schemes:
- 🔴 **Red**: Errors and failures
- 🟡 **Yellow**: Warnings and information
- 🟢 **Green**: Success and confirmations
- 🔵 **Blue**: Process information and headers

### Error Handling
All scripts follow consistent patterns:
- Exit on any error (`set -e`)
- Clear error messages with suggested solutions
- Graceful cleanup of temporary files
- Proper exit codes for automation

## 🛠️ Development Guidelines

### Adding New Scripts
1. Follow naming convention: `task-<name>.sh`
2. Include proper shebang and error handling
3. Use consistent color coding and messaging
4. Document purpose and usage in this README

### Modifying Existing Scripts
1. Test with various connectivity scenarios
2. Ensure TTY handling remains functional
3. Maintain backward compatibility
4. Update documentation as needed

### Testing Scripts
```bash
# Test connectivity
./scripts/task-playbook.sh 0

# Test individual playbooks
./scripts/task-playbook.sh 1
./scripts/task-playbook.sh deploy-ssh-key

# Test full workflow
task playbook -- 1 --check
task all
```

## 📝 Maintenance Notes

- Scripts directory should contain only executable shell scripts
- Each script should be self-contained and well-documented
- Regular testing with different host connectivity scenarios is recommended
- Keep scripts focused on single responsibilities
- **task-clean.sh**: Cleans up temporary files

## TTY Handling

All Ansible playbook executions use the `script` command wrapper:
```bash
script -q /dev/null ansible-playbook [options]
```

This ensures:
- ✅ **Proper TTY allocation** for interactive prompts
- ✅ **Password prompt support** in the SSH key deployment playbook
- ✅ **No hanging processes** when prompts are needed
- ✅ **Clean output** with `-q /dev/null` to suppress script command output

### Usage

```bash
# Show help and available playbooks
task playbook

# Direct execution by number
task playbook -- 1

# Direct execution by name  
task playbook -- deploy-ssh-key

# Direct execution by full name
task playbook -- 1_deploy-ssh-key

# With additional Ansible options
task playbook -- 1 --check                    # Dry run
task playbook -- 1 --limit pi-node-01         # Target specific host
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
