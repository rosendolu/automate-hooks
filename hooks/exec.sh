#!/usr/bin/env bash

# params
combined_cmd=$1
echo "Exec:$combined_cmd"
result=$(eval "$combined_cmd")
echo "Result:\n $result"
