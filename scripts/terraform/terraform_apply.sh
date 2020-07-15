#!/usr/bin/env bash

set -e 

BITOPS_DIR="/opt/bitops"
SCRIPTS_DIR="$BITOPS_DIR/scripts"
export ERROR='\033[0;31m'
export SUCCESS='\033[0;32m'
export TERRAFORM_ROOT="" 
export TF_LOG=""

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  printf "${ERROR}environment variable (AWS_ACCESS_KEY_ID) not set."
  exit 1
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  printf "${ERROR}environment variable (AWS_ACCESS_KEY_ID) not set."
  exit 1
fi
if [ -z "$AWS_DEFAULT_REGION" ]; then
  printf "${ERROR}environment variable (AWS_DEFAULT_REGION) not set."
  exit 1
fi
if [ -z "$ENVIRONMENT" ]; then
  printf "${ERROR}environment variable (ENVIRONMENT) not set."
  exit 1
fi
if [ -n "$TERRAFORM_DIRECTORY" ]; then
    TERRAFORM_ROOT=$TEMPDIR/$TERRAFORM_DIRECTORY
else
    TERRAFORM_ROOT=$TEMPDIR/$ENVIRONMENT/terraform
fi

if [ -f "$TERRAFORM_ROOT/bitops.config.yaml" ]; then
    echo "Found Bitops config"
else
    printf "${ERROR} Error: Bitops config not found!${NC}"
    exit 1
fi

echo "Terraform Root: $TERRAFORM_ROOT"
if [ "$(shyaml debug < "$TERRAFORM_ROOT"/bitops.config.yaml)" == 'True' ];
then
    echo "Setting Terraform logging to debug mode..."
    TF_LOG="DEBUG"
fi

# Check for Before Deploy Scripts
bash -x $SCRIPTS_DIR/deploy/before-deploy.sh $TERRAFORM_ROOT
if [ -d "$TERRAFORM_ROOT" ]
then 
    echo "Terraform directory not set. Using default directory."
    /root/.local/bin/aws sts get-caller-identity
    # Copy Default Terraform values
    echo "Copying TFVARS"
    $SCRIPTS_DIR/terraform/terraform_copy_tfvars.sh "$TERRAFORM_ROOT"
    cd "$TERRAFORM_ROOT"
    TERRAFORM_APPLIED=true

    if [ "${TERRAFORM_APPLY_ALTERNATE_COMMAND}" == "true" ]; then
        TERRAFORM_COMMAND=$(shyaml get-value terraform_options.terraform_plan.command < "$TERRAFORM_ROOT"/bitops.config.yaml || true)
        echo "#!/bin/bash" >> $TERRAFORM_ROOT/alt_script.sh
        echo ${TERRAFORM_COMMAND} >> $TERRAFORM_ROOT/alt_script.sh
        chmod u+x $TERRAFORM_ROOT/alt_script.sh
        bash -x $TERRAFORM_ROOT/alt_script.sh
        rm -rf $TERRAFORM_ROOT/alt_script.sh
    else
        /usr/local/bin/terraform init -input=false
        /usr/local/bin/terraform plan
        /usr/local/bin/terraform apply -auto-approve
    fi

    terraform output config_map_aws_auth > $TEMPDIR/config_map_aws_auth.yaml
    if [ "$CREATE_KUBECONFIG_BASE64" == "true" && -z "$KUBECONFIG_BASE64" ]; then
        terraform output kubeconfig > "$KUBE_CONFIG_FILE"
        export KUBECONFIG_BASE64=$(cat "$KUBE_CONFIG_FILE" | base64)
        KUBE_CONFIG_FILE="$TEMPDIR"/.kube/config
    fi

    if [[ "No resources found." == "$(kubectl get nodes --kubeconfig="$KUBE_CONFIG_FILE")" || "$CREATE_CLUSTER" == "true" ]]; then
        GET_CLUSTER_NAME=$(get-value cluster < "$TERRAFORM_ROOT"/bitops.config.yaml || true)
        echo "CLUSTER_NAME: $GET_CLUSTER_NAME"
        get-value cluster < "$TERRAFORM_ROOT"/bitops.config.yaml
        if [ "$GET_CLUSTER_NAME" != "true" ]; then
          CLUSTER_NAME=$(get-value cluster < "$TERRAFORM_ROOT"/bitops.config.yaml)
          /root/.local/bin/aws eks update-kubeconfig --name "$CLUSTER_NAME" --region $AWS_DEFAULT_REGION --kubeconfig "$TEMPDIR"/.kube/config
          curl -o aws-auth-cm.yaml https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/aws-auth-cm.yaml
          TMP_WORKER_ROLE=$(shyaml get-value role < $TEMPDIR/opscruise-test/terraform/bitops.config.yaml)
          AWS_ROLE_PREFIX=$(echo $TMP_WORKER_ROLE | awk -F\/ {'print $1'})
          ROLE_NAME=$(echo $TMP_WORKER_ROLE | awk -F\/ {'print $2'})
          WORKER_ROLE=$AWS_ROLE_PREFIX'\/'$ROLE_NAME
          cat aws-auth-cm.yaml | sed 's/ARN of instance role (not instance profile)//g' | sed 's/[<]/'"$ROLE"'/g' | sed 's/[>]//g' > aws-auth-cm.yaml-tmp
          rm -rf aws-auth-cm.yaml
          mv aws-auth-cm.yaml-tmp aws-auth-cm.yaml
          kubectl apply --kubeconfig="$KUBE_CONFIG_FILE" -f aws-auth-cm.yaml
        else
            printf "${ERROR} Please add the name of the cluster to your bitops.config.yaml in the $TERRAFORM_ROOT directory. ${NC}"
        fi
    fi 
fi  

# Check for After Deploy Scripts

bash -x $SCRIPTS_DIR/deploy/after-deploy.sh $TERRAFORM_ROOT
printf "${SUCCESS} Terraform deployment was successful...${NC}"


