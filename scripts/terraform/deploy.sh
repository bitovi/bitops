#!/usr/bin/env bash
# No set -e here because we want to get a non-zero exit code from terraform_plan.sh

# terraform vars
export TERRAFORM_ROOT="$ENVROOT/terraform" 
export TERRAFORM_BITOPS_CONFIG="$TERRAFORM_ROOT/bitops.config.yaml" 
export BITOPS_SCHEMA_ENV_FILE="$TERRAFORM_ROOT/ENV_FILE"
export BITOPS_CONFIG_SCHEMA="$SCRIPTS_DIR/terraform/bitops.schema.yaml"


if [ ! -d "$TERRAFORM_ROOT" ]; then
  echo "No terraform directory.  Skipping."
  exit 0
else
  printf "Deploying terraform... ${NC}"
fi

# Check for Before Deploy Scripts
bash -x $SCRIPTS_DIR/deploy/before-deploy.sh "$TERRAFORM_ROOT"

export BITOPS_CONFIG_COMMAND="$(ENV_FILE="$BITOPS_SCHEMA_ENV_FILE" DEBUG="" bash $SCRIPTS_DIR/bitops-config/convert-schema.sh $BITOPS_CONFIG_SCHEMA $TERRAFORM_BITOPS_CONFIG)"
echo "BITOPS_CONFIG_COMMAND: $BITOPS_CONFIG_COMMAND"
echo "BITOPS_SCHEMA_ENV_FILE: $(cat $BITOPS_SCHEMA_ENV_FILE)"
source "$BITOPS_SCHEMA_ENV_FILE"

bash $SCRIPTS_DIR/terraform/validate_env.sh

# Copy Default Terraform values
echo "Copying defaults"
$SCRIPTS_DIR/terraform/copy_defaults.sh "$TERRAFORM_ROOT"

echo "cd Terraform Root: $TERRAFORM_ROOT"
cd $TERRAFORM_ROOT

# cloud provider auth
echo "Terraform auth cloud provider"
bash $SCRIPTS_DIR/aws/sts.get-caller-identity.sh

# Set terraform version
echo "Using terraform version $TERRAFORM_VERSION"
ln -s /usr/local/bin/terraform-$TERRAFORM_VERSION /usr/local/bin/terraform

# always init first
echo "Running terraform init"
terraform init -input=false


if [ -n "$TERRAFORM_WORKSPACE" ]; then
  echo "Running Terraform Workspace"
  bash $SCRIPTS_DIR/terraform/terraform_workspace.sh $TERRAFORM_WORKSPACE
fi

if [ "${TERRAFORM_COMMAND}" == "plan" ]; then
  echo "Running Terraform Plan"
  bash $SCRIPTS_DIR/terraform/terraform_plan.sh "$BITOPS_CONFIG_COMMAND"
fi

if [ "${TERRAFORM_COMMAND}" == "apply" ] || [ "${TERRAFORM_APPLY}" == "true" ]; then
  # always plan first
  echo "Running Terraform Plan"
  bash $SCRIPTS_DIR/terraform/terraform_plan.sh "$BITOPS_CONFIG_COMMAND"

  # Only run terraform apply if there are changes in the plan
  if [ $? -eq 2 ]; then
    echo "Running Terraform Apply"
    bash $SCRIPTS_DIR/terraform/terraform_apply.sh "$BITOPS_CONFIG_COMMAND"
  fi
fi

if [ "${TERRAFORM_COMMAND}" == "destroy" ] || [ "${TERRAFORM_DESTROY}" == "true" ]; then
  # always plan first
  echo "Running Terraform Plan"
  bash $SCRIPTS_DIR/terraform/terraform_plan.sh "-destroy $BITOPS_CONFIG_COMMAND"
  
  # Only run terraform destroy if there are changes in the plan
  if [ $? -eq 2 ]; then
      bash $SCRIPTS_DIR/terraform/terraform_destroy.sh "$BITOPS_CONFIG_COMMAND"
  fi
fi

# Check for After Deploy Scripts
bash -x $SCRIPTS_DIR/deploy/after-deploy.sh "$TERRAFORM_ROOT"



