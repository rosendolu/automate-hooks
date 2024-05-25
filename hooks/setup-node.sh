#!/usr/bin/env bash

###########################
# ubuntu
###########################

# source
check_and_source_file() {
    local file="$1" # input params
    # if file exitst
    if [[ -f "$file" ]]; then
        echo "$file exists."
        source "$file"
    else
        echo "$file does not exist."
    fi
}

# uninstall mode
uninstall=false
for arg in "$@"; do
    if [[ "$arg" == "--uninstall" ]]; then
        uninstall=true
    fi
done

echo "uninstall: $uninstall"

if [[ "$uninstall" == true ]]; then
    rm -rf "$HOME/.nvm" || true
    exit 0
fi

##########################################################
# setup node
# https://github.com/nvm-sh/nvm
##########################################################

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# check_and_source_file "$HOME/.bashrc"
# check_and_source_file "$HOME/.zshrc"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

nvm install node # "node" is an alias for the latest version
nvm use node
nvm current >"$HOME/.nvmrc"
