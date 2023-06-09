#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/Dearion7/Proxmox/main/build.func)

function header_info {
clear
cat <<"EOF"
   __  __      __  _                   __ __                     
  / / / /___  / /_(_)___ ___  ___     / //_/_  ______ ___  ____ _
 / / / / __ \/ __/ / __  __ \/ _ \   / ,< / / / / __  __ \/ __  /
/ /_/ / /_/ / /_/ / / / / / /  __/  / /| / /_/ / / / / / / /_/ / 
\____/ .___/\__/_/_/ /_/ /_/\___/  /_/ |_\__,_/_/ /_/ /_/\__,_/  
    /_/                                                          
 
EOF
}
header_info
echo -e "Loading..."

# variables
APP="Uptime Kuma"
var_disk="4"
var_cpu="1"
var_ram="1024"
var_os="debian"
var_version="11"
var_brg="vmbr0"
var_disable_ipv6="yes"
var_verb="no"

variables
color
catch_errors

function basic_settings() {
  CT_TYPE="1"
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="$var_brg"
  DISABLEIP6="$var_disable_ipv6"
  VERB="$var_verb"
}

function echo_settings() {
  echo_settings_vars
}

function update_script() {
header_info
if [[ ! -d /opt/uptime-kuma ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
LATEST=$(curl -sL https://api.github.com/repos/louislam/uptime-kuma/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
msg_info "Stopping ${APP}"
sudo systemctl stop uptime-kuma &>/dev/null
msg_ok "Stopped ${APP}"

cd /opt/uptime-kuma

msg_info "Pulling ${APP} ${LATEST}"
git fetch --all &>/dev/null
git checkout $LATEST --force &>/dev/null
msg_ok "Pulled ${APP} ${LATEST}"

msg_info "Updating ${APP} to ${LATEST}"
npm install --production &>/dev/null
npm run download-dist &>/dev/null
msg_ok "Updated ${APP}"

msg_info "Starting ${APP}"
sudo systemctl start uptime-kuma &>/dev/null
msg_ok "Started ${APP}"
msg_ok "Updated Successfully"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:3001${CL} \n"