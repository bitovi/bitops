#!/usr/bin/env bash

config_file="$1"
key="$2"

RESULT=$(shyaml -q get-value "$key" < "$config_file")
echo "$RESULT"