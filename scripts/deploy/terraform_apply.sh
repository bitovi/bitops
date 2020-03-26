#!/usr/bin/env bash

set -e 

function terraform_plan() {
    if [ -z "$TERRAFORM_DIRECTORY" ]
    then 
        echo "Terraform directory not set. Using default directory."
        cd "$CURRENT_ENVIRONMENT/$DEPLOYMENT_DIR"
        /usr/local/bin/terraform init && /usr/local/bin/terraform plan
    else
       #Run Terraform Plan
       cd "$CURRENT_ENVIRONMENT/$TERRAFORM_DIRECTORY"
       /usr/local/bin/terraform init && /usr/local/bin/terraform plan
    fi
}

function terraform_apply() {
    if [ -z "$TERRAFORM_DIRECTORY" ]
    then 
        echo "Terraform directory not set. Using default directory."
        cd "$CURRENT_ENVIRONMENT/$DEPLOYMENT_DIR"
        /usr/local/bin/terraform init && /usr/local/bin/terraform plan
    else
       #launch terraform to create EKS cluster
       cd "$CURRENT_ENVIRONMENT/$TERRAFORM_DIRECTORY"
       /usr/local/bin/terraform init && /usr/local/bin/terraform plan
       /usr/local/bin/terraform apply -auto-approve
    fi  
}