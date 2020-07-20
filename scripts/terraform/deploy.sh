#!/usr/bin/env bash

set -ex 

# terraform vars
export TERRAFORM_ROOT="$ENVROOT/terraform" 
export TERRAFORM_BITOPS_CONFIG="$TERRAFORM_ROOT/bitops.config.yaml" 

if [ ! -d "$TERRAFORM_ROOT" ]; then
  echo "No terraform directory.  Skipping."
  exit 0
else
  printf "Deploying terraform... ${NC}"
fi


if [ -f "$BITOPS_CONFIG" ]; then
  echo "Terraform - Found Bitops config"
else
  echo "Terraform - No Bitops config"
fi

CREATE_CLUSTER=false


bash $SCRIPTS_DIR/terraform/validate_env.sh


if [ -n "$CLUSTER_NAME" ]; then
  echo "Using $CLUSTER_NAME cluster..."
else
  CLUSTER_NAME=$(shyaml get-value cluster < "$TERRAFORM_BITOPS_CONFIG" || true)
  CLUSTER_NAME=$(echo $CLUSTER_NAME | sed 's/true//g')
fi

if [ -z "$CLUSTER_NAME" ]; then
    printf "
${ERROR} Please set the CLUSTER_NAME environment variable or the cluster option in <env>/terraform/bitops.config.yaml.${NC}
"
    return 1 
fi

# Copy Default Terraform values
echo "Copying defaults"
$SCRIPTS_DIR/terraform/copy_defaults.sh "$TERRAFORM_ROOT"

echo "cd Terraform Root: $TERRAFORM_ROOT"
cd $TERRAFORM_ROOT


# cloud provider auth
echo "Terraform auth cloud provider"
bash $SCRIPTS_DIR/aws/sts.get-caller-identity.sh



if [[ "${TERRAFORM_PLAN}" == "true" ]];then
  echo "Running Terraform Plan"
  bash $SCRIPTS_DIR/terraform/terraform_plan.sh
fi

if [[ "${TERRAFORM_APPLY}" == "true" ]]; then
  echo "Running Terraform Apply"
  bash $SCRIPTS_DIR/terraform/terraform_apply.sh
fi

if [[ "${TERRAFORM_DESTROY}" == "true" ]];then
  echo "Destroying Cluster"
  bash $SCRIPTS_DIR/terraform/terraform_destroy.sh
fi
