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

if [[ "${action}" == "config" ]]; then

    # target WireGuard config file path
    WG_CONF="/etc/wireguard/wg0.conf"

    # check WireGuard config file exists
    if [[ ! -f "$WG_CONF" ]]; then
        echo "WireGuard config file not found: $WG_CONF"
        exit 1
    fi

    # tarverse WireGuard config file ，find all peer name
    while IFS= read -r line; do
        if [[ "$line" =~ ^#\ BEGIN_PEER\ (.*)$ ]]; then
            peer_name="${BASH_REMATCH[1]}"
            peer_conf="$HOME/$peer_name.conf"

            echo "Found peer: $peer_name"

            # check coresponding conf file
            if [[ -f "$peer_conf" ]]; then
                echo "Reading config for $peer_name from $peer_conf:"
                cat "$peer_conf"
                echo ""
            else
                echo "Config file not found for $peer_name: $peer_conf"
            fi
        fi
    done <"$WG_CONF"

fi

echo "Previous: ${PreviousListenPort}"
echo "Current: ${defaultNextPort}"
