#!/usr/bin/env bash

set -e 

export TERRAFORM_ROOT=""
BITOPS_DIR="/opt/bitops"
SCRIPTS_DIR="$BITOPS_DIR/scripts"
export ERROR='\033[0;31m'
export SUCCESS='\033[0;32m'
export TERRAFORM_ROOT=""

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
    TERRAFORM_ROOT=$TEMPDIR/$TERRAFORM_DIRECTORY
else
    TERRAFORM_ROOT=$TEMPDIR/$ENVIRONMENT/terraform/
fi

if [ -f "$TERRAFORM_ROOT/bitops.config.yaml" ]; then
    echo "Found Bitops config"
else
    printf "${ERROR} Error: Bitops config not found!${NC}"
    exit 1
fi

if [ -d "$TERRAFORM_ROOT" ]
then 
    # Copy Default Terraform values
    echo "Copying TFVARS"
    $SCRIPTS_DIR/terraform/terraform_copy_tfvars.sh "$TERRAFORM_ROOT"

    cd "$TERRAFORM_ROOT"
    if [ "${TERRAFORM_PLAN_ALTERNATE_COMMAND}" == "true" ]; then
        TERRAFORM_COMMAND=$(shyaml get-value terraform_options.terraform_plan.command < "$TERRAFORM_ROOT"/bitops.config.yaml || true)
        echo "#!/bin/bash" >> $TERRAFORM_ROOT/alt_script.sh
        echo ${TERRAFORM_COMMAND} >> $TERRAFORM_ROOT/alt_script.sh
        chmod u+x $TERRAFORM_ROOT/alt_script.sh
        bash -x $TERRAFORM_ROOT/alt_script.sh
        rm -rf $TERRAFORM_ROOT/alt_script.sh
    else
        /usr/local/bin/terraform init -input=false
        /usr/local/bin/terraform plan
    fi
fi  

