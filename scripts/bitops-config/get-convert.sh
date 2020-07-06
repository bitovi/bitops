#!/usr/bin/env bash

export BITOPS_DIR="/opt/bitops"
export SCRIPTS_DIR="$BITOPS_DIR/scripts"


config_file="$1"
key="$2"
key_type="$3"
cli_flag="$4"
terminal="$5"

if [ -n "$DEBUG" ]; then
  echo "get-convert.sh"
  echo "  config_file: $config_file"
  echo "  key: $key"
  echo "  key_type: $key_type"
  echo "  cli_flag: $cli_flag"
  echo "  terminal: $terminal"
fi

v="$(bash "$SCRIPTS_DIR/bitops-config/get.sh" "$config_file" "$key")"
OUTPUT="$(bash "$SCRIPTS_DIR/bitops-config/convert.sh" "$v" "$key_type" "$cli_flag" "$terminal")"

echo "$OUTPUT"
