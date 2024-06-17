#!/usr/bin/env bash

# check params
if [ $# -ne 2 ]; then
    echo "Usage: $0 <repository_url> <branch_name>"
    exit 1
fi

repo_url=$1
branch_name=$2

# parse repo
repo_name=$(basename $repo_url .git)

# check if dir exist
if [ -d "$repo_name" ]; then
    echo "Repository '$repo_name' already exists. Fetching latest changes..."
    cd $repo_name
    # force overwrite local
    git fetch origin
    git checkout --force $branch_name
else
    # clone && checkout
    echo "Cloning repository '$repo_name'..."
    git clone $repo_url
    cd $repo_name
    git checkout $branch_name
fi

echo "Done."
