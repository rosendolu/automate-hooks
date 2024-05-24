#!/bin/bash
set -e

# Change to the directory where the script is located
cd "$(dirname "$0")"
BASE_DIR="$HOME/automate-hooks"
echo "RootDIR: $(pwd)"
echo "BASE_DIR: $BASE_DIR"

# Check and install webhook and git if not already installed
if ! command -v webhook >/dev/null; then
    sudo apt-get update -y
    sudo apt-get install webhook git -y
fi

# Clone or update the repository
if [ -d "$BASE_DIR" ]; then
    echo "Directory \"$BASE_DIR\" exists"
    cd "$BASE_DIR"
    git pull
else
    git clone --branch main https://github.com/rosendolu/automate-hooks.git "$BASE_DIR"
    cd "$BASE_DIR"
fi

echo "Current directory: $(pwd)"

# Load environment variables from .env.local if it exists
if [ -f "$BASE_DIR/.env.local" ]; then
    while IFS='=' read -r key value; do
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        export "$key"="$value"
    done <"$BASE_DIR/.env.local"
    echo "Loaded environment variables:"
fi

# Check if the system is Ubuntu
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

# Replace variables in hook.yaml
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

# Install Node.js and npm if not already installed
if ! command -v node >/dev/null; then
    chmod +x "$BASE_DIR/hooks/setup-node.sh"
    source "$BASE_DIR/hooks/setup-node.sh"
    echo "NPM: $(which npm)"
fi

# Install pm2 if not already installed
if ! command -v pm2 >/dev/null; then
    npm install -g pm2
fi

# Start or restart the webhook application with pm2
if pm2 ls | grep -q "webhook"; then
    echo "Webhook is already running. Restarting..."
    pm2 restart webhook
else
    echo "Webhook is not running. Starting..."
    pm2 start "$BASE_DIR/startup.sh" --name webhook --watch
    pm2 startup
    pm2 save
fi

pm2 ls
