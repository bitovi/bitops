#!/usr/bin/env bash
set -e

value="$1"
cli_flag="$2"
terminal="$3"
space=" "
schema_path="$4"
schema_value_path="$5"


function get_schema_values(){
  rootkey="$1"
  k="$(cat $schema_path | shyaml get-values "$schema_value_path.selection-list" | tr "\n" " " | xargs )"
  echo "$k"
}


# echo "LOOK HERE: 1:[$value], 2:[$cli_flag], 3:[$terminal], 4:[$schema_path], 5:[$schema_value_path] 6:[$(get_schema_keys)]"
SELECTION_VALUES_LIST="$(get_schema_values)"
IFS=' ' read -r -a SELECTION_VALUES_ARRAY <<< "$SELECTION_VALUES_LIST"

# Create array from get_schema_values
# Loop through array and determine if the incoming value
# is in the selection group

if [ -n "$DEBUG" ]; then
    echo "converters/selection-list.sh"
    echo "  value: $value"
    echo "  cli_flag: $cli_flag"
    echo "  terminal: $terminal"
fi

for i in "${SELECTION_VALUES_ARRAY[@]}"
do
    # Check the value at this point.
    if [[ "$value" == "$i" ]]; then
        OUTPUT="--${cli_flag}=$value"
    fi
done

echo "$OUTPUT"

