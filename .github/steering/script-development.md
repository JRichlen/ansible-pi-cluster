---
title: "Shell Script Development Standards & Patterns"
triggers: ["script", "shell", "bash", "task-script", "run-playbook", "TTY", "automation"]
applies_to: ["scripts/*", "*.sh"]
context: ["shell", "script", "automation", "task-runner"]
priority: high
---

# Shell Script Development Instructions

## 🔧 Core Script Architecture

### Script Types & Responsibilities
- **Core Runner**: `run-playbook.sh` - intelligent workflow engine
- **Task Scripts**: `task-*.sh` - implement Taskfile.yml commands
- **Integration Pattern**: Task scripts wrap core functionality

### Script Naming Standards
- **Task Scripts**: `task-<command>.sh` (must match Taskfile.yml tasks)
- **Core Scripts**: Descriptive names (`run-playbook.sh`)
- **Permissions**: All scripts must be executable (`chmod +x`)

## 🎯 Development Standards

### Script Header Template
```bash
#!/usr/bin/env bash
set -euo pipefail

# Script: task-example.sh
# Purpose: Brief description of what this script does
# Usage: Called via task runner or directly
# Dependencies: List any required tools or files
```

### Error Handling Patterns
```bash
# Strict error handling
set -euo pipefail

# Function for error messages
error_exit() {
    echo "✗ $1" >&2
    exit 1
}

# Check dependencies
command -v ansible >/dev/null || error_exit "Ansible not found. Run 'task install' first."

# Validate required files
[[ -f "$required_file" ]] || error_exit "Required file not found: $required_file"
```

### Output Standards
```bash
# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status message functions
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
info() { echo -e "${BLUE}ℹ${NC} $1"; }
```

## 🧠 Intelligent Runner Patterns

### TTY Handling for Interactive Prompts
```bash
# Ensure proper TTY allocation for password prompts
run_with_tty() {
    local command=("$@")
    if [[ -t 0 && -t 1 ]]; then
        # We have a TTY, run normally
        "${command[@]}"
    else
        # No TTY, use script command to allocate one
        script -q /dev/null "${command[@]}"
    fi
}

# Usage for ansible-playbook with prompts
run_with_tty ansible-playbook -i inventories/hosts.yml --ask-pass playbook.yml
```

### Result Processing & Caching
```bash
# Connectivity result processing
RESULTS_DIR="/tmp/ansible_connectivity_$(date +%s)"
REACHABLE_FILE="${RESULTS_DIR}/reachable_hosts"
SSH_KEY_FILE="${RESULTS_DIR}/ssh_key_hosts"

# Parse Ansible output for host status
parse_connectivity_results() {
    local output_file="$1"
    
    # Extract successful hosts
    grep "SUCCESS" "$output_file" | awk '{print $1}' > "$REACHABLE_FILE"
    
    # Extract SSH key authentication successful hosts
    grep "ssh_key_auth.*true" "$output_file" | awk '{print $1}' > "$SSH_KEY_FILE"
}

# Clean up temporary files
cleanup() {
    [[ -d "$RESULTS_DIR" ]] && rm -rf "$RESULTS_DIR"
}
trap cleanup EXIT
```

### User Interaction Patterns
```bash
# Prompt for user confirmation
prompt_user() {
    local message="$1"
    local default="${2:-n}"
    
    echo -n "$message"
    read -r response
    response=${response:-$default}
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Example usage
if prompt_user "Do you want to proceed with password authentication? (y/N): " "n"; then
    info "Proceeding with password authentication..."
else
    info "Exiting gracefully."
    exit 0
fi
```

## 📋 Task Script Implementation

### Task Script Template
```bash
#!/usr/bin/env bash
set -euo pipefail

# Script: task-example.sh
# Purpose: Implement 'task example' command
# Integration: Called from Taskfile.yml

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source common functions if needed
# source "$SCRIPT_DIR/common-functions.sh"

main() {
    # Validate arguments if any
    if [[ $# -gt 0 ]]; then
        info "Processing arguments: $*"
    fi
    
    # Implement task functionality
    info "Executing task: example"
    
    # Call core functionality
    # "$SCRIPT_DIR/run-playbook.sh" "example-playbook"
    
    success "Task completed successfully"
}

# Run main function with all arguments
main "$@"
```

### Argument Processing
```bash
# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --)
                shift
                PLAYBOOK_ARGS=("$@")
                break
                ;;
            *)
                PLAYBOOK_NAME="$1"
                shift
                ;;
        esac
    done
}
```

## 🔄 Integration Patterns

### Taskfile.yml Integration
```yaml
# Task definition pattern
example:
  desc: "Brief description of what this task does"
  dir: "{{.USER_WORKING_DIR}}"
  cmd: "./scripts/task-example.sh {{.CLI_ARGS}}"
```

### Common Function Library
```bash
# common-functions.sh - shared utilities
check_dependencies() {
    local deps=("$@")
    for dep in "${deps[@]}"; do
        command -v "$dep" >/dev/null || error_exit "$dep not found"
    done
}

find_playbooks() {
    find playbooks -name "*.yml" | sort
}

validate_playbook() {
    local playbook="$1"
    [[ -f "playbooks/$playbook.yml" ]] || error_exit "Playbook not found: $playbook"
}
```

### Error Propagation
```bash
# Ensure errors propagate through the call chain
run_ansible_playbook() {
    local playbook="$1"
    shift
    local args=("$@")
    
    if ! ansible-playbook -i inventories/hosts.yml "playbooks/${playbook}.yml" "${args[@]}"; then
        error_exit "Playbook execution failed: $playbook"
    fi
}
```

## 🎯 Quality Standards

### Script Testing Guidelines
- [ ] Test with various argument combinations
- [ ] Verify error handling paths
- [ ] Confirm TTY handling for interactive elements
- [ ] Test integration with task runner
- [ ] Validate output formatting and colors

### Code Quality Checklist
- [ ] Use `set -euo pipefail` for strict error handling
- [ ] Include proper shebang (`#!/usr/bin/env bash`)
- [ ] Add descriptive comments and headers
- [ ] Follow consistent naming conventions
- [ ] Use functions for repeated logic
- [ ] Include cleanup traps for temporary files

### Performance Considerations
- **Efficient Execution**: Avoid unnecessary subprocess spawning
- **Resource Cleanup**: Always clean up temporary files and processes
- **Caching**: Leverage caching for expensive operations
- **Parallel Processing**: Use background processes when appropriate

## 🔍 Debugging & Maintenance

### Debug Mode Pattern
```bash
# Enable debug mode via environment variable
if [[ "${DEBUG:-}" == "true" ]]; then
    set -x
    exec 2> >(tee -a "/tmp/script-debug-$(basename "$0").log" >&2)
fi

# Usage: DEBUG=true task example
```

### Logging Standards
```bash
# Logging function
log() {
    local level="$1"
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" >&2
}

# Usage
log "INFO" "Starting playbook execution"
log "ERROR" "Failed to connect to host: $hostname"
```

### Maintenance Tasks
- **Regular Review**: Review scripts for outdated patterns
- **Dependency Updates**: Update tool version checks
- **Error Message Quality**: Improve error messages based on user feedback
- **Performance Optimization**: Profile and optimize slow operations
