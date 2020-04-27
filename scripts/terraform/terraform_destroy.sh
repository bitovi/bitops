#!/usr/bin/env bash

set -e 

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
    TERRAFORM_ROOT=$TERRAFORM_DIRECTORY
else
    TERRAFORM_ROOT=$TEMPDIR/$ENVIRONMENT/terraform/
fi

# Run Before Deploy Scripts.

if [ -d "$TERRAFORM_ROOT/bitops-before-deploy.d/" ];then
    BEFORE_DEPLOY=$(ls $TERRAFORM_ROOT/bitops-before-deploy.d/)
    if [[ -n ${BEFORE_DEPLOY} ]];then
        echo "Running Before Deploy Scripts"
        END=$(ls $TERRAFORM_ROOT/bitops-before-deploy.d/*.sh | wc -l)
        for ((i=1;i<=END;i++)); do
            if [ -x "$i" ]; then
                /bin/bash -x $TERRAFORM_ROOT/bitops-before-deploy.d/$i.sh
            else
                echo "Before deploy script is not executible. Skipping..."
            fi
        done
    fi
fi

if [ -d "$TERRAFORM_ROOT" ]
then 
    echo "Terraform directory not set. Using default directory."
    /root/.local/bin/aws sts get-caller-identity
    cd "$TERRAFORM_ROOT"
    /usr/local/bin/terraform init -input=false
    /usr/local/bin/terraform destroy -auto-approve
fi  

# Run After Deploy Scripts if any.

if [ -d "$TERRAFORM_ROOT/bitops-after-deploy.d/" ];then
    AFTER_DEPLOY=$(ls $TERRAFORM_ROOT/bitops-after-deploy.d/)
    if [[ -n ${AFTER_DEPLOY} ]];then
        echo "Running After Deploy Scripts"
        END=$(ls $TERRAFORM_ROOT/bitops-after-deploy.d/*.sh | wc -l)
        for ((i=1;i<=END;i++)); do
            if [ -x "$i" ]; then
                /bin/bash -x $TERRAFORM_ROOT/bitops-after-deploy.d/$i.sh
            else
                echo "After deploy script is not executible. Skipping..."
            fi
        done
    fi
fi





