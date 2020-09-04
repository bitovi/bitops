#!/usr/bin/env bash
set -e

TERRAFORM_ROOT=$1
DEFAULT_TERRAFORM_ROOT="$DEFAULT_ENVROOT/terraform"
if [ -d "$DEFAULT_TERRAFORM_ROOT/values" ];then
    COPY_TFVARS=$(ls $DEFAULT_TERRAFORM_ROOT/values)
    if [[ -n ${COPY_TFVARS} ]];then
        echo "Copying TFVARS to Terraform Root directory."
        END=$(ls $DEFAULT_TERRAFORM_ROOT/values | wc -l)
        for ((i=1;i<=END;i++)); do
            cp -rf $DEFAULT_TERRAFORM_ROOT/values/$i $TERRAFORM_ROOT/
        done
    fi
fi