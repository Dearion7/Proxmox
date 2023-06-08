#!/usr/bin/env bash

# Proxmox VE API endpoint
# Base URL https://your-proxmox-ve-host/api2/json 
base_url="https://$URL/api2/json"

# Proxmox VE API authentication credentials
username="$USERNAME"
password="$PASSWORD"
realm="$RALM"

# Validate required arguments
if [[ -z $DISK_SIZE || -z $CORE_COUNT || -z $RAM_SIZE || -z $BRG || -z $Hostname || -z $NET || -z $GATEWAY || -z $DNS_SERVERS ]]; then
  echo "Missing required arguments."
  exit 1
fi

# Create Container Payload
payload=$(cat <<EOF
{
    "hostname": "$Hostname",
    "memory": $RAM_SIZE,
    "cores": $CORE_COUNT,
    "ostemplate": "$TEMPLATE",
    "rootfs": "$DISK_SIZE",
    "net0": "name=$BRG,hwaddr="$MAC",ip=$NET,gw=$GATEWAY",
    "nameserver": "$DNS_SERVERS",
}
EOF
)

# Function to get template ID based on OS version and distribution
function get_template_id() {
  os="$OS"
  version="$VERSION"

  # Get the templates available
  response=$(curl -s -k -H "Authorization: PVEAPIToken=$ticket" "$base_url/cluster/aplinfo")

  # Parse the response to find the template ID matching the specified OS version and distribution
  template_id=$(echo "$response" | jq -r --arg os "$os" --arg version "$version" '.data[] | select(.os==$os and .version==$version) | .template')
}