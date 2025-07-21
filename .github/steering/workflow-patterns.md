---
title: "Intelligent Workflow Patterns & Authentication Systems"
triggers: ["workflow", "authentication", "connectivity", "ssh-key", "password", "playbook-execution"]
applies_to: ["scripts/*", "playbooks/0_test-connectivity.yml", "run-playbook.sh"]
context: ["ansible", "workflow", "authentication", "ssh"]
priority: high
---

# Intelligent Workflow Instructions

## 🔄 Core Workflow Architecture

### Three-Layer Design Pattern
1. **Connectivity Testing** (playbook): Network reachability + SSH authentication testing
2. **Analysis & Decision** (script): Parse results, determine authentication method
3. **User Interaction** (script): Smart prompting with proper TTY handling

### Workflow Execution Sequence
```
Task Command → Script Wrapper → Intelligent Runner → Connectivity Test → Analysis → Authentication Decision → Playbook Execution
```

## 🧠 Intelligent Authentication System

### Connectivity Test Phase (Silent)
- **Purpose**: Test without user prompts or terminal pollution
- **Implementation**: `playbooks/0_test-connectivity.yml`
- **Tests Performed**:
  - [ ] Network connectivity (port 22)
  - [ ] SSH key authentication (`BatchMode=yes`)
  - [ ] Result storage in `/tmp/ansible_connectivity_results/`

### Analysis Phase (Script Logic)
- **Parse Results**: Categorize hosts by reachability and authentication method
- **Host Categories**:
  - Reachable with SSH key auth
  - Reachable requiring password auth  
  - Unreachable hosts
- **User Display**: Clean, color-coded summary

### Authentication Decision Logic
```bash
if all_reachable_hosts_have_ssh_keys; then
    run_playbook_without_password_prompt
elif some_hosts_need_passwords; then
    prompt_user_for_password_authentication_approval
    if approved; then
        run_playbook_with_ask_pass
    else
        exit_gracefully
    fi
else
    handle_unreachable_hosts
fi
```

## 🎯 TTY Handling Standards

### Requirements
- **Visible Prompts**: All password prompts must be visible and interactive
- **No Hanging**: Prevent commands from hanging waiting for invisible input
- **Clean Output**: Maintain color-coding and formatting

### Implementation Pattern
```bash
script -q /dev/null ansible-playbook [options]
```
- **Purpose**: Ensures proper TTY allocation
- **Benefits**: Makes prompts visible, preserves terminal functionality
- **Usage**: Apply to all ansible-playbook executions

## 📊 Output Standards

### Connectivity Test Results Format
```
Testing connectivity to hosts...
✓ Connectivity test completed
✓ Reachable hosts: ubuntu-1.local ubuntu-2.local ubuntu-4.local
✓ SSH key authentication: ubuntu-1.local ubuntu-2.local
⚠ Need password authentication: ubuntu-4.local
```

### Status Indicators
- **✓** (Green): Success, working as expected
- **⚠** (Yellow): Warning, attention needed but not fatal
- **✗** (Red): Error, requires intervention
- **ℹ** (Blue): Information, status update

### User Interaction Patterns
- **Clear Questions**: "Do you want to proceed with password authentication? (y/N)"
- **Default Actions**: Sensible defaults (N for potentially destructive actions)
- **Graceful Exit**: Clean exit messages when user declines

## 🔧 Script Development Patterns

### Error Handling Standards
```bash
# Check for required files
if [[ ! -f "$results_file" ]]; then
    echo "✗ Connectivity results not found. Run connectivity test first."
    exit 1
fi

# Validate host reachability
if [[ ${#reachable_hosts[@]} -eq 0 ]]; then
    echo "✗ No reachable hosts found. Check your inventory and network connectivity."
    exit 1
fi
```

### Result Processing Patterns
- **File-Based Communication**: Store results in `/tmp/ansible_connectivity_*`
- **JSON/YAML Parsing**: Use reliable parsing for Ansible output
- **Array Management**: Proper handling of host arrays and status

### User Experience Guidelines
- **Minimal Prompts**: Only prompt when necessary
- **Clear Context**: Explain why prompting (authentication method needed)
- **Quick Feedback**: Immediate confirmation of user choices

## 🏗️ Integration Requirements

### Task Runner Integration
- **Consistent Interface**: All playbooks accessible via `task playbook -- <name>`
- **Help Integration**: Dynamic discovery and listing of available playbooks
- **Error Propagation**: Proper exit codes and error messages

### Caching Strategy
- **Connectivity Results**: Cache in `/tmp/ansible_connectivity_*`
- **Cache Invalidation**: Clean cache with `task clean`
- **Performance**: Avoid unnecessary retesting

### Ansible Integration
- **Inventory Compatibility**: Work with existing `inventories/hosts.yml`
- **Variable Passing**: Proper handling of group and host variables
- **Collection Dependencies**: Ensure required collections are available

## 📋 Development Guidelines

### When Modifying Workflow
- [ ] Test all authentication scenarios (SSH keys, passwords, mixed, unreachable)
- [ ] Verify TTY handling with interactive prompts
- [ ] Maintain clean output formatting
- [ ] Test integration with task runner
- [ ] Validate error handling paths

### When Adding Authentication Methods
- [ ] Update connectivity testing playbook
- [ ] Modify analysis logic in `run-playbook.sh`
- [ ] Add appropriate user prompting
- [ ] Test edge cases and error conditions
- [ ] Document new authentication flow

### Performance Considerations
- **Silent Testing**: Keep connectivity tests fast and non-invasive
- **Result Caching**: Leverage cached results when appropriate
- **Parallel Execution**: Use Ansible's parallel capabilities
- **Timeout Handling**: Set appropriate timeouts for network operations

## 🔍 Troubleshooting Patterns

### Common Issues & Solutions
- **Hanging Prompts**: Ensure proper TTY allocation with `script` command
- **Authentication Failures**: Check SSH key deployment and permissions
- **Network Issues**: Validate host reachability and inventory configuration
- **Permission Problems**: Verify sudo configuration and user permissions

### Debugging Workflow
1. **Run Connectivity Test**: `task test` for isolated connectivity testing
2. **Check Results**: Examine `/tmp/ansible_connectivity_results/`
3. **Validate Inventory**: Confirm host definitions and variables
4. **Test Individual Hosts**: Use Ansible ad-hoc commands for specific hosts
