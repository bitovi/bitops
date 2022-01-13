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

function run_create_s3_bucket () {
  # OPTIONAL FEATURES CAN BE PLACED INTO HERE
  if [[ $CFN_CREATE_BUCKET == true ]] || [[ $CFN_CREATE_BUCKET == True ]]; then
    aws s3api create-bucket --bucket "$CFN_TEMPLATE_S3_BUCKET" --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION || true
  fi
}

function run_config_validation () {
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

function run_s3_sync_templates () {
    CLOUDFORMATION_ROOT=$CLOUDFORMATION_ROOT/templates
    CFN_S3_PREFIX_READONLY=$CFN_S3_PREFIX
    
    CFN_TEMPLATE_FILENAME="templates"
    run_config_conversion
    CFN_S3_PREFIX="$CFN_S3_PREFIX/templates"

    # Check if template folder exists
    if [[ -d $CLOUDFORMATION_ROOT ]]; then

      run_s3_sync 
    else
      echo "A default template folder was not detected. It's recommended you add one when using multi-regional deployments."
    fi

    CLOUDFORMATION_ROOT=$CLOUDFORMATION_ROOT_READONLY
    CFN_S3_PREFIX=$CFN_S3_PREFIX_READONLY
}

function run_s3_sync () {
  # CFN_TEMPLATE_PARAM="--template-body=file://$CFN_TEMPLATE_FILENAME"

  if [[ $MULTI_REGION_DEPLOY == "true" ]] || [[ $MULTI_REGION_DEPLOY == "True" ]]; then
    CFN_S3_PREFIX="$CFN_S3_PREFIX/$AWS_DEFAULT_REGION"
    echo "Sync with prefix + region"
  fi
  
  if [ -n "$CFN_TEMPLATE_S3_BUCKET" ] && [ -n "$CFN_S3_PREFIX" ]; then
    echo "CFN_TEMPLATE_S3_BUCKET is set, syncing operations repo with S3..."
    echo "Syncing to: [s3://$CFN_TEMPLATE_S3_BUCKET/$CFN_S3_PREFIX/]"
    aws s3 sync $CLOUDFORMATION_ROOT s3://$CFN_TEMPLATE_S3_BUCKET/$CFN_S3_PREFIX/
    if [ $? == 0 ]; then
      echo "Upload to S3 successful..."
      CFN_TEMPLATE_PARAM="--template-url https://$CFN_TEMPLATE_S3_BUCKET.s3.amazonaws.com/$CFN_S3_PREFIX/$CFN_TEMPLATE_FILENAME"
    else
      echo "Upload to S3 failed"
    fi
  fi
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

run_copy_multideploy_parameters () { 
  mv $CLOUDFORMATION_ROOT/parameters.json $CLOUDFORMATION_ROOT/parameters-old.json
  cp $CLOUDFORMATION_ROOT_READONLY/parameters.json $CLOUDFORMATION_ROOT/parameters.json
}


function run_predeployment () {
  # Load config file
  run_config_conversion

  # Creating S3 bucket
  run_create_s3_bucket

  # Sync the current files to the S3 bucket
  run_s3_sync

  # Run before scripts
  run_before_scripts

  # Validate config file
  run_config_validation
}


function run_deployment () {
  # Combine anything in the parameters folder
  run_combine_parameters

  # Log in to the aws identity
  run_aws_get_identity

  # Validate the stack yaml
  run_config_validation_stack_action

  # Deploy the stack
  run_deploy_stack_action
  
  run_delete_stack_action

  # Run after scripts
  run_after_scripts
}


# ~ # ~ # ~ SCRIPT START ~ # ~ # ~ # 

# cloudformation vars
export CLOUDFORMATION_ROOT_READONLY="$ENVROOT/cloudformation"
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

multi_region_targets="$(bash "$SCRIPTS_DIR/bitops-config/get.sh" "$CLOUDFORMATION_BITOPS_CONFIG" "cloudformation.multi-regional-target-regions" "")"

if [[ -n $multi_region_targets ]]; then
  # ~ # ~ MULTI REGION ~ # ~ # 
  echo "Using Multi-Regional deployment strategy"

  # sync the templates folder
  run_s3_sync_templates
  export MULTI_REGION_DEPLOY="true"
  
  for region in $(echo $multi_region_targets);do
    if [[ $region == "-" ]]; then
      # This accounts for the regions being in a list 
      continue
    
    else
    
      echo "Processing region: [$region]"
      CLOUDFORMATION_ROOT=$CLOUDFORMATION_ROOT_READONLY
      CLOUDFORMATION_ROOT_MULTIREGION="$CLOUDFORMATION_ROOT/$region"
      CLOUDFORMATION_ROOT=$CLOUDFORMATION_ROOT_MULTIREGION
      CLOUDFORMATION_BITOPS_CONFIG="$CLOUDFORMATION_ROOT_MULTIREGION/bitops.config.yaml"   
      BITOPS_SCHEMA_ENV_FILE="$CLOUDFORMATION_ROOT_MULTIREGION/ENV_FILE"
      BITOPS_CONFIG_SCHEMA="$SCRIPTS_DIR/cloudformation/bitops.schema.yaml"
      export AWS_DEFAULT_REGION=$region


      run_predeployment

      cd $CLOUDFORMATION_ROOT_MULTIREGION

      run_copy_multideploy_parameters

      run_deployment
    fi
  done

  else
    # ~ # ~ DEFAULT SINGLE REGION ~ # ~ # 
    echo "Using Default deployment strategy"

    run_predeployment

    cd $CLOUDFORMATION_ROOT

    run_deployment
fi