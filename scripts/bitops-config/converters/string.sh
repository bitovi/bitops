#!/usr/bin/env bash
set -e

value="$1"
cli_flag="$2"
terminal="$3"

if [ -n "$DEEP_DEBUG" ]; then
    echo "converters/string.sh"
    echo "  value: $value"
    echo "  cli_flag: $cli_flag"
    echo "  terminal: $terminal"
fi

OUTPUT="${cli_flag}=$value"

echo "$OUTPUT"

