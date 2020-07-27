#!/usr/bin/env bash

# set -e

config_file="$1"
key="$2"

RESULT=$(shyaml -q get-value "$key" < "$config_file")
echo "$RESULT"