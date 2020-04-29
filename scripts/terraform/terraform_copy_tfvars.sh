#!/usr/bin/env bash
set -ex

TERRAFORM_ROOT=$1

if [ -d "$TMPDIR/default/terraform/values" ];then
    COPY_TFVARS=$(ls $TMPDIR/default/terraform/values)
    if [[ -n ${COPY_TFVARS} ]];then
        echo "Copying TFVARS to Terraform Root directory."
        END=$(ls $TMPDIR/default/terraform/values | wc -l)
        for ((i=1;i<=END;i++)); do
            cp -rf $TMPDIR/default/terraform/values/$i $TERRAFORM_ROOT/
        done
    fi
fi