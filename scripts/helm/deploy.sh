#!/usr/bin/env bash

set -ex

# helm vars
export HELM_RELEASE_NAME=""
export HELM_DEBUG_COMMAND=""
export HELM_DEPLOY=${HELM_CHARTS:=false}
export HELM_ROOT="$ENVROOT/helm" 
export DEFAULT_HELM_ROOT="$DEFAULT_ENVROOT/helm" 

# if subdirectory is not provided, iterate subdirectories
if [ -z "$ENVIRONMENT_HELM_SUBDIRECTORY" ]; then
  echo "ENVIRONMENT_HELM_SUBDIRECTORY not provided, iterate all helm charts in $ENV_DIR/helm"
  for helm_chart_dir in $HELM_ROOT/*/; do
    helm_chart_dir=${helm_chart_dir%*/}      # remove the trailing "/"
    helm_chart_dir=${helm_chart_dir##*/}    # get everything after the final "/"
    echo "Deploy $helm_chart_dir for $ENVIRONMENT"
    $SCRIPTS_DIR/helm/deploy-chart.sh $helm_chart_dir
  done
else
  echo "ENVIRONMENT_HELM_SUBDIRECTORY: $ENV_DIR/helm/$ENVIRONMENT_HELM_SUBDIRECTORY"
  $SCRIPTS_DIR/helm/deploy-chart.sh $ENVIRONMENT_HELM_SUBDIRECTORY
fi

