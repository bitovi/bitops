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

config_file="$1"
key="$2"
key_type="$3"
cli_flag="$4"
terminal="$5"
required="$6"
export_env="$7"
default="$8"
dash_type="$9"

if [ -n "$DEEP_DEBUG" ]; then
  echo "get-convert.sh"
  echo "  config_file: $config_file"
  echo "  key: $key"
  echo "  key_type: $key_type"
  echo "  cli_flag: $cli_flag"
  echo "  terminal: $terminal"
  echo "  dash_type: $dash_type"
fi

on_exit () {
  rv=$?
  if [ "$rv" -gt "0" ]; then
    echo "exit non-zero ($rv) for: $key" 1>&2
  fi
  exit $rv
}
trap '{ on_exit; }' EXIT

# Gets value within the CONFIG FILE ($key would = helm.cli.namespace as an example)
v="$(bash "$SCRIPTS_DIR/bitops-config/get.sh" "$config_file" "$key" "$default")"

# Convert incoming values (from config file) into normalized CLI options
OUTPUT="$(bash "$SCRIPTS_DIR/bitops-config/convert.sh" "$v" "$key_type" "$cli_flag" "$terminal" "$dash_type" )"

if [ -n "$export_env" ] && [ -n "$ENV_FILE" ] && [ -n "$v" ]; then
  echo "export ${export_env}='$v'" >> "$ENV_FILE"
fi

if [ -n "$required" ] && [ -z "$v" ]; then
  echo "REQUIRED: $key" 1>&2
  exit 1
fi

if [ "$OUTPUT" == "" ] || [ "$OUTPUT" == " " ] || [ -z "$OUTPUT" ] || [ "$OUTPUT" == "$dash_type" ];  then
  # Ignoring empty return values
  OUTPUT=""
fi

echo "$OUTPUT"
