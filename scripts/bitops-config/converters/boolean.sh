#!/usr/bin/env bash

# set -ex

value="$1"
cli_flag="$2"
terminal="$3"

if [ -n "$DEBUG" ]; then
    echo "converters/boolean.sh"
    echo "  value: $value"
    echo "  cli_flag: $cli_flag"
    echo "  terminal: $terminal"
fi

OUTPUT=""
if [ -z "$value" ] || [ "$value" == "" ] || [ "$value" == "False" ]; then
    OUTPUT=""
elif [ "$value" == "True" ]; then
    OUTPUT="--${cli_flag}"
    if [ "$terminal" == "True" ] || [ "$terminal" == "true" ]; then
        if [ -n "$DEBUG" ]; then
            echo "boolean terminal: true - exit 1"
        fi
        exit 1
    fi
else
    OUTPUT="--${cli_flag} $value"
fi

echo "$OUTPUT"

