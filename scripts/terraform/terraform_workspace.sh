#!/usr/bin/env bash

set -e 

echo "Running terraform workspace..."
terraform workspace new $TERRAFORM_WORKSPACE || terraform workspace select $TERRAFORM_WORKSPACE

