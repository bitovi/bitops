#!/usr/bin/env bash

set -e 

function terraform_plan() {
    if [ -z "$TERRAFORM_DIRECTORY" ]
    then 
        echo "Terraform directory not set. Using default directory."
        cd "$DEPLOYMENT_DIR/$CURRENT_ENVIRONMENT/terraform/"
        /usr/local/bin/terraform init && /usr/local/bin/terraform plan
    else
       #Run Terraform Plan
       cd "$TERRAFORM_DIRECTORY/"
       /usr/local/bin/terraform init && /usr/local/bin/terraform plan
    fi
}

function terraform_apply() {
    if [ -z "$TERRAFORM_DIRECTORY" ]
    then 
        echo "Terraform directory not set. Using default directory."
        cd "$DEPLOYMENT_DIR/$CURRENT_ENVIRONMENT/terraform/"
        /usr/local/bin/terraform init && /usr/local/bin/terraform plan
        /usr/local/bin/terraform apply -auto-approve
    else
       #launch terraform to create EKS cluster
       cd "$TERRAFORM_DIRECTORY/"
       /usr/local/bin/terraform init && /usr/local/bin/terraform plan
       /usr/local/bin/terraform apply -auto-approve
    fi  
}

terraform_plan
terraform_apply