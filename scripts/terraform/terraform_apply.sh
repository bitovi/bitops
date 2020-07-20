#!/usr/bin/env bash

set -e 

BITOPS_CONFIG="$TERRAFORM_BITOPS_CONFIG" 

echo "Running terraform apply..."
printf "${WARN}This will create an EKS Cluster in AWS. Charges may apply.${NC}"

TF_LOG=""
if [ "$(shyaml debug < "$BITOPS_CONFIG")" == 'True' ]; then
    echo "Setting Terraform logging to debug mode..."
    TF_LOG="DEBUG"
fi

# Check for Before Deploy Scripts
bash -x $SCRIPTS_DIR/deploy/before-deploy.sh $TERRAFORM_ROOT


if [ "${TERRAFORM_APPLY_ALTERNATE_COMMAND}" == "true" ]; then
  printf "${WARN}Running Alternate Terraform command.${NC}"

  TERRAFORM_COMMAND=$(shyaml get-value terraform_options.terraform_apply.command < "$BITOPS_CONFIG" || true)
  bash $SCRIPTS_DIR/util/run-text-as-script.sh "$TERRAFORM_ROOT" "$TERRAFORM_COMMAND"
else
  # TODO: the terraform_apply script should not do init, plan, and apply (just apply)
  terraform init -input=false
  terraform plan
  terraform apply -auto-approve
fi



terraform output config_map_aws_auth > $TEMPDIR/config_map_aws_auth.yaml

if [ ! -f "$KUBE_CONFIG_FILE" ]; then 
  echo "${WARN}KUBE_CONFIG_FILE is empty ($KUBE_CONFIG_FILE)${NC}"
  echo "Attempting to retrieve KUBECONFIG from Terraform..."
  bash $SCRIPTS_DIR/terraform/generate_kubeconfig.sh
fi

# TODO: what is the purpose of this block?
if [[ "No resources found." == "$(kubectl get nodes --kubeconfig="$KUBE_CONFIG_FILE")" || "$CREATE_CLUSTER" == "true" ]]; then
  GET_CLUSTER_NAME=$(get-value cluster < "$BITOPS_CONFIG" || true)
  echo "CLUSTER_NAME: $GET_CLUSTER_NAME"

  if [ "$GET_CLUSTER_NAME" != "true" ]; then
    CLUSTER_NAME=$(get-value cluster < "$BITOPS_CONFIG")

    CLUSTER_NAME="$CLUSTER_NAME" \
    KUBECONFIG="$KUBE_CONFIG_FILE" \
    bash $SCRIPTS_DIR/aws/eks.update-kubeconfig.sh

    bash $SCRIPTS_DIR/aws/eks.create_config_map.sh
    
  else
    printf "${ERROR} Please add the name of the cluster to your bitops.config.yaml in the $TERRAFORM_ROOT directory. ${NC}"
  fi
fi 

# Check for After Deploy Scripts
bash -x $SCRIPTS_DIR/deploy/after-deploy.sh $TERRAFORM_ROOT
printf "${SUCCESS} Terraform deployment was successful...${NC}"


