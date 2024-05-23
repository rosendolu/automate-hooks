#!/bin/bash

BASE_DIR="$HOME/automate-hooks"
echo "RootDIR: $(pwd)"
echo "BASE_DIR: $BASE_DIR"

# Check Ubuntu system
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

sudo apt-get update -y
sudo apt-get install webhook git -y

if [ -d "$BASE_DIR" ]; then
    echo "Directory \"$BASE_DIR\" exists"
    cd "$BASE_DIR"
    git pull
else
    git clone --branch main https://github.com/rosendolu/automate-hooks.git "$BASE_DIR"
    cd "$BASE_DIR"
fi

echo "Current directory: $(pwd)"

# Setup node
chmod +x "$BASE_DIR/hooks/setup-node.sh"
source "$BASE_DIR/hooks/setup-node.sh"

# Install pm2 and deploy
sudo npm install -g pm2
pm2 start "$BASE_DIR/startup.sh" --name webhook --watch
pm2 startup
pm2 save
pm2 ls
