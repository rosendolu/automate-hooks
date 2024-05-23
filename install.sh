#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")
echo "RootDir:$SCRIPT_DIR"

# check Ubuntu system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        echo "This script can only run on Ubuntu."
        exit 1
    fi
else
    echo "/etc/os-release file not found. Unable to determine the operating system."
    exit 1
fi

sudo apt-get install webhook

# setup node
./hooks/setup-node.sh

# pm2 deploy
npm i -g pm2
pm2 start ./startup.sh --name webhook --watch
pm2 startup
pm2 save
