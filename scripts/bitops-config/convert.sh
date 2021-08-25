#!/usr/bin/env bash
set -e

if [ -z "$BITOPS_DIR" ];then
  echo "Using default BitOps Directory"
  export BITOPS_DIR="/opt/bitops"
fi

if [ -z "$SCRIPTS_DIR" ];then
  echo "Using default BitOps Script Directory"
  export SCRIPTS_DIR="/opt/bitops"
fi

value="$1"
key_type="$2"
cli_flag="$3"
terminal="$4"
schema_path="$5"
schema_value_path="$6"

if [ -n "$DEBUG" ]; then
    echo "convert.sh"
    echo "  value: $value"
    echo "  key_type: $key_type"
    echo "  cli_flag: $cli_flag"
    echo "  terminal: $terminal"
    echo "  schema_path: $schema_path"
fi

converter_script="$SCRIPTS_DIR/bitops-config/converters/${key_type}.sh"

if [ -z "$cli_flag" ] || [ -z "$value" ]; then
  echo ""
  exit 0
fi

if [ -f "$converter_script" ]; then
  if [ "$key_type" == "selection-list" ]; then
    OUTPUT="$(bash "$converter_script" "$value" "$cli_flag" "$terminal" "$schema_path" "$schema_value_path"  || exit)"
  else
    OUTPUT="$(bash "$converter_script" "$value" "$cli_flag" "$terminal" || exit)"
  fi
else
    OUTPUT="$(bash "$SCRIPTS_DIR/bitops-config/converters/string.sh" "$value" "$cli_flag" "$terminal" || exit)"
fi

echo "$OUTPUT"

