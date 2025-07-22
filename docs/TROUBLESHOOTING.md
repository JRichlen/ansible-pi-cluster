# 🛠️ Troubleshooting Guide

## 🎯 Overview

Comprehensive troubleshooting guide for common issues encountered when managing Raspberry Pi clusters with ansible-pi-cluster.

## 🔍 Quick Diagnostics

### Basic System Check
```bash
# Verify task runner installation
./bin/task list

# Test basic connectivity
task test

# Check current status
ls -la /tmp/ansible_connectivity_results/
```

### Environment Validation
```bash
# Check Ansible installation
ansible --version

# Verify inventory syntax
ansible-inventory -i inventories/hosts.yml --list

# Test Ansible connectivity manually
ansible -i inventories/hosts.yml ubuntu -m ping
```

## 🌐 Connectivity Issues

### ❌ Problem: "No hosts reachable"
**Symptoms**:
```
Testing connectivity to hosts...
❌ No hosts are reachable. Check your network connection and host availability.
```

**Common Causes**:
1. **Network Issues**: Hosts are powered off or unreachable
2. **DNS Resolution**: Hostnames not resolving correctly
3. **SSH Service**: SSH daemon not running on target hosts
4. **Firewall**: Port 22 blocked on target or source

**Solutions**:

1. **Check Host Status**:
   ```bash
   # Ping test
   ping ubuntu-1.local
   ping ubuntu-2.local
   
   # Check if SSH port is open
   nc -zv ubuntu-1.local 22
   ```

2. **Verify DNS Resolution**:
   ```bash
   # Check hostname resolution
   nslookup ubuntu-1.local
   
   # Try IP addresses instead of hostnames
   # Edit inventories/hosts.yml to use IPs
   ```

3. **SSH Service Verification**:
   ```bash
   # Test SSH manually
   ssh ubuntu-1.local
   
   # Check SSH service on target (if you have access)
   sudo systemctl status ssh
   sudo systemctl start ssh
   ```

### ⚠️ Problem: "Mixed SSH authentication"
**Symptoms**:
```
✓ SSH key authentication: ubuntu-1.local
⚠ Need password authentication: ubuntu-2.local ubuntu-3.local
```

**Expected Behavior**: This is normal and handled automatically by the system.

**Actions**:
1. **Accept password authentication** when prompted
2. **Deploy SSH keys** to problematic hosts:
   ```bash
   task playbook -- 1_deploy-ssh-key
   ```
3. **Verify key deployment**:
   ```bash
   task playbook -- 2_test-master-connectivity
   ```

### 🔑 Problem: "SSH permission denied"
**Symptoms**:
```
ubuntu-1.local | UNREACHABLE! => {
    "msg": "Permission denied (publickey,password)."
}
```

**Common Causes**:
1. **Wrong Username**: Incorrect `ansible_user` in inventory
2. **No SSH Keys**: No public keys available
3. **Wrong Key Location**: Keys not in expected location
4. **Key Permissions**: Incorrect file permissions

**Solutions**:

1. **Verify Username**:
   ```yaml
   # In inventories/hosts.yml
   all:
     children:
       ubuntu:
         vars:
           ansible_user: your-actual-username  # Check this
   ```

2. **Check SSH Key Availability**:
   ```bash
   # List available keys
   ls -la ~/.ssh/id_*.pub
   
   # Generate key if none exist
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

3. **Fix Key Permissions**:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_*
   chmod 644 ~/.ssh/id_*.pub
   ```

## 🔧 Installation Issues

### ❌ Problem: "Task runner not found"
**Symptoms**:
```bash
$ task list
bash: task: command not found
```

**Solution**:
```bash
# Install task runner
curl -sL https://taskfile.dev/install.sh | sh

# Or use the local binary
./bin/task list
```

### ❌ Problem: "Ansible collections missing"
**Symptoms**:
```
ERROR! couldn't resolve module/action 'kubernetes.core.k8s'
```

**Solution**:
```bash
# Install all dependencies
task install

# Manual installation if needed
ansible-galaxy collection install kubernetes.core
ansible-galaxy collection install community.general
```

### ⚠️ Problem: "Python dependencies missing"
**Symptoms**:
```
MODULE FAILURE: No module named 'kubernetes'
```

**Solution**:
```bash
# Install Python Kubernetes client
pip install kubernetes

# Or use system package manager
sudo apt-get install python3-kubernetes
```

## ☸️ Kubernetes Deployment Issues

### ❌ Problem: "Kubernetes initialization failed"
**Symptoms**:
```
fatal: [ubuntu-1]: FAILED! => {
    "msg": "kubeadm init failed"
}
```

**Common Causes**:
1. **Port Conflicts**: Required ports already in use
2. **Memory Issues**: Insufficient RAM on master node
3. **Swap Enabled**: Kubernetes requires swap to be disabled
4. **Container Runtime**: containerd not properly configured

**Solutions**:

1. **Check Prerequisites**:
   ```bash
   # Ensure SSH keys are deployed first
   task playbook -- 1_deploy-ssh-key
   
   # Prepare Kubernetes environment
   task playbook -- 5_prepare-kubernetes
   ```

2. **Memory Verification**:
   ```bash
   # Check available memory (needs 2GB+ for master)
   ansible -i inventories/hosts.yml ubuntu-1.local -m shell -a "free -h"
   ```

