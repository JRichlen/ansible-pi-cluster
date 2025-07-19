#!/bin/bash
# Alternative network scanner that tries multiple approaches

SUBNET="$1"

if [ -z "$SUBNET" ]; then
  echo "Usage: $0 <subnet>"
  exit 1
fi

echo "Scanning $SUBNET for devices..."
echo "Format: IP Address       Status    Hostname"
echo "=========================================="

# Extract network portion for ping sweep
NETWORK=$(echo "$SUBNET" | cut -d'/' -f1 | cut -d'.' -f1-3)

# Simple ping sweep with parallel execution
for i in {1..254}; do
  (
    IP="$NETWORK.$i"
    if ping -c 1 -W 1000 "$IP" >/dev/null 2>&1; then
      HOSTNAME=$(nslookup "$IP" 2>/dev/null | grep "name =" | awk '{print $NF}' | sed 's/\.$//' || echo "Unknown")
      printf "%-16s %-9s %s\n" "$IP" "UP" "$HOSTNAME"
    fi
  ) &
done

# Wait for all ping processes to complete
wait

echo "=========================================="
echo "Ping sweep complete."
echo ""
echo "For more detailed MAC address information, run with sudo:"
echo "sudo $(dirname "$0")/scan_network.sh $SUBNET"
