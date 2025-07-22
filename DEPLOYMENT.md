# 🚀 Production Deployment Guide

## 🎯 Overview

Comprehensive guide for deploying and managing ansible-pi-cluster in production environments, including best practices, security considerations, and operational procedures.

## 🏗️ Infrastructure Planning

### Hardware Requirements

#### Master Node (Control Plane)
- **CPU**: 4+ cores (ARM64 recommended)
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 32GB+ SD card (Class 10 or better)
- **Network**: Stable Ethernet connection preferred
- **Role**: kubernetes control plane, cluster coordination

#### Worker Nodes  
- **CPU**: 2+ cores (ARM64)
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 16GB+ SD card (Class 10 or better)
- **Network**: Stable network connection (Ethernet or WiFi)
- **Role**: Container workload execution

#### Network Architecture
```
Internet
    │
    ▼
┌─────────────────┐    ┌─────────────────┐
│   Router/FW     │    │   Tailscale     │
│   Port 22       │    │   Mesh VPN      │
└─────────────────┘    └─────────────────┘
    │                           │
    ▼                           ▼
┌───────────────────────────────────────────┐
│           Local Network                    │
│  ┌─────────┐ ┌─────────┐ ┌─────────────┐ │
│  │ubuntu-1 │ │ubuntu-2 │ │  ubuntu-3/4 │ │
│  │(master) │ │(worker) │ │  (workers)  │ │
│  └─────────┘ └─────────┘ └─────────────┘ │
└───────────────────────────────────────────┘
```

## 🔒 Security Configuration

### SSH Hardening
```yaml
# In inventories/hosts.yml - Production SSH settings
all:
  children:
    ubuntu:
      vars:
        ansible_user: pi-admin
        ansible_ssh_common_args: >-
          -o StrictHostKeyChecking=yes
          -o UserKnownHostsFile=~/.ssh/known_hosts
          -o ControlMaster=auto
          -o ControlPersist=300
```

### Production SSH Setup
```bash
# 1. Generate dedicated deployment key
ssh-keygen -t ed25519 -f ~/.ssh/pi-cluster-deploy -C "pi-cluster-deployment"

# 2. Deploy with strong security
task playbook -- 1_deploy-ssh-key

# 3. Disable password authentication on targets
ansible -i inventories/hosts.yml ubuntu -m lineinfile \
  -a "path=/etc/ssh/sshd_config line='PasswordAuthentication no'" \
  --become

# 4. Restart SSH service
ansible -i inventories/hosts.yml ubuntu -m service \
  -a "name=ssh state=restarted" --become
```

### Firewall Configuration
```bash
# Enable UFW on all nodes
ansible -i inventories/hosts.yml ubuntu -m ufw \
  -a "state=enabled policy=deny direction=incoming" --become

# Allow SSH
ansible -i inventories/hosts.yml ubuntu -m ufw \
  -a "rule=allow port=22 proto=tcp" --become

# Allow Kubernetes API (master only)
ansible -i inventories/hosts.yml ubuntu-1.local -m ufw \
  -a "rule=allow port=6443 proto=tcp" --become

# Allow NodePort range (all nodes)
ansible -i inventories/hosts.yml ubuntu -m ufw \
  -a "rule=allow port=30000:32767 proto=tcp" --become
```

## 🌐 Network Configuration

### Tailscale VPN Deployment
```bash
# 1. Obtain production auth key from Tailscale admin
# - Set as reusable for multiple devices
# - Set appropriate expiration (1 year for production)
# - Enable device authorization if required

# 2. Deploy Tailscale mesh
export TAILSCALE_AUTH_KEY="tskey-auth-production-key"
task playbook -- 4_install-tailscale

# 3. Verify mesh connectivity
tailscale ping ubuntu-1
tailscale ping ubuntu-2
```

