#!/usr/bin/env bash

set -ex 

# terraform vars
export TERRAFORM_ROOT="$ENVROOT/terraform" 
export TERRAFORM_TERRAFORM_BITOPS_CONFIG="$TERRAFORM_ROOT/bitops.config.yaml" 

if [ ! -d "$TERRAFORM_ROOT" ]; then
  echo "No terraform directory.  Skipping."
  exit 0
else
  printf "Deploying terraform... ${NC}"
fi


if [ -f "$TERRAFORM_BITOPS_CONFIG" ]; then
  echo "Terraform - Found Bitops config"
else
  echo "Terraform - No Bitops config"
fi

CREATE_CLUSTER=false


if [ -n "$CLUSTER_NAME" ]; then
  echo "Using $CLUSTER_NAME cluster..."
else
  CLUSTER_NAME=$(shyaml get-value cluster < "$TERRAFORM_BITOPS_CONFIG" || true)
  CLUSTER_NAME=$(echo $CLUSTER_NAME | sed 's/true//g')
fi

CLUSTER_NAME="$CLUSTER_NAME" \
bash $SCRIPTS_DIR/terraform/validate_env.sh


# Copy Default Terraform values
echo "Copying defaults"
$SCRIPTS_DIR/terraform/copy_defaults.sh "$TERRAFORM_ROOT"

echo "cd Terraform Root: $TERRAFORM_ROOT"
cd $TERRAFORM_ROOT


# cloud provider auth
echo "Terraform auth cloud provider"
bash $SCRIPTS_DIR/aws/sts.get-caller-identity.sh


# always init first
echo "Running terraform init"
terraform init -input=false

# always plan first
echo "Running Terraform Plan"
bash $SCRIPTS_DIR/terraform/terraform_plan.sh


if [[ "${TERRAFORM_APPLY}" == "true" ]]; then
  echo "Running Terraform Apply"
  bash $SCRIPTS_DIR/terraform/terraform_apply.sh
fi

if [[ "${TERRAFORM_DESTROY}" == "true" ]]; then
  echo "Destroying Cluster"
  bash $SCRIPTS_DIR/terraform/terraform_destroy.sh
  exit 0
fi

# always get the kubeconfig (whether or not we applied)
if [ ! -f "$KUBE_CONFIG_FILE" ]; then 
  echo "${WARN}KUBE_CONFIG_FILE is empty ($KUBE_CONFIG_FILE)${NC}"
  echo "Attempting to retrieve KUBECONFIG from Terraform..."
  bash $SCRIPTS_DIR/terraform/generate_kubeconfig.sh
fi


# validate nodes exist
if [[ "No resources found." == "$(kubectl get nodes --kubeconfig="$KUBE_CONFIG_FILE")" ]]; then
  CLUSTER_NAME="$CLUSTER_NAME" \
  KUBECONFIG="$KUBE_CONFIG_FILE" \
  bash $SCRIPTS_DIR/aws/eks.update-kubeconfig.sh

  bash $SCRIPTS_DIR/aws/eks.create_config_map.sh
fi 





