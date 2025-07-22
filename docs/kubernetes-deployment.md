# Kubernetes Deployment for Raspberry Pi Cluster

This guide covers deploying Kubernetes to your Raspberry Pi cluster using the existing ansible-pi-cluster project infrastructure.

## 🎯 Overview

The Kubernetes deployment is fully integrated with your existing project workflow and includes:
- **Automated cluster setup** with control plane and worker nodes
- **Container runtime configuration** (containerd optimized for ARM64)
- **Advanced CNI networking** with Cilium for high-performance eBPF-based networking
- **Smart authentication** leveraging your existing SSH key infrastructure
- **Verification and testing** to ensure cluster health

## 📋 Prerequisites

Before deploying Kubernetes, ensure you have completed the foundational steps:

1. **SSH Key Deployment** (Required)
   ```bash
   task playbook -- 1_deploy-ssh-key
   ```

2. **System Updates** (Recommended)
   ```bash
   task playbook -- 3_update-packages
   ```

3. **Required Collections** (Auto-installed)
   ```bash
   task install  # Installs kubernetes.core and other dependencies
   ```

## 🚀 Deployment Process

### Step 1: Prepare Kubernetes Environment
```bash
task playbook -- 5_prepare-kubernetes
```

This preparation playbook will:
- ✅ Configure all nodes with container runtime (containerd)
- ✅ Install Kubernetes packages (kubelet, kubeadm, kubectl)
- ✅ Configure system prerequisites and dependencies
- ✅ Optimize settings for ARM64 Raspberry Pi hardware

### Step 2: Deploy Kubernetes Cluster
```bash
task playbook -- 6_deploy-kubernetes
```

This deployment playbook will:
- ✅ Initialize control plane on ubuntu-1
- ✅ Install Cilium CNI with eBPF networking and kube-proxy replacement
- ✅ Join worker nodes to the cluster
- ✅ Copy kubeconfig to your local machine

**Expected Runtime:** 15-25 minutes depending on network speed

### Step 3: Verify Cluster Health (Optional but Recommended)
```bash
task playbook -- 7_verify-kubernetes
```

This verification playbook will:
- ✅ Check all nodes are Ready
- ✅ Verify system pods are running
- ✅ Deploy test workloads across nodes
- ✅ Test pod-to-pod networking
- ✅ Validate DNS resolution

## 🔧 Configuration Details

### Cluster Topology
- **Control Plane:** ubuntu-1 (master node)
- **Worker Nodes:** ubuntu-2, ubuntu-3, ubuntu-4
- **Pod Network:** 10.0.0.0/8 (Cilium CNI)
- **Service Network:** 10.96.0.0/12 (default)

### Key Components Installed
- **Container Runtime:** containerd (optimized for ARM64)
- **Kubernetes Version:** 1.29.x (latest stable)
- **CNI Plugin:** Cilium (eBPF-based, ARM64 compatible)
- **Control Plane:** kubeadm-bootstrapped with systemd cgroup driver
- **Network Features:** kube-proxy replacement, native routing, IPv4 masquerading

### ARM64 Optimizations
- **Systemd cgroup driver** for better resource management
- **ARM64-specific container runtime** configuration
- **Memory-optimized kubelet settings** for Raspberry Pi hardware
- **Graceful node shutdown** features enabled
- **eBPF networking** with Cilium for enhanced performance and observability
- **Native routing mode** for optimal network performance

## 📁 Generated Files

After successful deployment:

### Local Machine
```
~/.kube/pi-cluster-config    # Kubeconfig for your cluster
```

### Control Plane Node (ubuntu-1)
```
/home/{user}/.kube/config    # Admin kubeconfig
/etc/kubernetes/             # Cluster certificates and configs
```

## 🔍 Usage Examples

### Connect to Your Cluster
```bash
# Set kubeconfig environment variable
export KUBECONFIG=~/.kube/pi-cluster-config

# Verify cluster access
kubectl get nodes -o wide
kubectl get pods --all-namespaces
```

### Deploy a Test Application
```bash
# Create a simple deployment
kubectl create deployment nginx --image=nginx:alpine --replicas=3

# Expose the deployment
kubectl expose deployment nginx --port=80 --type=NodePort

# Check deployment status
kubectl get pods -o wide
```

### Monitor Cluster Resources
```bash
# View node resource usage
kubectl top nodes

# Check system pods
kubectl get pods -n kube-system

# View cluster events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## 🔧 Troubleshooting

### Common Issues

#### Nodes Not Ready
```bash
# Check kubelet status on affected node
ssh ubuntu-X.local "sudo systemctl status kubelet"

# Check node conditions
kubectl describe node ubuntu-X
```

#### Pod Networking Issues
```bash
# Check Cilium status
kubectl get pods -n kube-system -l k8s-app=cilium

# Verify Cilium connectivity
cilium status

# Check Cilium agent logs
kubectl logs -n kube-system -l k8s-app=cilium --tail=50
```

#### Join Token Expired
```bash
# Generate new token on control plane
ssh ubuntu-1.local "kubeadm token create --print-join-command"

# Re-run the join command on worker nodes
```

### Manual Recovery

If deployment fails partway through:

```bash
# Reset a node to clean state
ssh ubuntu-X.local "sudo kubeadm reset --force"

# Clean up CNI configuration
ssh ubuntu-X.local "sudo rm -rf /etc/cni/net.d/*"

# Clean up Cilium state (if needed)
ssh ubuntu-X.local "sudo rm -rf /var/lib/cilium"

# Re-run deployment
task playbook -- 5_deploy-kubernetes
```

## 📊 Performance Expectations

### Resource Usage (Per Node)
- **Control Plane:** ~800MB RAM, ~0.5 CPU cores
- **Worker Nodes:** ~400MB RAM, ~0.2 CPU cores
- **System Pods:** ~200MB RAM total across cluster

### Network Performance
- **Pod-to-Pod:** ~900 Mbps (Gigabit Ethernet)
- **Service Discovery:** <5ms latency
- **Internet Egress:** Limited by upstream bandwidth

## 🎯 Next Steps

After successful deployment, consider:

1. **Install Kubernetes Dashboard**
2. **Set up Ingress Controller** (NGINX, Traefik)
3. **Configure Persistent Storage** (NFS, local storage)
4. **Deploy monitoring** (Prometheus, Grafana)
5. **Set up GitOps** (ArgoCD, Flux)
6. **Explore Cilium features** (Hubble for observability, network policies, service mesh)

## 🚀 Cilium Advantages

Your cluster benefits from Cilium's advanced features:
- **eBPF-based networking** for superior performance
- **kube-proxy replacement** reducing resource overhead
- **Built-in observability** with Hubble for network visibility
- **Advanced network policies** for microsegmentation
- **Service mesh capabilities** without additional sidecars
- **Load balancing** and service discovery optimization

## 🔐 Security Notes

- **RBAC** is enabled by default
- **Network policies** can be added for microsegmentation
- **Pod Security Standards** should be configured for production workloads
- **Regular updates** via your existing update playbook

## 📚 Integration with Existing Workflow

The Kubernetes playbooks integrate seamlessly with your existing project:
- **Uses same inventory** and SSH key infrastructure
- **Follows same numbering convention** (5_deploy-kubernetes.yml)
- **Leverages task runner** for consistent UX
- **Respects authentication patterns** established in earlier playbooks
- **Includes proper error handling** and user feedback

Run `task list` to see all available playbooks including the new Kubernetes options.
