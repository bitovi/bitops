#!/usr/bin/env bash
set -e

value="$1"
cli_flag="$2"
terminal="$3"

if [ -n "$DEEP_DEBUG" ]; then
    echo "converters/exists.sh"
    echo "  value: $value"
    echo "  cli_flag: $cli_flag"
    echo "  terminal: $terminal"
fi

if [ -z "$value" ] || [ "$value" == "" ]; then
    OUTPUT=""
else
    OUTPUT="${cli_flag}"
fi

echo "$OUTPUT"

