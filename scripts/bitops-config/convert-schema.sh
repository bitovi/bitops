#!/usr/bin/env bash

export BITOPS_DIR="/opt/bitops"
export SCRIPTS_DIR="$BITOPS_DIR/scripts"

# set -ex

SCHEMA_FILE="$1"
BITOPS_CONFIG_FILE="$2"
KEYS_LIST=""

function get_schema_keys(){
  rootkey="$1"
  k="$(cat $SCHEMA_FILE | shyaml keys $rootkey)"
  echo "$k"
}

function build_keys_list(){
  local rootkey="$1"
  local rootkey_schema="$2"
  local keys=""

  keys="$(get_schema_keys ${rootkey_schema})"
  
  while IFS= read -r value; do
    # echo "RECEIVED: '$value'"

    full_value_path="${value}"
    full_value_path_schema="${value}"

    if [ -n "$rootkey" ]; then
      full_value_path="${rootkey}.${value}"
      full_value_path_schema="${rootkey_schema}.${value}"
    fi

    type="$($SCRIPTS_DIR/bitops-config/get.sh $SCHEMA_FILE "${full_value_path_schema}.type")"

    # if type is object, recurse
    # else, add key path to final list
    if [ "$type" == "object" ]; then
      build_keys_list "${full_value_path}" "${full_value_path_schema}.properties"
    else
      KEYS_LIST="$KEYS_LIST
${full_value_path},${full_value_path_schema}"
    fi
  done <<< "$keys"
}

# TODO
# KEYS_LIST="$(build_keys_list)"
build_keys_list



script_options=""
while IFS= read -r value; do
  if [ -z "$value" ]; then
    continue
  fi

  IFS=',' read -r -a array <<< "$value"
  full_value_path="${array[0]}"
  full_value_path_schema="${array[1]}"

  type="$($SCRIPTS_DIR/bitops-config/get.sh $SCHEMA_FILE "${full_value_path_schema}.type")"
  parameter="$($SCRIPTS_DIR/bitops-config/get.sh $SCHEMA_FILE "${full_value_path_schema}.parameter")"
  terminal="$($SCRIPTS_DIR/bitops-config/get.sh $SCHEMA_FILE "${full_value_path_schema}.terminal")"


  script_option="$($SCRIPTS_DIR/bitops-config/get-convert.sh $BITOPS_CONFIG_FILE "$full_value_path" "$type" "$parameter" "$terminal")"
  
  if [ -n "$DEBUG" ]; then
    echo "$full_value_path"
    echo "  type: $type"
    echo "  parameter: $parameter"
    echo "  terminal: $terminal"
    echo "  script_option: $script_option"
  fi

  script_options="$script_options $script_option"
done <<< "$KEYS_LIST"


if [ -n "$DEBUG" ]; then
  echo "script_options:"
fi

echo "$script_options"

