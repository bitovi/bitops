#!/usr/bin/env bash
# convert-schema.sh --> get-convert --> get.sh --> shyaml
#                                 | --> convert.sh --> converters/ (converter is choosen by the schema.type, defaults to string)                   

set -e

if [ -z "$BITOPS_DIR" ];then
  echo "Using default BitOps Directory"
  export BITOPS_DIR="/opt/bitops"
fi

if [ -z "$SCRIPTS_DIR" ];then
  echo "Using default BitOps Script Directory"
  export SCRIPTS_DIR="/opt/bitops/scripts"
fi


POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -r|--root-key)
      ROOT_KEY=$2
      shift # Pass over optional arguement
      shift # Pass over optional arguement value
      ;;
      -rs|--root-key-schema)
      ROOT_KEY_SCHEMA=$2
      shift # Pass over optional arguement
      shift # Pass over optional arguement value
      ;;
    *)
      POSITIONAL+=("$1")
      shift # Add Normal positionals back into place
      ;;
  esac
done


set -- "${POSITIONAL[@]}" # Restore positional arguements

# -- #
SCHEMA_FILE="$1"
BITOPS_CONFIG_FILE="$2"
# -- #
if [ -z "$ROOT_KEY" ];then
  export ROOT_KEY="$3"
fi
# -- #
if [ -z "$ROOT_KEY_SCHEMA" ];then
  export ROOT_KEY_SCHEMA="$4"
fi
# -- #


if [ -n "$DEEP_DEBUG" ]; then
  echo "BITOPS SET TO: [$BITOPS_DIR]"
  echo "SCRIPTS SET TO: [$SCRIPTS_DIR]"
  echo "SCHEMA_FILESET TO: [$SCHEMA_FILE]"
  echo "BITOPS_CONFIG_FILE SET TO: [$BITOPS_CONFIG_FILE]"
  echo "ROOT_KEY SET TO: [$ROOT_KEY]"
  echo "ROOT_KEY_SCHEMA SET TO: [$ROOT_KEY_SCHEMA]"
fi

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

  if [ -z "$rootkey_schema" ];then
    rootkey_schema=$ROOT_KEY_SCHEMA
  fi

  keys="$(get_schema_keys ${rootkey_schema})"

  while IFS= read -r value; do
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
      echo "$full_value_path,$full_value_path_schema"
    fi
  done <<< "$keys"
}

# OLD USAGE
# build_keys_list "$ROOT_KEY" "$ROOT_KEY_SCHEMA"
# This has been changed to the line below
KEYS_LIST="$(build_keys_list $ROOT_KEY)"
if [ -n "$DEEP_DEBUG" ]; then
  echo "Keys List: [$KEYS_LIST]"
fi

script_options=""
while IFS= read -r value; do
  if [ -z "$value" ]; then
    continue
  fi

  IFS=',' read -r -a array <<< "$value"
  full_value_path="${array[0]}"
  full_value_path_schema="${array[1]}"

  if [ -n "$DEEP_DEBUG" ]; then
    echo "full_value_path=$full_value_path"
    echo "full_value_path_schema=$full_value_path_schema"
  fi 

  type="$($SCRIPTS_DIR/bitops-config/get.sh $SCHEMA_FILE "${full_value_path_schema}.type")"
  parameter="$($SCRIPTS_DIR/bitops-config/get.sh $SCHEMA_FILE "${full_value_path_schema}.parameter")"
  terminal="$($SCRIPTS_DIR/bitops-config/get.sh $SCHEMA_FILE "${full_value_path_schema}.terminal")"
  required="$($SCRIPTS_DIR/bitops-config/get.sh $SCHEMA_FILE "${full_value_path_schema}.required")"
  export_env="$($SCRIPTS_DIR/bitops-config/get.sh $SCHEMA_FILE "${full_value_path_schema}.export_env")"
  default="$($SCRIPTS_DIR/bitops-config/get.sh $SCHEMA_FILE "${full_value_path_schema}.default")"
  dash_type="$($SCRIPTS_DIR/bitops-config/get.sh $SCHEMA_FILE "${full_value_path_schema}.dash_type")"

  # Default to double dash
  if [ -z "$dash_type" ]; then
    dash_type="--"
  fi

  if [ -n "$DEEP_DEBUG" ]; then
    echo "$full_value_path"
    echo "  type: $type"
    echo "  parameter: $parameter"
    echo "  terminal: $terminal"
    echo "  required: $required"
    echo "  export_env: $export_env"
    echo "  default: $default"
    echo "  dash_type: $dash_type"
  fi

  script_option="$($SCRIPTS_DIR/bitops-config/get-convert.sh $BITOPS_CONFIG_FILE "$full_value_path" "$type" "$parameter" "$terminal" "$required" "$export_env" "$default" "$dash_type" )"

  if [ -n "$script_option" ]; then
    script_options="$script_options $script_option"
  fi
done <<< "$KEYS_LIST"

if [ -n "$DEBUG" ]; then
  echo "script_options: [$script_options]"
fi

echo "$script_options"

if [ -z "$ENV_FILE" ]; then
  echo "env var not set: ENV_FILE
provide ENV_FILE to enable setting env variables via config option 'export_env'
  " 1>&2
else
  source $ENV_FILE
fi
