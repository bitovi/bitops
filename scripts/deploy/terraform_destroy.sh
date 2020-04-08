#!/usr/bin/env bash

set -e 

function terraform_destroy() {
    if [ -z "$TERRAFORM_DIRECTORY" ]
    then 
        echo "Terraform directory not set. Using default directory."
        cd "$DEPLOYMENT_DIR/$CURRENT_ENVIRONMENT/terraform/"
       /usr/local/bin/terraform init
       /usr/local/bin/terraform destroy -auto-approve
    else
       #Destroying EKS cluster
       cd "$TERRAFORM_DIRECTORY/"
       /usr/local/bin/terraform init
       /usr/local/bin/terraform destroy -auto-approve
    fi     
}

terraform_destroy