### DNS Configuration
```yaml
# Production inventory with both local and Tailscale addresses
all:
  children:
    ubuntu:
      hosts:
        ubuntu-1.local:
          ansible_host: 192.168.1.10
          tailscale_ip: 100.64.1.10
        ubuntu-2.local:
          ansible_host: 192.168.1.11  
          tailscale_ip: 100.64.1.11
        ubuntu-3.local:
          ansible_host: 192.168.1.12
          tailscale_ip: 100.64.1.12
        ubuntu-4.local:
          ansible_host: 192.168.1.13
          tailscale_ip: 100.64.1.13
```

## ☸️ Kubernetes Production Deployment

### Pre-Deployment Checklist
- [ ] SSH keys deployed and password auth disabled
- [ ] System packages updated on all nodes
- [ ] Firewall configured appropriately
- [ ] Network connectivity verified (including Tailscale if used)
- [ ] Sufficient resources available on all nodes
- [ ] DNS resolution working for all nodes

### Production Deployment Sequence
```bash
# 1. Foundation setup
task playbook -- 1_deploy-ssh-key
task playbook -- 3_update-packages

# 2. Network setup (optional but recommended)
task playbook -- 4_install-tailscale

# 3. Kubernetes preparation
task playbook -- 5_prepare-kubernetes

# 4. Full cluster deployment
task playbook -- 6_deploy-kubernetes

# 5. Verification and health check
task playbook -- 7_verify-kubernetes
```

### Production Kubernetes Configuration
The deployment automatically configures:

#### Control Plane Features
- **High Availability**: Single master (can be extended to multi-master)
- **Secure Communication**: TLS for all cluster communication
- **RBAC**: Role-based access control enabled
- **Resource Limits**: Memory and CPU limits for system components

#### Container Runtime
- **containerd**: Optimized for ARM64 architecture
- **Systemd cgroups**: Proper resource management
- **Image pulling**: Efficient image management
- **Security**: Non-privileged container execution

#### Networking (Cilium CNI)
- **eBPF-based**: High-performance networking with eBPF
- **Kube-proxy replacement**: Direct routing for better performance
- **Network policies**: Micro-segmentation capabilities
- **Service mesh ready**: Istio/Linkerd compatible

## 📊 Monitoring & Observability

### Cluster Health Monitoring
```bash
# Regular health checks
kubectl --kubeconfig ~/.kube/pi-cluster-config get nodes
kubectl --kubeconfig ~/.kube/pi-cluster-config get pods -A

# Resource usage monitoring
kubectl --kubeconfig ~/.kube/pi-cluster-config top nodes
kubectl --kubeconfig ~/.kube/pi-cluster-config top pods -A
```

### System Monitoring
```bash
# Node-level monitoring via Ansible
ansible -i inventories/hosts.yml ubuntu -m shell -a "df -h"
ansible -i inventories/hosts.yml ubuntu -m shell -a "free -h"
ansible -i inventories/hosts.yml ubuntu -m shell -a "uptime"
```

### Log Management
```bash
# Kubernetes logs
kubectl --kubeconfig ~/.kube/pi-cluster-config logs -n kube-system -l k8s-app=cilium

# System logs on nodes
ansible -i inventories/hosts.yml ubuntu -m shell \
  -a "sudo journalctl -u kubelet --since '1 hour ago'" --become
```

## 🔄 Operational Procedures

### Regular Maintenance

#### Weekly Tasks
```bash
# System updates
task playbook -- 3_update-packages

# Cluster health verification
task playbook -- 7_verify-kubernetes

# Connectivity testing
task test
```

#### Monthly Tasks
```bash
# Full system cleanup
task clean

# Kubernetes cluster validation
kubectl --kubeconfig ~/.kube/pi-cluster-config cluster-info
kubectl --kubeconfig ~/.kube/pi-cluster-config get componentstatuses
```

### Backup Procedures

