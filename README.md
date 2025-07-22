# Ansible Pi Cluster Management

A modern, interactive Ansible automation system for managing Raspberry Pi clusters with intelligent SSH authentication and robust error handling.

## ✨ Features

- **🎯 Smart Authentication**: Automatically detects SSH key vs password authentication needs
- **🔇 Clean Output**: Silent connectivity testing with clear, color-coded summaries  
- **💻 Perfect TTY Handling**: All prompts are visible and interactive, no hanging commands
- **⚡ Efficient Workflow**: Cached connectivity results, skip unnecessary steps
- **🔒 Robust Architecture**: Clean separation of playbook logic and user interaction
- **🔑 Master Node SSH**: Automatic SSH key generation and distribution for inter-node communication
- **☸️ Kubernetes Ready**: Full cluster deployment with ARM64 optimization for Raspberry Pi

## 🚀 Quick Start

### Prerequisites
- [go-task](https://taskfile.dev/) installed
- Ansible installed
- SSH access to target hosts

**Note**: Run `task install` to automatically install all required Ansible collections including Tailscale support.

### Run Any Playbook
```bash
# The intelligent workflow handles everything automatically:
task playbook -- <playbook-name>

# Examples:
task playbook -- 0_test-connectivity    # Test connectivity only
task playbook -- 1_deploy-ssh-key       # Deploy SSH keys with smart auth detection
task playbook -- 2_test-master-connectivity  # Test master node SSH to workers
task playbook -- 3_update-packages      # Update system packages
task playbook -- 4_install-tailscale    # Install and configure Tailscale VPN
task playbook -- 5_deploy-kubernetes    # Deploy Kubernetes cluster (requires SSH keys)
task playbook -- 6_verify-kubernetes    # Verify cluster health and test workloads
```

### What You'll Experience

#### All SSH Keys Working ✅
```
Testing connectivity to hosts...
✓ Connectivity test completed
✓ Reachable hosts: ubuntu-1.local ubuntu-2.local ubuntu-4.local  
✓ SSH key authentication: ubuntu-1.local ubuntu-2.local ubuntu-4.local

Running playbook: 1_deploy-ssh-key
[Playbook runs automatically without prompts]
```

#### Some Hosts Need Passwords ⚠️
```
Testing connectivity to hosts...
✓ Connectivity test completed
✓ Reachable hosts: ubuntu-1.local ubuntu-2.local ubuntu-4.local
✓ SSH key authentication: ubuntu-1.local
⚠ Need password authentication: ubuntu-2.local ubuntu-4.local

Some hosts require password authentication.
Do you want to proceed with password authentication? (y/N): 
```

## 📋 Available Tasks

```bash
task list                    # Show all available tasks
task install                 # Install project dependencies  
task test                    # Test connectivity to all hosts
task playbook -- <name>     # Run specific playbook with smart workflow
task all                     # Run all playbooks in sequence
task clean                   # Clean up temporary files
```

## 🏗️ Architecture

The system uses a three-layer approach:

1. **Connectivity Testing** (Ansible playbook) - Tests network and SSH authentication silently
2. **Analysis & Decision** (Shell script) - Parses results and determines authentication method  
3. **User Interaction** (Shell script) - Prompts for passwords only when needed

See [WORKFLOW.md](WORKFLOW.md) for detailed architecture documentation.

## ☸️ Kubernetes Deployment

Deploy a production-ready Kubernetes cluster optimized for Raspberry Pi:

```bash
# Prerequisites (run these first)
task playbook -- 1_deploy-ssh-key    # Required for inter-node communication
task playbook -- 3_update-packages   # Recommended for latest system packages

# Deploy full Kubernetes cluster
task playbook -- 5_deploy-kubernetes

# Verify cluster health (optional)
task playbook -- 6_verify-kubernetes
```

**What gets deployed:**
- **Control Plane:** ubuntu-1 (master with kubeadm)
- **Workers:** ubuntu-2, ubuntu-3, ubuntu-4
- **Container Runtime:** containerd (ARM64 optimized)
- **CNI:** Cilium networking with eBPF and kube-proxy replacement
- **Features:** Graceful shutdown, systemd cgroups, memory optimization

**After deployment:**
- Kubeconfig automatically copied to `~/.kube/pi-cluster-config`
- Ready for kubectl, helm, and any Kubernetes workloads
- Optimized for Raspberry Pi hardware constraints

See [docs/kubernetes-deployment.md](docs/kubernetes-deployment.md) for detailed deployment guide.

## 📁 Project Structure

```
├── Taskfile.yml              # Task runner configuration
├── requirements.yml          # Ansible collections and roles
├── inventories/
│   └── hosts.yml             # Ansible inventory
├── playbooks/
│   ├── 0_test-connectivity.yml    # Silent connectivity testing
│   ├── 1_deploy-ssh-key.yml      # SSH key deployment
│   ├── 2_test-master-connectivity.yml # Master-worker SSH verification  
│   ├── 3_update-packages.yml     # System updates
│   ├── 4_install-tailscale.yml   # Tailscale VPN setup
│   ├── 5_deploy-kubernetes.yml   # Full Kubernetes cluster deployment
│   └── 6_verify-kubernetes.yml   # Cluster health verification
├── scripts/
│   ├── task-playbook.sh      # Consolidated intelligent playbook runner
│   ├── task-*.sh            # Individual task implementations
│   └── simulate-*.sh        # Testing utilities
├── docs/
│   └── kubernetes-deployment.md  # Kubernetes deployment guide
└── WORKFLOW.md              # Detailed architecture documentation
```

## 🔧 Configuration

### Inventory Setup
Edit `inventories/hosts.yml`:
```yaml
all:
  children:
    ubuntu:
      hosts:
        ubuntu-1.local:
        ubuntu-2.local:
        ubuntu-3.local:
        ubuntu-4.local:
      vars:
        ansible_user: jrichlen
        ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
```

### SSH Key Setup
The system automatically detects and uses SSH keys from:
- `~/.ssh/id_rsa.pub` (default)
- `~/.ssh/id_ed25519.pub` (fallback)
- `~/.ssh/id_ecdsa.pub` (fallback)

### Tailscale Configuration
To use the Tailscale VPN setup:

1. **Install Dependencies**: Run `task install` (includes Tailscale collection)
2. **Get Auth Key**: Visit [Tailscale Admin Console](https://login.tailscale.com/admin/authkeys) to generate an auth key
3. **Set Environment Variable**: 
   ```bash
   export TAILSCALE_AUTH_KEY="your-auth-key-here"
   task playbook -- 4_install-tailscale
   ```
4. **Alternative**: If no environment variable is set, the playbook will prompt for the auth key securely

**Security Note**: Auth keys are handled securely and never logged in plain text.

Generate a new key if needed:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

## 🛠️ Troubleshooting

### Connectivity Issues
```bash
# Test connectivity only
task playbook -- 0_test-connectivity

# Check results manually
ls -la /tmp/ansible_connectivity_results/
cat /tmp/ansible_connectivity_results/*.env
```

### Prompt Visibility Issues
The system uses `script -q /dev/null` to ensure proper TTY allocation. All prompts should be visible and interactive.

### SSH Key Authentication
If SSH keys aren't working, the system will automatically prompt for passwords when needed. No manual configuration required.

## 📝 Contributing

1. Follow the architecture principles in [WORKFLOW.md](WORKFLOW.md)
2. Keep playbook logic separate from user interaction
3. Ensure all prompts work with TTY allocation
4. Test with various connectivity scenarios

## 📄 License

MIT License - see LICENSE file for details.
