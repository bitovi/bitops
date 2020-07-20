#!/usr/bin/env bash

set -e 

echo "Running terraform destroy..."

if [ "${TERRAFORM_DESTROY_ALTERNATE_COMMAND}" == "true" ]; then
  printf "${WARN}Running Alternate Terraform command.${NC}"

  TERRAFORM_COMMAND=$(shyaml get-value terraform_options.terraform_destroy.command < "$TERRAFORM_BITOPS_CONFIG" || true)
  bash $SCRIPTS_DIR/util/run-text-as-script.sh "$TERRAFORM_ROOT" "$TERRAFORM_COMMAND"
else
  terraform init -input=false
  terraform plan
  terraform destroy -auto-approve
fi

printf "${SUCCESS} Successfully destroyed Terraform deployment..."
