#!/usr/bin/env bash
set -e

if [ -z "$BITOPS_DIR" ];then
  echo "Using default BitOps Directory"
  export BITOPS_DIR="/opt/bitops"
fi

if [ -z "$SCRIPTS_DIR" ];then
  echo "Using default BitOps Script Directory"
  export SCRIPTS_DIR="/opt/bitops/scripts"
fi

value="$1"
key_type="$2"
cli_flag="$3"
terminal="$4"
dash_type="$5"

if [ -n "$DEEP_DEBUG" ]; then
    echo "convert.sh"
    echo "  value: $value"
    echo "  key_type: $key_type"
    echo "  cli_flag: $cli_flag"
    echo "  terminal: $terminal"
    echo "  dash_type: $dash_type"
fi

converter_script="$SCRIPTS_DIR/bitops-config/converters/${key_type}.sh"

if [ -z "$cli_flag" ] || [ -z "$value" ]; then
  echo ""
  exit 0
fi

if [ -f "$converter_script" ]; then

    OUTPUT="$(bash "$converter_script" "$value" "$cli_flag" "$terminal" "$dash_type" || exit)"
  
else
    OUTPUT="$(bash "$SCRIPTS_DIR/bitops-config/converters/string.sh" "$value" "$cli_flag" "$terminal" "$dash_type" || exit)"
fi

echo "$OUTPUT"

