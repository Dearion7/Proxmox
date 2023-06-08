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

variables
color
catch_errors

start
build_container

msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL.
         ${BL}http://${IP}:3000${CL} \n"