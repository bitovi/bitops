#!/usr/bin/env bash
set -e 

WORKSPACE=$1
echo "Running terraform workspace to [$WORKSPACE]..."
terraform workspace new $WORKSPACE || terraform workspace select $WORKSPACE

