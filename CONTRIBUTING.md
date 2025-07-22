# 🤝 Contributing to ansible-pi-cluster

## 🎯 Welcome Contributors!

Thank you for your interest in contributing to ansible-pi-cluster! This project thrives on community contributions and we welcome improvements, bug fixes, and new features.

## 📋 Quick Start for Contributors

### Prerequisites
- Git installed and configured
- [go-task](https://taskfile.dev/) installed (or use `./bin/task`)
- Ansible installed and basic familiarity
- Access to Raspberry Pi or similar ARM64 hardware for testing (optional)

### Getting Started
```bash
# Clone the repository
git clone https://github.com/JRichlen/ansible-pi-cluster.git
cd ansible-pi-cluster

# Install dependencies
task install

# Run tests to ensure everything works
task test
```

## 🏗️ Project Architecture Understanding

Before contributing, please familiarize yourself with the project structure:

### 📚 Required Reading
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design and component overview
- [WORKFLOW.md](WORKFLOW.md) - Three-layer architecture and execution flow
- [.github/steering/](/.github/steering/) - Development patterns and guidelines

### Key Architecture Principles
1. **Three-Layer Design**: Connectivity testing → Analysis → User interaction
2. **Separation of Concerns**: Playbooks are pure automation, scripts handle UI
3. **User Experience First**: Clear, color-coded output with minimal user prompts
4. **Robust Error Handling**: Multiple fallback mechanisms and helpful error messages

## 🔧 Development Workflow

### Setting Up Development Environment
```bash
# Ensure you have the task runner
./bin/task list

# Install development dependencies
task install

# Test your setup
task playbook -- 0_test-connectivity
```

### Code Style and Standards

#### Shell Scripts (`scripts/`)
- **Naming**: Use `task-*.sh` pattern for new task scripts
- **Error Handling**: Always include proper error handling and user feedback
- **TTY Compatibility**: Use `script -q /dev/null` for interactive commands
- **Color Coding**: Follow existing emoji and color patterns
- **Documentation**: Include comments explaining complex logic

**Example**:
```bash
#!/bin/bash
# task-example.sh - Example task implementation

set -euo pipefail

# Color definitions (consistent with other scripts)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "🔄 Starting example task..."

# Error handling example
if ! command -v ansible >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: Ansible is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Example task completed successfully${NC}"
```

#### Ansible Playbooks (`playbooks/`)
- **Naming**: Use numbered prefix for execution order (`N_descriptive-name.yml`)
- **No User Interaction**: Playbooks should run silently without prompts
- **Idempotency**: All tasks should be idempotent and safe to re-run
- **Error Handling**: Include proper error checking and informative failure messages
- **Documentation**: Add task names and comments explaining purpose

**Example**:
```yaml
---
- name: Example Playbook - Brief Description
  hosts: ubuntu
  gather_facts: true
  become: true
  
  pre_tasks:
    - name: Verify prerequisites
      ansible.builtin.fail:
        msg: "Required condition not met"
      when: not some_condition
  
  tasks:
    - name: Descriptive task name
      ansible.builtin.package:
        name: example-package
        state: present
      register: package_result
      
    - name: Show result if verbose
      ansible.builtin.debug:
        var: package_result
      when: ansible_verbosity >= 2
```

#### Task Runner Integration (`Taskfile.yml`)
- **New Tasks**: Add to `Taskfile.yml` if creating new functionality
- **Script Integration**: Ensure new scripts are properly integrated
- **Documentation**: Update task descriptions to be clear and helpful

### Testing Your Changes

#### Basic Testing
```bash
# Test connectivity (basic functionality)
task test

# Test specific playbook
task playbook -- 0_test-connectivity

# Clean up after testing
task clean
```

#### Integration Testing
```bash
# Test complete workflow
task all

# Test individual components
task playbook -- 1_deploy-ssh-key
task playbook -- 3_update-packages
```

#### Manual Testing
```bash
# Test with verbose output
ANSIBLE_VERBOSITY=2 task playbook -- your-playbook

# Test error conditions
# (disconnect network, change credentials, etc.)
```

## 🎯 Types of Contributions

### 🐛 Bug Fixes
1. **Identify the Issue**: Clearly understand the problem
2. **Reproduce the Bug**: Create steps to reproduce consistently
3. **Minimal Fix**: Make the smallest change possible to fix the issue
4. **Test Thoroughly**: Ensure the fix works and doesn't break anything else

### ✨ New Features
1. **Discuss First**: Open an issue to discuss the feature before implementing
2. **Follow Architecture**: Ensure new features fit the three-layer design
3. **Update Documentation**: Add appropriate documentation for new features
4. **Integration**: Ensure proper integration with the task runner system

### 📚 Documentation Improvements
1. **Accuracy**: Ensure all examples actually work
2. **Clarity**: Write for users who may be new to Ansible or Kubernetes
3. **Completeness**: Include troubleshooting info for common issues
4. **Consistency**: Follow existing formatting and emoji patterns

### 🔧 Infrastructure Improvements
1. **Automation**: Improve the development workflow
2. **Testing**: Add better testing capabilities
3. **CI/CD**: Enhance automated testing and validation

## 📝 Pull Request Guidelines

### Before Submitting
- [ ] **Test your changes** with `task test` and relevant playbooks
- [ ] **Update documentation** if your changes affect user-facing functionality
- [ ] **Follow code style** guidelines outlined above
- [ ] **Check for breaking changes** and note them in PR description

### PR Description Template
```markdown
## 🎯 Purpose
Brief description of what this PR accomplishes.

## 🔧 Changes Made
- List specific changes
- Include any new files or modifications
- Note any breaking changes

## 🧪 Testing
- [ ] Tested with `task test`
- [ ] Tested relevant playbooks: `task playbook -- X`
- [ ] Tested integration with existing workflows
- [ ] Verified documentation accuracy

## 📚 Documentation
- [ ] Updated relevant .md files
- [ ] Added/updated inline comments
- [ ] Verified all examples work

## 🎨 Additional Notes
Any additional context, screenshots, or considerations.
```

### Review Process
1. **Automated Checks**: Ensure all automated tests pass
2. **Code Review**: Maintainers will review for architecture alignment
3. **Testing**: Changes will be tested in various scenarios
4. **Documentation**: Verify documentation is accurate and complete

## 🚀 Development Guidelines

### Adding New Playbooks
1. **Number Appropriately**: Use the next number in sequence
2. **Follow Dependencies**: Ensure dependencies are clearly documented
3. **Test Integration**: Verify integration with `task-playbook.sh`
4. **Update Documentation**: Add to README.md and API.md

### Adding New Scripts
1. **Follow Naming**: Use `task-*.sh` pattern
2. **Integrate with Taskfile**: Add appropriate task definition
3. **Error Handling**: Include robust error handling
4. **User Experience**: Maintain consistent output formatting

### Modifying Core Scripts
1. **Understand Impact**: Core scripts affect all functionality
2. **Test Extensively**: Test all workflows and edge cases
3. **Backward Compatibility**: Avoid breaking existing usage patterns
4. **Documentation**: Update architecture docs if needed

## 🤔 Getting Help

### Documentation Resources
- [ARCHITECTURE.md](ARCHITECTURE.md) - Understanding the system design
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions
- [API.md](API.md) - Complete command reference
- [.github/steering/](/.github/steering/) - Development pattern guidance

### Community Support
- **GitHub Issues**: Ask questions or report problems
- **Discussions**: Use GitHub discussions for broader topics
- **Code Review**: Request review feedback during PR process

### Maintainer Contact
- Open an issue for questions or clarification
- Tag maintainers in PRs when ready for review
- Be patient - this is a volunteer-driven project

## 🎉 Recognition

Contributors are recognized in:
- Git commit history and PR acknowledgments
- Project documentation where appropriate
- Release notes for significant contributions

## 📄 License Agreement

By contributing to this project, you agree that your contributions will be licensed under the same MIT License that covers the project.

## 🔄 Continuous Improvement

This contributing guide is a living document. If you find ways to improve the development process or documentation, please suggest changes!

### Areas for Improvement
- Development automation
- Testing procedures
- Documentation clarity
- Onboarding process

Thank you for contributing to ansible-pi-cluster! 🚀