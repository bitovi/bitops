#!/usr/bin/env bash

set -e 

export TERRAFORM_ROOT=""
BITOPS_DIR="/opt/bitops"
SCRIPTS_DIR="$BITOPS_DIR/scripts"
export ERROR='\033[0;31m'
export SUCCESS='\033[0;32m'

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "environment variable (AWS_ACCESS_KEY_ID) not set"
  exit 1
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "environment variable (AWS_ACCESS_KEY_ID) not set"
  exit 1
fi
if [ -z "$AWS_DEFAULT_REGION" ]; then
  echo "environment variable (AWS_DEFAULT_REGION) not set"
  exit 1
fi
if [ -z "$ENVIRONMENT" ]; then
  echo "environment variable (ENVIRONMENT) not set"
  exit 1
fi
if [ -n "$TERRAFORM_DIRECTORY" ]; then
    TERRAFORM_ROOT=$TERRAFORM_DIRECTORY
else
    TERRAFORM_ROOT=$TEMPDIR/$ENVIRONMENT/terraform/
fi


if [ -d "$TERRAFORM_ROOT" ]
then 
    echo "Terraform directory not set. Using default directory."
    /root/.local/bin/aws sts get-caller-identity
    cd "$TERRAFORM_ROOT"
    /usr/local/bin/terraform init -input=false
    /usr/local/bin/terraform destroy -auto-approve
fi  

printf "${SUCCESS} Successfully destroyed Terraform deployment..."






