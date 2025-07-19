# Ansible Pi Cluster

Infrastructure automation for Raspberry Pi clusters using Ansible.

## Project Structure

```
ansible-pi-cluster/
├── scripts/                  # All network discovery tools
│   ├── network-discovery     #   Main network discovery command
│   ├── README.md            #   Detailed documentation
│   └── utils/               #   Core utility scripts
│       ├── discover_subnet.sh  #     Dynamic subnet detection
│       ├── scan_network.sh     #     nmap-based scanning
│       └── simple_scan.sh      #     ping-based scanning
├── inventories/             # Ansible inventory files
│   └── hosts.ini           #   Host definitions
├── playbooks/              # Ansible playbooks
├── roles/                  # Ansible roles
├── Makefile               # Build and utility commands
└── README.md              # This file
```

## Quick Start

### 1. Network Discovery

Find devices on your local network:

```bash
# Using make commands (recommended)
make scan                     # Basic network scan
make scan-detailed            # Detailed scan with MAC addresses (requires sudo)
make subnet                   # Show detected subnet only
make help                     # Show network discovery help

# Using the script directly
./scripts/network-discovery scan
./scripts/network-discovery subnet
./scripts/network-discovery help
```

### 2. Advanced Network Commands

```bash
# Scan specific subnet with nmap
make nmap SUBNET=192.168.1.0/24

# Simple ping sweep of specific subnet  
make ping-sweep SUBNET=192.168.1.0/24

# Or use the script directly
sudo ./scripts/network-discovery nmap 192.168.1.0/24
./scripts/network-discovery ping 192.168.1.0/24
```

### 3. Ansible Commands

```bash
make ansible-ping            # Test connectivity to all hosts
make ansible-update          # Run update playbook
```

### 2. Manual Network Scanning

For more control, use the scripts directly:

```bash
# Change to scripts directory
cd scripts

# Run main scanning script
./find_pis.sh

# Or with sudo for MAC addresses
sudo ./find_pis.sh
```

### 3. Utility Scripts

Access individual utilities:

```bash
# Discover local subnet
./network-discovery subnet

# Scan specific subnet with nmap
sudo ./network-discovery nmap 192.168.1.0/24

# Simple ping sweep
./network-discovery ping 192.168.1.0/24
```

## Features

- **Dynamic Network Discovery**: Automatically detects your local network subnet
- **Multiple Scanning Methods**: 
  - nmap (detailed, requires sudo) - shows MAC addresses and vendors
  - ping sweep (basic, no sudo) - shows IP addresses and hostnames
- **Modular Design**: Separate utilities for different network operations
- **macOS Optimized**: Uses macOS-specific networking commands
- **User-Friendly Interface**: Clear output and helpful error messages

## Requirements

- macOS (current networking stack)
- Bash shell
- Optional: `nmap` for detailed scans (`brew install nmap`)
- Optional: `sudo` privileges for MAC address detection

## Example Output

```
$ ./network-discovery scan

Discovering local subnet...
Detected subnet: 192.168.50.0/24

Using ping sweep method (no MAC addresses)...
Format: IP Address       Status    Hostname
==========================================
192.168.50.1     UP        GT-AC5300-AA60
192.168.50.121   UP        Jordans-MBP
192.168.50.195   UP        homeassistant
==========================================
Ping sweep complete.
```

## Next Steps

1. **Update Inventory**: Use discovered IPs to update `inventories/hosts.ini`
2. **Create Playbooks**: Add your automation playbooks to `playbooks/`
3. **Define Roles**: Create reusable roles in `roles/`

## Documentation

- [Network Discovery Scripts](scripts/README.md) - Detailed documentation for all network discovery tools
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html) - Official Ansible documentation
