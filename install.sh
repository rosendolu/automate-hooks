#!/bin/bash
set -e
cd "$(dirname "$0")"
BASE_DIR="$HOME/automate-hooks"
echo "RootDIR: $(pwd)"
echo "BASE_DIR: $BASE_DIR"

if [ -d "$BASE_DIR" ]; then
    echo "Directory \"$BASE_DIR\" exists"
    cd "$BASE_DIR"
    git pull
else
    git clone --branch main https://github.com/rosendolu/automate-hooks.git "$BASE_DIR"
    cd "$BASE_DIR"
fi

echo "Current directory: $(pwd)"

if [ -f "$BASE_DIR/.env.local" ]; then
    while IFS='=' read -r key value; do
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        if [ -z "$value" ]; then
            value=""
        fi
        export "$key"="$value"
    done <"$BASE_DIR/.env.local"
    echo "Loaded environment variables:"
fi

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

HOOKS_CONF="$BASE_DIR/hook.yaml"
VARIABLES=("SECRET" "BASE_DIR")
for var in "${VARIABLES[@]}"; do
    value="${!var}"
    if [ -z "$value" ]; then
        echo "Warning: $var is not set"
        continue
    fi
    sed -i "s|{{${var}}}|${value}|g" "$HOOKS_CONF"
done

# Setup node
chmod +x "$BASE_DIR/hooks/setup-node.sh"
source "$BASE_DIR/hooks/setup-node.sh"

# Install pm2 and deploy
which npm
npm install -g pm2
pm2 start "$BASE_DIR/startup.sh" --name webhook --watch
pm2 startup
pm2 save
pm2 ls
