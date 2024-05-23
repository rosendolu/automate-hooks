#!/usr/bin/env bash

action=$1

echo "Action: $action"
echo ""
current_time=$(date +"%Y-%m-%d %H:%M:%S")
echo "Current time: $current_time"

PreviousListenPort=$(grep '^ListenPort' /etc/wireguard/wg0.conf | cut -d " " -f 3)
defaultNextPort=$PreviousListenPort

if [[ "${action}" == "set" ]]; then
    defaultNextPort=$((PreviousListenPort + 1))
    sed -i "s/ListenPort.*/ListenPort = $defaultNextPort/g" /etc/wireguard/wg0.conf
    # Verify the change
    grep "ListenPort" /etc/wireguard/wg0.conf
    ufw delete allow $PreviousListenPort/udp
    ufw allow $defaultNextPort/udp
    wg-quick down /etc/wireguard/wg0.conf
    wg-quick up /etc/wireguard/wg0.conf
fi

echo "Previous: ${PreviousListenPort}"
echo "Current: ${defaultNextPort}"
