#!/usr/bin/env bash

# Convert incoming values (from config file) into normalized CLI options
set -e

value="$1"
cli_flag="$2"
terminal="$3"
dash_type="$4"
space=" "

if [ -n "$DEEP_DEBUG" ]; then
    echo "converters/parameter-list.sh"
    echo "  value: $value"
    echo "  cli_flag: $cli_flag"
    echo "  terminal: $terminal"
    echo "  dash_type: $dash_type"
fi

values=$(echo $value | tr "\n" " " | tr "\- " " " | xargs)

IFS=" " read -r -a values_array <<< $values


OUTPUT=
for i in "${values_array[@]}"
do
    # <dashes><schema_parameter><config value>
    OUTPUT="$(echo "$dash_type$cli_flag=\"${i}\"") $OUTPUT"
done
# OUTPUT NEEDS TO BE: backend-config="KEY1=VALUE1" backend-config="KEY2=VALUE2"
# echo $value | tr "\n" " " | tr "\- " " " | xargs

echo "$OUTPUT"

