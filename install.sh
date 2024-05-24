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

# Install Node.js and npm if not already installed
if ! command -v node >/dev/null; then
    chmod +x "$BASE_DIR/hooks/setup-node.sh"
    source "$BASE_DIR/hooks/setup-node.sh"
fi

echo "NODE -v: $(node -v)"
echo "NPM -v: $(npm -v)"

# Install pm2 if not already installed
if ! command -v pm2 >/dev/null; then
    npm install -g pm2
else
    pm2 update
fi
pm2 stop webhook || true
pm2 save --force
pm2 ls

# Clone or update the repository
if [ -d "$BASE_DIR" ]; then
    echo "Directory \"$BASE_DIR\" exists"
    cd "$BASE_DIR"
    git fetch origin
    git reset --hard origin/main
else
    git clone --branch main https://github.com/rosendolu/automate-hooks.git "$BASE_DIR"
    cd "$BASE_DIR"
fi

echo "Current directory: $(pwd)"

# Load environment variables from .env.* files in the current directory
for env_file in "$BASE_DIR"/.env.*; do
    if [ -f "$env_file" ]; then
        while IFS='=' read -r key value; do
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs)
            echo "$key=$value"
            export "$key"="$value"
        done <"$env_file"
        echo "Loaded environment variables from $env_file"
    fi
done

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
VARIABLES=("SECRET" "BASE_DIR" "TOKEN")
for var in "${VARIABLES[@]}"; do
    value="${!var}"
    if [ -z "$value" ]; then
        echo "Warning: $var is not set"
        continue
    fi
    sed -i "s|{{${var}}}|${value}|g" "$HOOKS_CONF"
done

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
