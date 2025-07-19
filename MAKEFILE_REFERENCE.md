# Makefile Commands Reference

## Network Discovery Commands

| Command | Description |
|---------|-------------|
| `make scan` | Basic network scan (ping sweep) |
| `make scan-detailed` | Detailed scan with MAC addresses (requires sudo) |
| `make subnet` | Show detected local subnet only |
| `make nmap SUBNET=X.X.X.X/XX` | Detailed nmap scan of specific subnet |
| `make ping-sweep SUBNET=X.X.X.X/XX` | Ping sweep of specific subnet |
| `make help` | Show network discovery help |

## Ansible Commands

| Command | Description |
|---------|-------------|
| `make ansible-ping` | Test connectivity to all inventory hosts |
| `make ansible-update` | Run the update playbook |
| `make ansible-all` | Run all playbooks |

## Examples

```bash
# Basic network discovery
make scan
make subnet

# Advanced scanning
make nmap SUBNET=192.168.1.0/24
make ping-sweep SUBNET=10.0.0.0/24

# Ansible operations  
make ansible-ping
make ansible-update
```
