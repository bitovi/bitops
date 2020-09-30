#!/usr/bin/env bash
set -e

# cloudformation vars
export CLOUDFORMATION_ROOT="$ENVROOT/cloudformation" 
export CLOUDFORMATION_BITOPS_CONFIG="$CLOUDFORMATION_ROOT/bitops.config.yaml" 
export BITOPS_SCHEMA_ENV_FILE="$CLOUDFORMATION_ROOT/ENV_FILE"
export BITOPS_CONFIG_SCHEMA="$SCRIPTS_DIR/cloudformation/bitops.schema.yaml"


if [ ! -d "$CLOUDFORMATION_ROOT" ]; then
  echo "No cloudformation directory.  Skipping."
  exit 0
else
  printf "Deploying cloudformation... ${NC}"
fi


if [ -f "$CLOUDFORMATION_BITOPS_CONFIG" ]; then
  echo "cloudformation - Found BitOps config"
else
  echo "cloudformation - No BitOps config"
fi

# Check for Before Deploy Scripts
bash -x $SCRIPTS_DIR/deploy/before-deploy.sh "$CLOUDFORMATION_ROOT"

export BITOPS_CONFIG_COMMAND="$(ENV_FILE="$BITOPS_SCHEMA_ENV_FILE" DEBUG="" bash $SCRIPTS_DIR/bitops-config/convert-schema.sh $BITOPS_CONFIG_SCHEMA $CLOUDFORMATION_BITOPS_CONFIG)"
echo "BITOPS_CONFIG_COMMAND: $BITOPS_CONFIG_COMMAND"
echo "BITOPS_SCHEMA_ENV_FILE: $(cat $BITOPS_SCHEMA_ENV_FILE)"
source "$BITOPS_SCHEMA_ENV_FILE"

# Exit if Stack Name not found
if [[ "${CFN_STACK_NAME=}" == "" ]] || [[ "${CFN_STACK_NAME=}" == "''" ]] || [[ "${CFN_STACK_NAME=}" == "None" ]]; then
  >&2 echo "{\"error\":\"$CFN_STACK_NAME config is required in bitops config.Exiting...\"}"
  exit 1
fi

# Exit if CFN Template Filename is not found
if [[ "${CFN_TEMPLATE_FILENAME==}" == "" ]] || [[ "${CFN_TEMPLATE_FILENAME==}" == "''" ]] || [[ "${CFN_TEMPLATE_FILENAME==}" == "None" ]]; then
  >&2 echo "{\"error\":\"$CFN_TEMPLATE_FILENAME config is required in bitops config.Exiting...\"}"
  exit 1
fi

# Exit if CFN Template Parameters Filename is not found
if [[ "${CFN_PARAMS_FLAG}" == "True" ]] || [[ "${CFN_PARAMS_FLAG}" == "true" ]]; then
  if [[ "${CFN_TEMPLATE_PARAMS_FILENAME}" == "" ]] || [[ "${CFN_TEMPLATE_PARAMS_FILENAME}" == "''" ]] || [[ "${CFN_TEMPLATE_PARAMS_FILENAME}" == "None" ]]; then
    >&2 echo "{\"error\":\"$CFN_TEMPLATE_FILENAME config is required in bitops config.Exiting...\"}"
    exit 1
  fi
fi

echo "cd cloudformation Root: $CLOUDFORMATION_ROOT"
cd $CLOUDFORMATION_ROOT

# cloud provider auth
echo "cloudformation auth cloud provider"
bash $SCRIPTS_DIR/aws/sts.get-caller-identity.sh

# always run cfn template validation first
if [[ "${CFN_TEMPLATE_VALIDATION}" == "True" ]] || [[ "${CFN_TEMPLATE_VALIDATION}" == "true" ]]; then
  echo "Running Cloudformation Template Validation"
  bash $SCRIPTS_DIR/cloudformation/cloudformation_validate.sh "$CFN_TEMPLATE_FILENAME"
fi

if [[ "${CFN_STACK_ACTION}" == "deploy" ]] || [[ "${CFN_STACK_ACTION}" == "Deploy" ]]; then
  echo "Running Cloudformation Deploy Stack"
  bash $SCRIPTS_DIR/cloudformation/cloudformation_deploy.sh "$CFN_TEMPLATE_FILENAME" "$CFN_PARAMS_FLAG" "$CFN_TEMPLATE_PARAMS_FILENAME" "$CFN_STACK_NAME" "$CFN_CAPABILITY"
fi

if [[ "${CFN_STACK_ACTION}" == "delete" ]] || [[ "${CFN_STACK_ACTION}" == "Delete" ]]; then
  echo "Running Cloudformation Delete Stack"
  bash $SCRIPTS_DIR/cloudformation/cloudformation_delete.sh "$CFN_STACK_NAME"
fi

# Check for After Deploy Scripts
bash -x $SCRIPTS_DIR/deploy/after-deploy.sh "$CLOUDFORMATION_ROOT"