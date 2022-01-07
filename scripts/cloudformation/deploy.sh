#!/usr/bin/env bash
set -e


# Functions
function run_before_scripts () {
  # Check for Before Deploy Scripts
  bash $SCRIPTS_DIR/deploy/before-deploy.sh "$CLOUDFORMATION_ROOT"
}

function run_config_conversion () {
  export BITOPS_CONFIG_COMMAND="$(ENV_FILE="$BITOPS_SCHEMA_ENV_FILE" DEBUG="" bash $SCRIPTS_DIR/bitops-config/convert-schema.sh $BITOPS_CONFIG_SCHEMA $CLOUDFORMATION_BITOPS_CONFIG)"
  echo "BITOPS_CONFIG_COMMAND: $BITOPS_CONFIG_COMMAND"
  echo "BITOPS_SCHEMA_ENV_FILE: $(cat $BITOPS_SCHEMA_ENV_FILE)"
  source "$BITOPS_SCHEMA_ENV_FILE"
}

function run_schema_validation () {
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
}

function run_combine_parameters () {
  # Combine parameters
  if [[ "$CFN_MERGE_PARAMETER" == "true" ]] || [[ "$CFN_MERGE_PARAMETER" == "True" ]]; then
    echo "Combining json files in $CFN_MERGE_DIRECTORY folder"
    # All files in the $CFN_MERGE_DIRECTORY will be merged into the $CFN_TEMPLATE_PARAMS_FILENAME, if $CFN_TEMPLATE_PARAMS_FILENAME is unset it will use parameters.json
    COMBINE_FILES=
    for filename in $(ls $CLOUDFORMATION_ROOT/$CFN_MERGE_DIRECTORY); do
      COMBINE_FILES+="$CLOUDFORMATION_ROOT/$CFN_MERGE_DIRECTORY/$filename "
    done;
    jq '.[]' $COMBINE_FILES | jq -s . > $CFN_TEMPLATE_PARAMS_FILENAME
  fi
}

function run_aws_get_identity () {
  echo "cloudformation auth cloud provider"
  bash $SCRIPTS_DIR/aws/sts.get-caller-identity.sh
}

function run_config_validation_stack_action () {
  if [[ "${CFN_TEMPLATE_VALIDATION}" == "True" ]] || [[ "${CFN_TEMPLATE_VALIDATION}" == "true" ]]; then
    echo "Running Cloudformation Template Validation : [$CFN_TEMPLATE_FILENAME]"
    bash $SCRIPTS_DIR/cloudformation/cloudformation_validate.sh "$CFN_TEMPLATE_FILENAME"
  fi
}

function run_deploy_stack_action () {
  if [[ "${CFN_STACK_ACTION}" == "deploy" ]] || [[ "${CFN_STACK_ACTION}" == "Deploy" ]]; then
    echo "Running Cloudformation Deploy Stack"
    bash $SCRIPTS_DIR/cloudformation/cloudformation_deploy.sh "$CFN_TEMPLATE_FILENAME" "$CFN_PARAMS_FLAG" "$CFN_TEMPLATE_PARAMS_FILENAME" "$CFN_STACK_NAME" "$CFN_CAPABILITY" "$CFN_TEMPLATE_S3_BUCKET" "$CFN_S3_PREFIX"
  fi
}

function run_delete_stack_action () {
  if [[ "${CFN_STACK_ACTION}" == "delete" ]] || [[ "${CFN_STACK_ACTION}" == "Delete" ]]; then
    echo "Running Cloudformation Delete Stack"
    bash $SCRIPTS_DIR/cloudformation/cloudformation_delete.sh "$CFN_STACK_NAME"
  fi
}

function run_after_scripts () {
  # Check for After Deploy Scripts
  bash $SCRIPTS_DIR/deploy/after-deploy.sh "$CLOUDFORMATION_ROOT"
}



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

v="$(bash "$SCRIPTS_DIR/bitops-config/get.sh" "$CLOUDFORMATION_BITOPS_CONFIG" "bitops.multi-regional-target-regions" "")"

if [[ -n $v ]]; then
  echo "Using Multi-Regional deployment strategy"

  for i in $(echo $v | tr " " "\n"); do
    echo "Processing region: [$i]"
    CLOUDFORMATION_ROOT_MULTIREGION="$CLOUDFORMATION_ROOT/$i"
    CLOUDFORMATION_BITOPS_CONFIG="$CLOUDFORMATION_ROOT_MULTIREGION/bitops.config.yaml"   
    BITOPS_SCHEMA_ENV_FILE="$CLOUDFORMATION_ROOT_MULTIREGION/ENV_FILE"
    BITOPS_CONFIG_SCHEMA="$SCRIPTS_DIR/cloudformation/bitops.schema.yaml"

    echo "$CLOUDFORMATION_ROOT_MULTIREGION    |    $CLOUDFORMATION_BITOPS_CONFIG    |    $BITOPS_SCHEMA_ENV_FILE    |    $BITOPS_CONFIG_SCHEMA"

    run_before_scripts
    run_config_conversion
    run_schema_validation

    cd $CLOUDFORMATION_ROOT_MULTIREGION
    export AWS_DEFAULT_REGION=$i

    run_combine_parameters
    run_aws_get_identity

    run_config_validation_stack_action

    run_deploy_stack_action
    run_delete_stack_action

    run_after_scripts
  done

  else
    echo "Using Default deployment strategy"
    run_before_scripts
    run_config_conversion
    run_schema_validation

    cd $CLOUDFORMATION_ROOT

    run_combine_parameters
    run_aws_get_identity

    run_config_validation_stack_action

    run_deploy_stack_action
    run_delete_stack_action

    run_after_scripts
