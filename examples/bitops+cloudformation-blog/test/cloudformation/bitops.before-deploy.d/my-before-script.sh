#!/bin/bash
set -e
PARAMS_FILE=$CLOUDFORMATION_ROOT/parameters.json

cat $PARAMS_FILE | jq 'map(select(.ParameterKey == "DBUser").ParameterValue='\"$CF_DB_USERNAME\"')' > out.tmp
mv out.tmp $CLOUDFORMATION_ROOT/parameters.json

cat $PARAMS_FILE | jq 'map(select(.ParameterKey == "DBPassword").ParameterValue='\"$CF_DB_PASSWORD\"')' > out.tmp
mv out.tmp $CLOUDFORMATION_ROOT/parameters.json