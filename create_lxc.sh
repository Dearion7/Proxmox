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
    "ostemplate": "$template",
    "rootfs": "$DISK_SIZE",
    "net0": "name=$BRG,hwaddr=$MAC,ip=$NET,gw=$GATEWAY",
    "nameserver": "$DNS_SERVERS",
}
EOF
)

# This sets error handling options and defines the error_handler function to handle errors
set -Eeuo pipefail
trap 'error_handler $LINENO "$BASH_COMMAND"' ERR

# This function handles errors
function error_handler() {
  local exit_code="$?"
  local line_number="$1"
  local command="$2"
  local error_message="${RD}[ERROR]${CL} in line ${RD}$line_number${CL}: exit code ${RD}$exit_code${CL}: while executing command ${YW}$command${CL}"
  echo -e "\n$error_message\n"
}

# This function prints an informational message
function msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
}

# This function prints a success message
function msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

# This function prints an error message
function msg_error() {
  local msg="$1"
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}


# Function to get template ID based on OS version and distribution
function get_template_id() {
  local os="$OS"
  local version="$VERSION"

  # Get the templates available
  response=$(curl -s -k -H "Authorization: PVEAPIToken=$ticket" "$base_url/cluster/aplinfo")

  # Parse the response to find the template ID matching the specified OS version and distribution
  template_id=$(echo "$response" | jq -r --arg os "$os" --arg version "$version" '.data[] | select(.os==$os and .version==$version) | .template')

  echo "$template_id"
}

# Authenticate with the ProxMox VE API and return a ticket
response=$(curl -s -k -d "username=$username&password=$password&realm=$realm" "$base_url/access/ticket")
ticket=$(echo "$response" | jq -r '.data.ticket')

# Get template ID from OS and Version
template=$(get_template_id)

if [[ -n "$template_id" ]]; then
  msg_info "Template ID: ${BL}$template_id${CL}"
else
  msg_error "No matching template found for OS version $version and distribution $os."
fi

# Create a container
msg_info "Creating LXC Container"
response=$(curl -s -k -X POST -H "Authorization: PVEAPIToken=$ticket" -d "$payload" "$base_url/nodes/pve/lxc?newid=$CTID")

# Check the response status
if [[ $(echo "$response" | jq -r '.status') == "OK" ]]; then
  mesg_ok "LXC Container ${BL}$APP${CL} ${GN}created successfully."
else
  echo "Error creating the container:"
  echo "$response" | jq -r '.errors[]'
fi

# Revoke the ticket (optional)
curl -s -k -X POST -H "Authorization: PVEAPIToken=$ticket" "$base_url/access/ticket/$ticket"