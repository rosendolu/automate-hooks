#!/usr/bin/env bash

action=$1

echo "Action: $action"
echo ""
current_time=$(date +"%Y-%m-%d %H:%M:%S")
echo "Current time: $current_time"

WG_CONF_FILE_PATH="/etc/wireguard/wg0.conf"
if [ ! -f "$WG_CONF_FILE_PATH" ]; then
    echo "File \"$WG_CONF_FILE_PATH\" dont exists"
    exit 1
fi
PreviousListenPort=$(grep '^ListenPort' "$WG_CONF_FILE_PATH" | cut -d " " -f 3)
defaultNextPort=$PreviousListenPort

if [[ "${action}" == "set" ]]; then
    defaultNextPort=$((PreviousListenPort + 1))
    sed -i "s/ListenPort.*/ListenPort = $defaultNextPort/g" "$WG_CONF_FILE_PATH"
    # Verify the change
    grep "ListenPort" "$WG_CONF_FILE_PATH"
    ufw delete allow $PreviousListenPort/udp
    ufw allow $defaultNextPort/udp
    wg-quick down "$WG_CONF_FILE_PATH"
    wg-quick up "$WG_CONF_FILE_PATH"
fi

echo "Previous: ${PreviousListenPort}"
echo "Current: ${defaultNextPort}"
