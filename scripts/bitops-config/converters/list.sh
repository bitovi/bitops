#!/usr/bin/env bash
set -e

value="$1"
cli_flag="$2"
terminal="$3"
space=" "

value=${value%$'\n'}
IFS='-';for stringval in $1; 
do 
    if [[ $stringval == "" ]] || [[ $stringval == " " ]]; then
        setval=""
    else
        setval=$"${cli_flag}$stringval"
        setval=${setval%$'\n'}
        OUTPUT=$OUTPUT$setval$space
    fi
done

echo "$OUTPUT"

