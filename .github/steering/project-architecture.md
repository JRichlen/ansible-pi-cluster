---
title: "Project Architecture & Component Organization"
triggers: ["project-structure", "file-organization", "component-layout", "directory-structure"]
applies_to: ["*", "playbooks/*", "scripts/*", "inventories/*"]
context: ["ansible", "project-architecture", "organization"]
priority: high
---

# Project Architecture Instructions

## 📁 Component Organization Rules

### Directory Structure Standards
```
ansible-pi-cluster/
├── playbooks/           # Numbered execution order (0_, 1_, 2_)
├── scripts/            # Shell scripts (task-*.sh pattern)
├── inventories/        # Host definitions and variables
├── roles/              # Ansible roles (future expansion)
├── .github/            # GitHub workflows and steering docs
└── Taskfile.yml        # Unified task interface
```

### File Naming Conventions
- **Playbooks**: `N_descriptive-name.yml` (numbered prefix for execution order)
- **Task Scripts**: `task-name.sh` (must integrate with Taskfile.yml)
- **Documentation**: Follow existing emoji and section patterns

## 🎯 Component Purposes & Responsibilities

### Playbooks Directory
- **0_test-connectivity.yml**: Silent connectivity testing, authentication detection
- **1_deploy-ssh-key.yml**: SSH key deployment, system setup, security
- **2_update-packages.yml**: System updates, development tools, security tools

**Adding New Playbooks:**
- [ ] Use next number in sequence
- [ ] Test integration with `task playbook -- N_name`
- [ ] Document purpose and dependencies
- [ ] Follow existing error handling patterns

### Scripts Directory
- **Core Script**: `task-playbook.sh` - intelligent workflow heart with user-friendly interface
- **Task Scripts**: `task-*.sh` - implement Taskfile.yml tasks
- **Integration**: All scripts must work with task runner system

**Script Development Rules:**
- [ ] Follow existing TTY handling patterns
- [ ] Maintain clean, color-coded output
- [ ] Include proper error handling
- [ ] Make executable with `chmod +x`
- [ ] Add corresponding Taskfile.yml task

### Inventory Management
- **hosts.yml**: Host definitions, connection parameters, group variables
- **Structure**: Support for host groups, connection variables, SSH options
- **Security**: Handle authentication methods (keys vs passwords)

## 🏗️ Architecture Principles

### Separation of Concerns
- **Playbooks**: Ansible logic, system configuration, testing
- **Scripts**: User interaction, authentication decisions, TTY management
- **Task Runner**: Unified interface, command organization

### Intelligent Automation
- **Authentication Detection**: Automatic SSH key vs password detection
- **Silent Testing**: Clean connectivity testing without terminal pollution
- **Graceful Handling**: Unreachable hosts, failed connections
- **Minimal Prompts**: Only prompt when actually needed

### Workflow Integration
```
Taskfile.yml → task-*.sh → task-playbook.sh → connectivity test → analysis → execution
```

## 📝 Development Guidelines

### When Adding Components

#### New Playbook Checklist
- [ ] Determine execution order number
- [ ] Create `N_descriptive-name.yml`
- [ ] Add to task runner integration
- [ ] Test with connectivity workflow
- [ ] Document purpose and usage

#### New Script Checklist
- [ ] Create `task-name.sh` 
- [ ] Add to `Taskfile.yml`
- [ ] Follow existing error handling
- [ ] Test TTY handling
- [ ] Document in scripts/README.md

#### New Role Checklist
- [ ] Create standard Ansible role structure
- [ ] Reference from appropriate playbooks
- [ ] Follow Ansible best practices
- [ ] Document dependencies

### Maintenance Standards
- **Documentation Updates**: Update relevant docs when adding components
- **Error Handling**: Follow existing robust error handling patterns
- **User Experience**: Maintain clean, color-coded output standards
- **Testing**: Include integration testing with existing workflow

### File Management Rules
- **Temporary Files**: Use `/tmp/ansible_connectivity_*` pattern
- **Cleanup**: Include cleanup tasks in maintenance scripts
- **Caching**: Leverage connectivity result caching for efficiency

## 🔄 Workflow Architecture

### Task Execution Flow
1. **User Command**: `task <command>`
2. **Script Wrapper**: `task-*.sh` handles arguments
3. **Intelligent Runner**: `task-playbook.sh` manages workflow with smart resolution
4. **Connectivity Test**: Silent testing with result analysis
5. **Authentication Decision**: Smart prompting based on test results
6. **Playbook Execution**: With appropriate authentication method

### Integration Points
- **Task Runner**: All functionality accessible via `task` commands
- **Connectivity System**: All playbooks integrate with intelligent authentication
- **Output Standards**: Consistent color-coding and messaging
- **Error Handling**: Graceful degradation and user guidance
