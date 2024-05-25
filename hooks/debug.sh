#!/usr/bin/env bash

# params
query_str=$1
header_str=$2
payload_str=$3

# print params
echo "Query String:$query_str"
echo ""
echo "Header String:$header_str"
echo ""
echo "Playload String:$payload_str"
echo ""
current_time=$(date +"%Y-%m-%d %H:%M:%S")
echo "Current time: $current_time"
echo ''