#### Configuration Backup
```bash
# Backup cluster configuration
mkdir -p backups/$(date +%Y%m%d)
cp -r inventories/ backups/$(date +%Y%m%d)/
cp ~/.kube/pi-cluster-config backups/$(date +%Y%m%d)/

# Backup etcd (on master node)
ansible -i inventories/hosts.yml ubuntu-1.local -m shell \
  -a "sudo ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup-$(date +%Y%m%d).db" \
  --become
```

#### Recovery Procedures
```bash
# Restore from backup
cp backups/YYYYMMDD/inventories/hosts.yml inventories/
cp backups/YYYYMMDD/pi-cluster-config ~/.kube/

# Redeploy if needed
task playbook -- 6_deploy-kubernetes
```

### Scaling Operations

#### Adding Worker Nodes
1. **Prepare new node**:
   ```bash
   # Add to inventory
   vim inventories/hosts.yml
   ```

2. **Deploy foundation**:
   ```bash
   task playbook -- 1_deploy-ssh-key
   task playbook -- 3_update-packages
   task playbook -- 5_prepare-kubernetes
   ```

3. **Join to cluster**:
   ```bash
   # Get join command from master
   ansible -i inventories/hosts.yml ubuntu-1.local -m shell \
     -a "sudo kubeadm token create --print-join-command" --become
   
   # Execute join command on new node
   ansible -i inventories/hosts.yml new-ubuntu.local -m shell \
     -a "sudo [join-command-output]" --become
   ```

#### Removing Worker Nodes
```bash
# Drain node
kubectl --kubeconfig ~/.kube/pi-cluster-config drain ubuntu-X.local --ignore-daemonsets

# Remove from cluster
kubectl --kubeconfig ~/.kube/pi-cluster-config delete node ubuntu-X.local

# Clean up node
ansible -i inventories/hosts.yml ubuntu-X.local -m shell \
  -a "sudo kubeadm reset -f" --become
```

## 🚨 Disaster Recovery

### Complete Cluster Recovery
```bash
# 1. Reset all nodes
ansible -i inventories/hosts.yml ubuntu -m shell \
  -a "sudo kubeadm reset -f" --become

# 2. Clean container runtime
ansible -i inventories/hosts.yml ubuntu -m shell \
  -a "sudo systemctl restart containerd" --become

# 3. Redeploy cluster
task playbook -- 6_deploy-kubernetes

# 4. Verify recovery
task playbook -- 7_verify-kubernetes
```

### Partial Recovery Scenarios

#### Master Node Recovery
```bash
# If master node fails, redeploy on same or different hardware
task playbook -- 5_prepare-kubernetes
task playbook -- 6_deploy-kubernetes

# Rejoin workers if needed
# [Use join procedures from scaling section]
```

#### Network Recovery
```bash
# Reset Tailscale connections
ansible -i inventories/hosts.yml ubuntu -m shell \
  -a "sudo tailscale logout" --become

# Redeploy Tailscale
task playbook -- 4_install-tailscale
```

## 📈 Performance Optimization

### Resource Tuning
```yaml
# In Kubernetes manifests - Resource limits
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"
    cpu: "100m"
```

### Storage Optimization
```bash
# Monitor disk usage
ansible -i inventories/hosts.yml ubuntu -m shell -a "df -h /"

# Clean Docker/containerd images
ansible -i inventories/hosts.yml ubuntu -m shell \
  -a "sudo crictl rmi --prune" --become
```

## 🔐 Security Best Practices

### Access Control
- Use dedicated service accounts for automation
- Implement RBAC policies in Kubernetes
- Regular SSH key rotation
- Monitor access logs

### Network Security
- Enable network policies in Kubernetes
- Use Tailscale for secure remote access
- Implement proper firewall rules
- Regular security updates

### Data Protection
- Encrypt etcd data at rest
- Secure backup storage
- Regular security audits
- Vulnerability scanning

## 📚 Related Documentation

- [README.md](README.md) - Quick start and basic usage
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design and components
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Problem resolution
- [API.md](API.md) - Complete command reference
- [docs/kubernetes-deployment.md](docs/kubernetes-deployment.md) - Kubernetes-specific deployment details