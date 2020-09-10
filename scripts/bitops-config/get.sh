#!/usr/bin/env bash
set -e

config_file="$1"
key="$2"
default="$3"

RESULT=$(shyaml -q get-value "$key" "$default" < "$config_file")
echo "$RESULT"