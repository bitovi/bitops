#!/usr/bin/env bash

export BITOPS_DIR="/opt/bitops"
export SCRIPTS_DIR="$BITOPS_DIR/scripts"

set -e

value="$1"
key_type="$2"
cli_flag="$3"
terminal="$4"

if [ -n "$DEBUG" ]; then
    echo "convert.sh"
    echo "  value: $value"
    echo "  key_type: $key_type"
    echo "  cli_flag: $cli_flag"
    echo "  terminal: $terminal"
fi

converter_script="$SCRIPTS_DIR/bitops-config/converters/${key_type}.sh"

if [ -z "$cli_flag" ] || [ -z "$value" ]; then
  echo ""
  exit 0
fi

if [ -f "$converter_script" ]; then
    OUTPUT="$(bash "$converter_script" "$value" "$cli_flag" "$terminal" || exit)"
else
    OUTPUT="$(bash "$SCRIPTS_DIR/bitops-config/converters/string.sh" "$value" "$cli_flag" "$terminal" || exit)"
fi

echo "$OUTPUT"