fi

# # Check for Before Deploy Scripts
# bash $SCRIPTS_DIR/deploy/before-deploy.sh "$CLOUDFORMATION_ROOT"


# export BITOPS_CONFIG_COMMAND="$(ENV_FILE="$BITOPS_SCHEMA_ENV_FILE" DEBUG="" bash $SCRIPTS_DIR/bitops-config/convert-schema.sh $BITOPS_CONFIG_SCHEMA $CLOUDFORMATION_BITOPS_CONFIG)"
# echo "BITOPS_CONFIG_COMMAND: $BITOPS_CONFIG_COMMAND"
# echo "BITOPS_SCHEMA_ENV_FILE: $(cat $BITOPS_SCHEMA_ENV_FILE)"
# source "$BITOPS_SCHEMA_ENV_FILE"

# # Exit if Stack Name not found
# if [[ "${CFN_STACK_NAME=}" == "" ]] || [[ "${CFN_STACK_NAME=}" == "''" ]] || [[ "${CFN_STACK_NAME=}" == "None" ]]; then
#   >&2 echo "{\"error\":\"$CFN_STACK_NAME config is required in bitops config.Exiting...\"}"
#   exit 1
# fi

# # Exit if CFN Template Filename is not found
# if [[ "${CFN_TEMPLATE_FILENAME==}" == "" ]] || [[ "${CFN_TEMPLATE_FILENAME==}" == "''" ]] || [[ "${CFN_TEMPLATE_FILENAME==}" == "None" ]]; then
#   >&2 echo "{\"error\":\"$CFN_TEMPLATE_FILENAME config is required in bitops config.Exiting...\"}"
#   exit 1
# fi

# # Exit if CFN Template Parameters Filename is not found
# if [[ "${CFN_PARAMS_FLAG}" == "True" ]] || [[ "${CFN_PARAMS_FLAG}" == "true" ]]; then
#   if [[ "${CFN_TEMPLATE_PARAMS_FILENAME}" == "" ]] || [[ "${CFN_TEMPLATE_PARAMS_FILENAME}" == "''" ]] || [[ "${CFN_TEMPLATE_PARAMS_FILENAME}" == "None" ]]; then
#     >&2 echo "{\"error\":\"$CFN_TEMPLATE_FILENAME config is required in bitops config.Exiting...\"}"
#     exit 1
#   fi
# fi

# echo "cd cloudformation Root: $CLOUDFORMATION_ROOT"
# cd $CLOUDFORMATION_ROOT

# # Combine parameters
# if [[ "$CFN_MERGE_PARAMETER" == "true" ]] || [[ "$CFN_MERGE_PARAMETER" == "True" ]]; then
#   echo "Combining json files in $CFN_MERGE_DIRECTORY folder"
#   # All files in the $CFN_MERGE_DIRECTORY will be merged into the $CFN_TEMPLATE_PARAMS_FILENAME, if $CFN_TEMPLATE_PARAMS_FILENAME is unset it will use parameters.json
#   COMBINE_FILES=
#   for filename in $(ls $CLOUDFORMATION_ROOT/$CFN_MERGE_DIRECTORY); do
#     COMBINE_FILES+="$CLOUDFORMATION_ROOT/$CFN_MERGE_DIRECTORY/$filename "
#   done;
#   jq '.[]' $COMBINE_FILES | jq -s . > $CFN_TEMPLATE_PARAMS_FILENAME
# fi

# # cloud provider auth
# echo "cloudformation auth cloud provider"
# bash $SCRIPTS_DIR/aws/sts.get-caller-identity.sh

# always run cfn template validation first
# if [[ "${CFN_TEMPLATE_VALIDATION}" == "True" ]] || [[ "${CFN_TEMPLATE_VALIDATION}" == "true" ]]; then
#   echo "Running Cloudformation Template Validation"
#   bash $SCRIPTS_DIR/cloudformation/cloudformation_validate.sh "$CFN_TEMPLATE_FILENAME"
# fi

# if [[ "${CFN_STACK_ACTION}" == "deploy" ]] || [[ "${CFN_STACK_ACTION}" == "Deploy" ]]; then
#   echo "Running Cloudformation Deploy Stack"
#   bash $SCRIPTS_DIR/cloudformation/cloudformation_deploy.sh "$CFN_TEMPLATE_FILENAME" "$CFN_PARAMS_FLAG" "$CFN_TEMPLATE_PARAMS_FILENAME" "$CFN_STACK_NAME" "$CFN_CAPABILITY" "$CFN_TEMPLATE_S3_BUCKET" "$CFN_S3_PREFIX"
# fi

# if [[ "${CFN_STACK_ACTION}" == "delete" ]] || [[ "${CFN_STACK_ACTION}" == "Delete" ]]; then
#   echo "Running Cloudformation Delete Stack"
#   bash $SCRIPTS_DIR/cloudformation/cloudformation_delete.sh "$CFN_STACK_NAME"
# fi


# Check for After Deploy Scripts
# bash $SCRIPTS_DIR/deploy/after-deploy.sh "$CLOUDFORMATION_ROOT"