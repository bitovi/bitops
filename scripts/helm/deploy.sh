#!/usr/bin/env bash

set -ex

# helm vars
export HELM_RELEASE_NAME=""
export HELM_DEBUG_COMMAND=""
export HELM_DEPLOY=${HELM_CHARTS:=false}


# validation and defaults
if [ -z "$NAMESPACE" ]; then
  echo "environment variable (NAMESPACE) not set"
  export NAMESPACE="default"
fi
if [ -z "$TIMEOUT" ]; then
  echo "environment variable (TIMEOUT) not set"
  export TIMEOUT="500s"
fi



if [[ ${HELM_DEPLOY} == "true" ]];then
    echo "Installing Helm Charts"
    bash $SCRIPTS_DIR/helm/helm_install_charts.sh
fi 

if [ -z "$EXTERNAL_HELM_CHARTS" ]; then 
    echo "EXTERNAL_HELM_CHARTS directory not set."
else
    echo "Running External Helm Charts."
    bash -x $SCRIPTS_DIR/helm/helm_install_external_charts.sh
fi

if [ -z "$HELM_CHARTS_S3" ]; then
    echo "HELM_CHARTS_S3 not set."
else
    echo "Adding S3 Helm Repo."
    bash -x $SCRIPTS_DIR/helm/helm_install_charts_from_s3.sh 
fi