3. **Port Availability**:
   ```bash
   # Check if required ports are free
   ansible -i inventories/hosts.yml ubuntu-1.local -m shell -a "ss -tulpn | grep :6443"
   ```

4. **Reset and Retry**:
   ```bash
   # Reset Kubernetes if needed
   ansible -i inventories/hosts.yml ubuntu -m shell -a "sudo kubeadm reset -f" --become
   
   # Clean containerd
   ansible -i inventories/hosts.yml ubuntu -m shell -a "sudo systemctl restart containerd" --become
   
   # Retry deployment
   task playbook -- 6_deploy-kubernetes
   ```

### ⚠️ Problem: "Worker nodes not joining"
**Symptoms**:
```bash
$ kubectl get nodes
NAME       STATUS     ROLES           AGE   VERSION
ubuntu-1   Ready      control-plane   10m   v1.29.0
# Missing worker nodes
```

**Solutions**:

1. **Check Join Token**:
   ```bash
   # Regenerate join command
   ansible -i inventories/hosts.yml ubuntu-1.local -m shell -a "sudo kubeadm token create --print-join-command" --become
   ```

2. **Verify Network Connectivity**:
   ```bash
   # Test master connectivity from workers
   task playbook -- 2_test-master-connectivity
   ```

3. **Check Worker Node Status**:
   ```bash
   # Check kubelet status on workers
   ansible -i inventories/hosts.yml ubuntu-2.local -m shell -a "sudo systemctl status kubelet" --become
   ```

## 🔐 Tailscale Issues

### ❌ Problem: "Tailscale auth key invalid"
**Symptoms**:
```
fatal: [ubuntu-1]: FAILED! => {
    "msg": "Tailscale authentication failed"
}
```

**Solutions**:

1. **Generate New Auth Key**:
   - Visit [Tailscale Admin Console](https://login.tailscale.com/admin/authkeys)
   - Generate a new auth key
   - Export the key: `export TAILSCALE_AUTH_KEY="tskey-auth-xxxxxxxxxxxx"`

2. **Check Key Expiration**:
   - Auth keys have expiration dates
   - Ensure the key hasn't expired
   - Generate a new key if needed

3. **Manual Auth Key Entry**:
   ```bash
   # Don't set environment variable, let playbook prompt
   unset TAILSCALE_AUTH_KEY
   task playbook -- 4_install-tailscale
   ```

## 🧹 State Reset Procedures

### Complete System Reset
```bash
# Clean all cached data
task clean

# Reset SSH authentication state
rm -rf /tmp/ansible_connectivity_results/

# Reinstall dependencies
task install

# Test from clean state
task test
```

### Kubernetes Reset
```bash
# Reset all Kubernetes components
ansible -i inventories/hosts.yml ubuntu -m shell -a "sudo kubeadm reset -f" --become

# Clean containerd
ansible -i inventories/hosts.yml ubuntu -m shell -a "sudo systemctl restart containerd" --become

# Remove kubeconfig
rm -f ~/.kube/pi-cluster-config

# Redeploy from scratch
task playbook -- 5_prepare-kubernetes
task playbook -- 6_deploy-kubernetes
```

### SSH Key Reset
```bash
# Remove deployed keys from remote hosts
ansible -i inventories/hosts.yml ubuntu -m shell -a "rm -f ~/.ssh/authorized_keys"

# Redeploy SSH keys
task playbook -- 1_deploy-ssh-key
```

## 🔍 Debug Mode

### Enable Verbose Output
```bash
# Ansible verbosity levels
ANSIBLE_VERBOSITY=1 task playbook -- <playbook>  # Basic
ANSIBLE_VERBOSITY=2 task playbook -- <playbook>  # Detailed
ANSIBLE_VERBOSITY=3 task playbook -- <playbook>  # Debug
ANSIBLE_VERBOSITY=4 task playbook -- <playbook>  # Full debug
```

### Manual Ansible Execution
```bash
# Run playbook manually with full verbosity
ansible-playbook -i inventories/hosts.yml -vvvv playbooks/1_deploy-ssh-key.yml

# Test specific hosts
ansible -i inventories/hosts.yml ubuntu-1.local -m ping -vvv

# Check facts gathering
ansible -i inventories/hosts.yml ubuntu -m setup
```

## 📞 Getting Help

### Information Gathering
When reporting issues, please include:

1. **Environment Information**:
   ```bash
   # System info
   uname -a
   ansible --version
   ./bin/task --version
   
   # Project state
   git log --oneline -5
   ls -la /tmp/ansible_connectivity_results/
   ```

2. **Error Output**:
   - Complete error messages
   - Full command that failed
   - Any relevant log files

3. **Configuration**:
   - Content of `inventories/hosts.yml` (sanitized)
   - Any custom environment variables
   - Network topology/setup

### Log Files
```bash
# Ansible logs (if configured)
tail -f /var/log/ansible.log

# System logs on target hosts
sudo journalctl -u ssh
sudo journalctl -u kubelet
sudo journalctl -u containerd
```

### Support Channels
- **GitHub Issues**: Report bugs and feature requests
- **Documentation**: Check related docs for additional context
- **Community**: Ansible and Kubernetes community resources

## 📚 Related Documentation

- [README.md](../README.md) - Quick start and basic usage
- [WORKFLOW.md](WORKFLOW.md) - Understanding the system architecture
- [API.md](API.md) - Complete command reference
- [DEPLOYMENT.md](DEPLOYMENT.md) - Production deployment guidelines