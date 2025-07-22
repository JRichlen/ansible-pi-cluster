# 🏗️ System Architecture

## 🎯 Overview

The ansible-pi-cluster project implements a sophisticated automation system designed specifically for managing Raspberry Pi clusters. The architecture prioritizes user experience, robust error handling, and intelligent automation while maintaining clean separation of concerns.

## 📊 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                           User Interface Layer                      │
├─────────────────────────────────────────────────────────────────────┤
│  Task Runner (Taskfile.yml)                                        │
│  ├─ task install     - Dependency management                       │
│  ├─ task test        - Connectivity testing                        │
│  ├─ task playbook    - Intelligent playbook execution              │
│  ├─ task all         - Sequential playbook execution               │
│  └─ task clean       - Cleanup operations                          │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Orchestration Layer                           │
├─────────────────────────────────────────────────────────────────────┤
│  Shell Scripts (scripts/)                                          │
│  ├─ task-playbook.sh    - Intelligent workflow orchestration       │
│  ├─ task-test.sh        - Connectivity testing coordinator         │
│  ├─ task-install.sh     - Dependency installer                     │
│  └─ task-*.sh           - Individual task implementations          │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Automation Layer                              │
├─────────────────────────────────────────────────────────────────────┤
│  Ansible Playbooks (playbooks/)                                    │
│  ├─ 0_test-connectivity     - Silent network/auth testing          │
│  ├─ 1_deploy-ssh-key        - SSH key deployment & security        │
│  ├─ 2_test-master-conn.     - Master node connectivity validation  │
│  ├─ 3_update-packages       - System updates & tools              │
│  ├─ 4_install-tailscale     - VPN mesh networking                  │
│  ├─ 5_prepare-kubernetes    - Kubernetes preparation               │
│  ├─ 6_deploy-kubernetes     - Full K8s cluster deployment          │
│  └─ 7_verify-kubernetes     - Cluster health verification          │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Infrastructure Layer                          │
├─────────────────────────────────────────────────────────────────────┤
│  Target Hosts (inventories/hosts.yml)                             │
│  ├─ ubuntu-1.local     - Master node (control plane)              │
│  ├─ ubuntu-2.local     - Worker node                              │
│  ├─ ubuntu-3.local     - Worker node                              │
│  └─ ubuntu-4.local     - Worker node                              │
└─────────────────────────────────────────────────────────────────────┘
```

## 🔧 Component Architecture

### Task Runner System
**File**: `Taskfile.yml`  
**Purpose**: Unified command interface and task coordination  
**Key Features**:
- Dynamic playbook discovery
- Consistent command patterns
- Environment variable management
- Integration with shell scripts

### Orchestration Scripts
**Directory**: `scripts/`  
**Purpose**: Workflow logic and user interaction  
**Key Components**:

#### `task-playbook.sh` - The Heart of the System
- Implements the three-layer workflow architecture
- Handles SSH authentication detection
- Manages user interaction and prompts
- Coordinates between connectivity testing and playbook execution

#### Supporting Scripts
- `task-test.sh` - Connectivity testing coordinator
- `task-install.sh` - Dependency management
- `task-all.sh` - Sequential execution controller
- `task-clean.sh` - Cleanup and maintenance

### Ansible Automation
**Directory**: `playbooks/`  
**Purpose**: Pure automation logic without user interaction  
**Design Pattern**: Numbered execution sequence

#### Playbook Categories:

**Foundation Playbooks (0-2)**:
- Network connectivity validation
- SSH key infrastructure
- Inter-node communication setup

**System Playbooks (3-4)**:
- Package management and updates
- VPN mesh networking (Tailscale)

**Kubernetes Playbooks (5-7)**:
- Container runtime preparation
- Full cluster deployment
- Health verification and testing

### Configuration Management
**Directory**: `inventories/`  
**Purpose**: Host definitions and variables  
**Structure**:
- Host grouping and organization
- SSH configuration and credentials
- Environment-specific variables

## 🔄 Data Flow Architecture

### Authentication Detection Flow
```
User Command → Connectivity Test → Result Analysis → User Prompt (if needed) → Playbook Execution
```

1. **Silent Testing**: `0_test-connectivity.yml` runs without user interaction
2. **Result Parsing**: Scripts analyze SSH authentication capabilities
3. **Smart Prompting**: Users only prompted when password auth is required
4. **Optimized Execution**: Playbooks run with optimal authentication method

### Result Caching System
**Location**: `/tmp/ansible_connectivity_results/`  
**Format**: Environment files per host  
**Purpose**: Avoid redundant connectivity testing  
**Lifecycle**: Cleaned by `task clean`

## 🎯 Design Principles

### Intelligent Automation
- **Smart Authentication**: Automatic SSH key vs password detection
- **Cached Results**: Efficient operations with minimal redundancy
- **Graceful Degradation**: Fallback mechanisms for all failure scenarios
- **User-Centric Design**: Minimal interaction required, maximum clarity when needed

### Separation of Concerns
- **Playbooks**: Pure automation, no user prompts
- **Scripts**: User interface and workflow coordination
- **Task Runner**: Command abstraction and consistency
- **Configuration**: Environment and host management

### Robust Error Handling
- **Multiple Fallbacks**: Network connectivity via multiple methods
- **Clear Messaging**: Color-coded status with emoji indicators
- **TTY Perfection**: All prompts visible and interactive
- **Recovery Guidance**: Actionable error messages and suggestions

## 🔒 Security Architecture

### SSH Key Management
- Automatic detection of available SSH keys
- Secure key distribution with proper permissions
- Master node key generation for inter-node communication
- Fallback to password authentication when needed

### Network Security
- Tailscale VPN mesh networking support
- SSH hardening through key-based authentication
- Secure credential handling (no plaintext storage)
- Connection validation before sensitive operations

## 🚀 Performance Architecture

### Optimization Strategies
- **Parallel Execution**: Ansible's built-in parallelism
- **Result Caching**: Avoid redundant connectivity tests
- **Efficient Targeting**: Run tasks only on relevant hosts
- **Resource Awareness**: ARM64 optimizations for Raspberry Pi

### Scalability Considerations
- **Modular Playbooks**: Easy addition of new automation
- **Flexible Inventory**: Simple host addition/removal
- **Plugin Architecture**: Ansible collections for extended functionality
- **Container Readiness**: Kubernetes deployment for containerized workloads

## 📚 Related Documentation

- [WORKFLOW.md](WORKFLOW.md) - Detailed workflow and execution patterns
- [API.md](API.md) - Complete command reference and usage
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions
- [DEPLOYMENT.md](DEPLOYMENT.md) - Production deployment guidelines