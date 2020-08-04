#!/usr/bin/env bash

# set -ex
set -e

export BITOPS_DIR="/opt/bitops"
export SCRIPTS_DIR="$BITOPS_DIR/scripts"


config_file="$1"
key="$2"
key_type="$3"
cli_flag="$4"
terminal="$5"
required="$6"
export_env="$7"
default="$8"

if [ -n "$DEBUG" ]; then
  echo "get-convert.sh"
  echo "  config_file: $config_file"
  echo "  key: $key"
  echo "  key_type: $key_type"
  echo "  cli_flag: $cli_flag"
  echo "  terminal: $terminal"
fi

on_exit () {
  rv=$?
  if [ "$rv" -gt "0" ]; then
    echo "exit non-zero ($rv) for: $key" 1>&2
  fi
  exit $rv
}
trap '{ on_exit; }' EXIT

v="$(bash "$SCRIPTS_DIR/bitops-config/get.sh" "$config_file" "$key" "$default")"

OUTPUT="$(bash "$SCRIPTS_DIR/bitops-config/convert.sh" "$v" "$key_type" "$cli_flag" "$terminal")"

if [ -n "$export_env" ] && [ -n "$ENV_FILE" ]; then
  # echo "export ${export_env}='$v'" >> $ENV_FILE
  echo "${export_env}='$v'" >> $ENV_FILE
fi

if [ -n "$required" ] && [ -z "$v" ]; then
  echo "REQUIRED: $key" 1>&2
  exit 1
fi


echo "$OUTPUT"
