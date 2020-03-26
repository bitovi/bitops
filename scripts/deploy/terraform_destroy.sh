#!/usr/bin/env bash

set -e 

function terraform_destroy() {
    if [ -z "$TERRAFORM_DIRECTORY" ]
    then 
        echo "Terraform directory not set. Using default directory."
        cd "$CURRENT_ENVIRONMENT/$DEPLOYMENT_DIR"
        /usr/local/bin/terraform init && /usr/local/bin/terraform plan
    else
       #Destroying EKS cluster
       cd "$CURRENT_ENVIRONMENT/$TERRAFORM_DIRECTORY"
       /usr/local/bin/terraform init
       /usr/local/bin/terraform destroy -auto-approve
    fi     
}