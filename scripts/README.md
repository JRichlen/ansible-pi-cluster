# Network Discovery Scripts

This directory contains network discovery tools for finding devices on your local network.

## Quick Start

From the project root directory:

```bash
# Basic network scan
make scan

# Detailed scan with MAC addresses (requires sudo)
make scan-detailed

# Just discover the subnet
make subnet

# Scan specific subnet
make nmap SUBNET=192.168.1.0/24
make ping-sweep SUBNET=192.168.1.0/24
```

## Directory Structure

```
scripts/
├── network-discovery        # Main network discovery command
├── README.md               # This file
└── utils/                  # Core utility scripts
    ├── discover_subnet.sh     # Subnet detection for macOS
    ├── scan_network.sh        # nmap-based detailed scanning
    └── simple_scan.sh         # ping-based basic scanning
```

## Scripts Overview

### `network-discovery` (Main Command)
The primary interface for all network discovery operations:

**Commands:**
- `scan` / `find` - Auto-discover subnet and scan for devices
- `subnet` - Show detected local subnet
- `nmap <subnet>` - Detailed nmap scan of specific subnet
- `ping <subnet>` - Simple ping sweep of specific subnet  
- `help` - Show usage information

**Examples:**
```bash
./network-discovery scan                    # Auto-scan local network
sudo ./network-discovery scan               # Detailed scan with MAC info
./network-discovery subnet                  # Show subnet only
sudo ./network-discovery nmap 192.168.1.0/24  # Scan specific subnet
./network-discovery ping 192.168.1.0/24     # Ping sweep specific subnet
```

### 2. `utils/discover_subnet.sh`
Automatically discovers your local network subnet on macOS by:
- Finding the default network interface
- Extracting IP address and netmask
- Converting to CIDR notation (e.g., 192.168.1.0/24)

**Direct Usage:**
```bash
cd scripts/utils
./discover_subnet.sh
# Output: 192.168.50.0/24
```

### 3. `utils/scan_network.sh`
Performs detailed network scanning using nmap (requires sudo):
- Shows device hostnames, IP addresses, MAC addresses, and vendors
- Requires nmap to be installed (`brew install nmap`)
- Needs sudo privileges for MAC address detection

**Direct Usage:**
```bash
cd scripts/utils
sudo ./scan_network.sh 192.168.1.0/24
```

### 4. `utils/simple_scan.sh`
Performs basic network discovery using ping:
- Works without sudo privileges
- Shows IP addresses and hostnames
- Faster but less detailed than nmap scan
- Runs ping sweeps in parallel for speed

**Direct Usage:**
```bash
cd scripts/utils
./simple_scan.sh 192.168.1.0/24
```

## Features

- **Dynamic Subnet Discovery**: No need to manually configure network ranges
- **Privilege Detection**: Automatically chooses the best scanning method available
- **Modular Design**: Each script has a single responsibility
- **Error Handling**: Graceful fallbacks and informative error messages
- **macOS Optimized**: Uses macOS-specific network commands for reliability

## Requirements

- macOS (tested with the current network stack)
- Bash shell
- For detailed scans: `nmap` (`brew install nmap`)
- For detailed scans: sudo privileges

## Example Output

```
Discovering local subnet...
Detected subnet: 192.168.50.0/24

Using ping sweep method (no MAC addresses)...
Format: IP Address       Status    Hostname
==========================================
192.168.50.1     UP        GT-AC5300-AA60
192.168.50.121   UP        Jordans-MBP
192.168.50.195   UP        homeassistant
==========================================
```

## Ansible Integration

These scripts can be used to:
1. Discover Pi devices on your network
2. Update your `inventories/hosts.ini` file with discovered IPs
3. Validate connectivity before running playbooks
