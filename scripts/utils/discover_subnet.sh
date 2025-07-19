#!/bin/bash
# Discover the local subnet dynamically (macOS)

# Get the default network interface
DEFAULT_IFACE=$(route get default 2>/dev/null | awk '/interface: /{print $2}' | head -n1)
if [ -z "$DEFAULT_IFACE" ]; then
  DEFAULT_IFACE=$(netstat -rn | awk '/default/{print $6; exit}')
fi

if [ -z "$DEFAULT_IFACE" ]; then
  echo "Error: Could not determine default network interface" >&2
  exit 1
fi

# Get IP address and netmask for the interface
IP_ADDR=$(ipconfig getifaddr "$DEFAULT_IFACE" 2>/dev/null)
NETMASK=$(ipconfig getoption "$DEFAULT_IFACE" subnet_mask 2>/dev/null)

# Fallback to ifconfig if ipconfig doesn't work
if [ -z "$IP_ADDR" ] || [ -z "$NETMASK" ]; then
  IFCONFIG_OUTPUT=$(ifconfig "$DEFAULT_IFACE" 2>/dev/null)
  if [ -n "$IFCONFIG_OUTPUT" ]; then
    IP_ADDR=$(echo "$IFCONFIG_OUTPUT" | awk '/inet /{print $2}' | head -n1)
    NETMASK=$(echo "$IFCONFIG_OUTPUT" | awk '/inet /{print $4}' | head -n1)
    # Convert hex netmask to decimal if needed
    if [[ "$NETMASK" =~ ^0x ]]; then
      hex_mask=${NETMASK#0x}
      m1=$(printf "%d" "0x${hex_mask:0:2}")
      m2=$(printf "%d" "0x${hex_mask:2:2}")  
      m3=$(printf "%d" "0x${hex_mask:4:2}")
      m4=$(printf "%d" "0x${hex_mask:6:2}")
      NETMASK="$m1.$m2.$m3.$m4"
    fi
  fi
fi

if [ -z "$IP_ADDR" ] || [ -z "$NETMASK" ]; then
  echo "Error: Could not determine IP address or netmask for interface $DEFAULT_IFACE" >&2
  exit 1
fi

# Convert netmask to CIDR notation
netmask_to_cidr() {
  local netmask="$1"
  IFS=. read -r i1 i2 i3 i4 <<< "$netmask"
  local mask_int=$((i1 * 256**3 + i2 * 256**2 + i3 * 256 + i4))
  local cidr=0
  local temp_mask=$mask_int
  
  while [ $temp_mask -ne 0 ]; do
    if [ $((temp_mask & 1)) -eq 1 ]; then
      cidr=$((cidr + 1))
    fi
    temp_mask=$((temp_mask >> 1))
  done
  
  # Count leading 1s more accurately
  cidr=0
  for byte in $i1 $i2 $i3 $i4; do
    case $byte in
      255) cidr=$((cidr + 8)) ;;
      254) cidr=$((cidr + 7)) ;;
      252) cidr=$((cidr + 6)) ;;
      248) cidr=$((cidr + 5)) ;;
      240) cidr=$((cidr + 4)) ;;
      224) cidr=$((cidr + 3)) ;;
      192) cidr=$((cidr + 2)) ;;
      128) cidr=$((cidr + 1)) ;;
      0) ;;
      *) echo "Error: Invalid netmask $netmask" >&2; exit 1 ;;
    esac
    [ $byte -ne 255 ] && break
  done
  
  echo $cidr
}

# Calculate network address
IFS=. read -r o1 o2 o3 o4 <<< "$IP_ADDR"
IFS=. read -r m1 m2 m3 m4 <<< "$NETMASK"
NET_ADDR="$((o1 & m1)).$((o2 & m2)).$((o3 & m3)).$((o4 & m4))"

# Get CIDR
CIDR=$(netmask_to_cidr "$NETMASK")
SUBNET="$NET_ADDR/$CIDR"

# Output the subnet
echo "$SUBNET"
