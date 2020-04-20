#!/usr/bin/env bash
set -x

##
## Environment Validation
##

# if this isn't a specific environment, exit
if [ -z "$ENVIRONMENT" ]; then
  echo "env var required: ENVIRONMENT"
  exit 1
fi


##
## Set up vars
##

# bitops paths
BITOPS_DIR="/opt/bitops"
SCRIPTS_DIR="$BITOPS_DIR/scripts"

# ops repo paths
ROOT_DIR="/bitops_deployment" # the operations repo should be mounted as a volume to `/bitops_deployment`
ENV_DIR="$ROOT_DIR/$ENVIRONMENT"



### Tools


# helm
if [ -d "$ENV_DIR/helm" ]; then

  # if subdirectory is not provided, iterate subdirectories
  if [ -z "$ENVIRONMENT_HELM_SUBDIRECTORY" ]; then
    echo "ENVIRONMENT_HELM_SUBDIRECTORY not provided, iterate all helm charts in $ENV_DIR/helm"
    for chart_dir in $ENV_DIR/helm/*/; do
      chart_dir=${chart_dir%*/}      # remove the trailing "/"
      chart_dir=${chart_dir##*/}    # get everything after the final "/"
      echo "Deploy $chart_dir for $ENVIRONMENT"
      $SCRIPTS_DIR/helm/deploy.sh $ROOT_DIR $ENVIRONMENT $chart_dir
    done
  else
    echo "ENVIRONMENT_HELM_SUBDIRECTORY: $ENV_DIR/helm/$ENVIRONMENT_HELM_SUBDIRECTORY"
    $SCRIPTS_DIR/helm/deploy.sh $ROOT_DIR $ENVIRONMENT $ENVIRONMENT_HELM_SUBDIRECTORY
  fi
fi


# Terraform
if [ -d "$ENV_DIR/helm" ]; then
  $SCRIPTS_DIR/terraform/deploy.sh
fi
