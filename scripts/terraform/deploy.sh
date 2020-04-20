#!/usr/bin/env bash

set -ex


##
## Set up parameters
##

# application root
ROOT_DIR="$1"

# Which environment to deploy
# this should correspond to a directory in the operations repo
# which should also be the current working directory
ENVIRONMENT="$2"

##
## Validation
##

# if this isn't a specific environment, exit
if [ -z "$ENVIRONMENT" ]; then
  echo "environment (second parameter) must be specified!"
  exit 1
fi



echo "TODO..."