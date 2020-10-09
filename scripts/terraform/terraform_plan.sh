#!/usr/bin/env bash
set -e

echo "Running terraform plan..."
TF_ARGS=$1

if [ "${TERRAFORM_PLAN_ALTERNATE_COMMAND}" == "true" ]; then
  printf "${WARN}Running Alternate Terraform command.${NC}"

  TERRAFORM_COMMAND=$(shyaml get-value terraform_options.terraform_plan.command < "$TERRAFORM_BITOPS_CONFIG" || true)
  bash $SCRIPTS_DIR/util/run-text-as-script.sh "$TERRAFORM_ROOT" "$TERRAFORM_COMMAND"
else
  terraform plan $TF_ARGS -detailed-exitcode
fi

