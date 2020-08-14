#!/usr/bin/env bash

set -e 

echo "Running terraform apply..."

BITOPS_CONFIG="$TERRAFORM_BITOPS_CONFIG" 
TF_ARGS=$1

TF_LOG=""
if [ "${DEBUG}" == 'True' ]; then
    echo "Setting Terraform logging to debug mode..."
    TF_LOG="DEBUG"
fi

# Check for Before Deploy Scripts
bash -x $SCRIPTS_DIR/deploy/before-deploy.sh "$(pwd)"


if [ "${TERRAFORM_APPLY_ALTERNATE_COMMAND}" == "true" ]; then
  printf "${WARN}Running Alternate Terraform command.${NC}"

  TERRAFORM_COMMAND=$(shyaml get-value terraform_options.terraform_apply.command < "$BITOPS_CONFIG" || true)
  bash $SCRIPTS_DIR/util/run-text-as-script.sh "$TERRAFORM_ROOT" "$TERRAFORM_COMMAND"
else
  terraform apply -auto-approve $TF_ARGS
fi

# Check for After Deploy Scripts
bash -x $SCRIPTS_DIR/deploy/after-deploy.sh "$(pwd)"
printf "${SUCCESS} Terraform deployment was successful...${NC}"


