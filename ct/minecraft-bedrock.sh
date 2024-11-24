#!/usr/bin/env bash
export GITHUB_USER="schmidtandreas"
source <(curl -s https://raw.githubusercontent.com/${GITHUB_USER:-"tteck"}/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
    __  ____            ______           ______     ____           __                __  
   /  |/  (_)___  ___  / ____/________ _/ __/ /_   / __ )___  ____/ /________  _____/ /__
  / /|_/ / / __ \/ _ \/ /   / ___/ __ `/ /_/ __/  / __  / _ \/ __  / ___/ __ \/ ___/ //_/
 / /  / / / / / /  __/ /___/ /  / /_/ / __/ /_   / /_/ /  __/ /_/ / /  / /_/ / /__/ ,<   
/_/  /_/_/_/ /_/\___/\____/_/   \__,_/_/  \__/  /_____/\___/\__,_/_/   \____/\___/_/|_|  
                                                                                         
EOF
}
header_info
echo -e "Loading..."
APP="MineCraft-Bedrock"
var_disk="2"
var_cpu="4"
var_ram="2048"
var_os="ubuntu"
var_version="22.04"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function get_mc_br_url() {
  download_url="https://www.minecraft.net/de-de/download/server/bedrock"
  get_header="user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
  curl -s -H "${get_header}" "${download_url}" | grep "serverBedrockLinux" | sed -e "s|.*href=\"\(.*\.zip\)\".*|\1|"
}

function get_mc_br_version() {
  get_mc_br_url | sed -e "s|.*bedrock-server-\(.*\)\.zip|\1|"
}

MCBR_SERVER_DIRECTORY="/minecraft"
MCBR_SERVER_VERSION_FILE="${MCBR_SERVER_DIRECTORY}/server_version.txt"
MCBR_VERSION="$(get_mc_br_version)"
MCBR_SERVER_ARCHIVE="bedrock-server-${MCBR_VERSION}.zip"

function get_local_mc_br_versoin() {
  version_file="${MCBR_SERVER_VERSION_FILE}"
  [ "${version_file}" ] && cat "${MCBR_SERVER_VERSION_FILE}" || echo ""
}

function update_script() {
  header_info
  if [[ ! -f /minecraft/bedrock_server ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  remote_version="${MCBR_VERSION}"
  local_version="$(get_local_mc_br_versoin)"
  if [[ "${remote_version}" != "${local_version}" ]]; then
    msg_info "Stopping ${APP}"
    systemctl stop minecraft
    msg_ok "Stopped ${APP}"

    msg_info "Updating ${APP} LXC"
    curl -s -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$(get_mc_br_url)" -o "${MCBR_SERVER_ARCHIVE}"
    unzip -o -d "${MCBR_SERVER_DIRECTORY}" "${MCBR_SERVER_ARCHIVE}"
    sed -i "s|level-name=.*|level-name=Schmidty Land|" "${MCBR_SERVER_DIRECTORY}/server.properties"
    get_mc_br_version >"${MCBR_SERVER_VERSION_FILE}"
    msg_ok "Updated ${APP} LXC"

    msg_info "Starting ${APP}"
    systemctl start minecraft
    msg_ok "Started ${APP}"
  else
    msg_ok "${APP} is uptodate"
  fi
  msg_ok "Updated Successfully"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
