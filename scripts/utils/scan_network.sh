#!/bin/bash
# Scan a network subnet for devices using nmap

echo "Requires sudo privileges for nmap scans."
sudo -v || { echo "Sudo access required. Exiting."; exit 1; }

# Check if subnet parameter is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <subnet>"
  echo "Example: $0 192.168.1.0/24"
  exit 1
fi

SUBNET="$1"

# Validate subnet format (basic check)
if ! echo "$SUBNET" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$'; then
  echo "Error: Invalid subnet format. Use format like 192.168.1.0/24"
  exit 1
fi

# Check if nmap is available
if ! command -v nmap >/dev/null 2>&1; then
  echo "Error: nmap is not installed. Please install it first:"
  echo "  brew install nmap"
  exit 1
fi

echo "Scanning $SUBNET for devices..."
echo "Format: Hostname/IP        IP Address       MAC Address          Vendor"
echo "=================================================================================="

# Run nmap scan with error handling
NMAP_OUTPUT=$(sudo nmap -n -sn "$SUBNET" 2>&1)
NMAP_EXIT_CODE=$?

# Check for dnet errors and try alternative approach
if echo "$NMAP_OUTPUT" | grep -q "dnet: Failed to open device"; then
  echo "Warning: Network interface access issue detected. Trying alternative scan method..."
  # Try using ping-based discovery instead
  NETWORK=$(echo "$SUBNET" | cut -d'/' -f1 | cut -d'.' -f1-3)
  MASK=$(echo "$SUBNET" | cut -d'/' -f2)
  
  if [ "$MASK" -eq 24 ]; then
    echo "Using ping-based discovery for /24 network..."
    for i in {1..254}; do
      IP="${NETWORK}.${i}"
      # Ping each IP with timeout
      if ping -c 1 -W 1000 "$IP" &>/dev/null; then
        # Try to get hostname
        HOSTNAME=$(nslookup "$IP" 2>/dev/null | grep "name =" | awk '{print $4}' | sed 's/\.$//')
        if [ -z "$HOSTNAME" ]; then
          HOSTNAME="$IP"
        fi
        printf "%-20s %-16s %-20s %s\n" "$HOSTNAME" "$IP" "N/A" "N/A (ping method)"
      fi &
    done
    wait
  else
    echo "Error: Alternative method only supports /24 networks currently"
    exit 1
  fi
elif [ $NMAP_EXIT_CODE -ne 0 ]; then
  echo "Error running nmap:"
  echo "$NMAP_OUTPUT"
  exit 1
else
  # Normal processing
  echo "$NMAP_OUTPUT" | awk '
/Nmap scan report for/ {
  ip = $NF
  if (ip ~ /^\(/) {
    # IP is in parentheses, extract it
    gsub(/[()]/, "", ip)
    hostname = $(NF-1)
  } else {
    # IP is the hostname
    hostname = ip
  }
  nextline = 1
}
/MAC Address:/ {
  if (nextline) {
    mac = $3
    vendor = ""
    # Get vendor info (everything after the MAC address)
    for (i = 4; i <= NF; i++) {
      vendor = vendor $i
      if (i < NF) vendor = vendor " "
    }
    # Clean up vendor string
    gsub(/^\(|\)$/, "", vendor)
    
    printf "%-20s %-16s %-20s %s\n", hostname, ip, mac, vendor
    nextline = 0
  }
}'
fi

echo "=================================================================================="
echo "Scan complete."
