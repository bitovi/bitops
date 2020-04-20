#!/usr/bin/env bash

set -ex


if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "environment variable (AWS_ACCESS_KEY_ID) not set"
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "environment variable (AWS_ACCESS_KEY_ID) not set"
fi




##
## Set up parameters
##

# application root
ROOT_DIR="$1"

# Which environment to deploy
# this should correspond to a directory in the operations repo
# which should also be the current working directory
ENVIRONMENT="$2"

# directory of the helm chart (subdirectory of helm/)
HELM_SUBDIRECTORY="$3"





##
## Validation
##

# if this isn't a specific environment, exit
if [ -z "$ENVIRONMENT" ]; then
  echo "environment (second parameter) must be specified!"
  exit 1
fi

# if this isn't a specific subdirectory, exit
if [ -z "$HELM_SUBDIRECTORY" ]; then
  echo "subdirectory (third parameter) must be specified!"
  exit 1
fi


##
## Set up path vars
##

CHART_RELATIVE_PATH="$ENVIRONMENT/helm/$HELM_SUBDIRECTORY"
CHART_ROOT="$ROOT_DIR/$CHART_RELATIVE_PATH"
DEFAULT_CHART_ROOT="$ROOT_DIR/default/helm/$HELM_SUBDIRECTORY"
CHART_BITOPS_CONFIG="$CHART_ROOT/bitops.config.yaml"

# TODO: put these in the dockerfile?
BITOPS_DIR="/opt/bitops"
BITOPS_SCRIPTS_DIR="$BITOPS_DIR/scripts"


# TODO: extract details from $CHART_BITOPS_CONFIG
NAMESPACE="default"
TIMEOUT="500s"
HELM_DEBUG_COMMAND=""
if [ -f "$CHART_BITOPS_CONFIG" ]; then
  echo "TODO: extract details from $CHART_BITOPS_CONFIG"

  # TODO: reformat to use shyaml
  # echo "    checking for namespace in bitops config..."
  # yq_response=$(yq r $CHART_BITOPS_CONFIG namespace)
  # if [ "$yq_response" != "null" ] && [ -n "$yq_response" ]; then
  #   echo "    namespace found in bitops config. setting to $yq_response."
  #   NAMESPACE="$yq_response"
  # else
  #   echo "    namespace not found in bitops config. using $NAMESPACE."
  # fi

  # TODO: reformat to use shyaml
  # echo "    checking for timeout in bitops config..."
  # yq_response=$(yq r $CHART_BITOPS_CONFIG timeout)
  # if [ "$yq_response" != "null" ] && [ -n "$yq_response" ]; then
  #   echo "    timeout found in bitops config. setting to $yq_response."
  #   TIMEOUT="$yq_response"
  # else
  #   echo "    timeout not found in bitops config. using $TIMEOUT."
  # fi

  # TODO: reformat to use shyaml
  # echo "    checking for debug in bitops config..."
  # yq_response=$(yq r $CHART_BITOPS_CONFIG debug)
  # if [ "$yq_response" = "true" ]; then
  #   echo "    debug found in bitops config. setting debug flag for helm deployment."
  #   HELM_DEBUG_COMMAND="--debug"
  # fi
fi


##
## Set up vars from env
##

# if HELM_RELEASE_NAME not specified, set it to HELM_SUBDIRECTORY
if [ -z "$HELM_RELEASE_NAME" ]; then
  HELM_RELEASE_NAME="$HELM_SUBDIRECTORY"
fi

# set up option string for kube-context if env var is set
KUBECONFIG_CONTEXT_COMMAND_OPTION=""
if [ -e "$KUBECONFIG_CONTEXT" ]; then
  echo "KUBECONFIG_CONTEXT: $KUBECONFIG_CONTEXT"
  KUBECONFIG_CONTEXT_COMMAND_OPTION_HELM="--kube-context=\"$KUBECONFIG_CONTEXT\""
  KUBECONFIG_CONTEXT_COMMAND_OPTION="--context=\"$KUBECONFIG_CONTEXT\""
fi







#########################################
## Setup
#########################################
echo "making a temporary directory"
TEMPDIR=$( mktemp -d )
echo "temp: $TEMPDIR"

#########################################
## Teardown
#########################################
cleanup () {

  echo "cleaning up..."
  local tmpdir=$1
  echo $TEMPDIR

  echo "removing temporary directory: $TEMPDIR"
  rm -rf $TEMPDIR
}
trap "{ cleanup $TEMPDIR; }" EXIT






# prep the deployment.  setup should do the following:
#     - move all env helm files ($CHART_ROOT) to $TEMPDIR
#     - decode $KUBECONFIG_BASE64 into $TEMPDIR/kube/config
#     - decode $HELM_SECRETS_FILE_BASE64 into $TEMPDIR/values-secrets.yaml
$BITOPS_SCRIPTS_DIR/helm/setup.sh $TEMPDIR $CHART_ROOT

##
## Set up parameters from setup.sh
##

# static stuff
CHART_ROOT="$TEMPDIR"
KUBECONFIG="$TEMPDIR/kube/config"
VALUES_FILE_PATH="$CHART_ROOT/values.yaml"
if [ ! -f "$VALUES_FILE_PATH" ]; then
  echo "Must include a versions file for $CHART_RELATIVE_PATH"
fi

# Handle secrets file
VALUES_SECRETS_FILE_PATH="$CHART_ROOT/values-secrets.yaml"
echo "Checking existence of secrets file ($VALUES_SECRETS_FILE_PATH)"
VALUES_SECRETS_FILE_COMMAND=""
if [ -f "$VALUES_SECRETS_FILE_PATH" ]; then
  echo "secrets file exists.  Including it in deployment."
  VALUES_SECRETS_FILE_COMMAND="-f $VALUES_SECRETS_FILE_PATH"
else
  echo "versions file does not exist. Skipping."
fi

# Handle versions files
VALUES_VERSIONS_FILE_PATH="$CHART_ROOT/values-versions.yaml"
echo "Checking existence of versions file ($VALUES_VERSIONS_FILE_PATH)"
VALUES_VERSIONS_FILE_COMMAND=""
if [ -f "$VALUES_VERSIONS_FILE_PATH" ]; then
  echo "versions file exists.  Including it in deployment."
  VALUES_VERSIONS_FILE_COMMAND="-f $VALUES_VERSIONS_FILE_PATH"
else
  echo "versions file does not exist. Skipping."
fi



###
### copy from default
###
echo "copy defaults..."

# crds/ directory from default directory
echo "  crds/ ($DEFAULT_CHART_ROOT/crds): $COPY_DEFAULT_CRDS"
if [ -n "$COPY_DEFAULT_CRDS" ]; then
  echo "COPY_DEFAULT_CRDS set"
  if [ -d $DEFAULT_CHART_ROOT/crds ]; then
    echo "    default crds/ exist"
    # TODO: handle if $CHART_ROOT/crds already exists (merge vs overwrite)?
    cp -rf $DEFAULT_CHART_ROOT/crds $CHART_ROOT
  else
    echo "    crds/ does not exist"
  fi
else
  echo "COPY_DEFAULT_CRDS not set"
fi

# TODO: charts/
# TODO: templates/
# TODO: values.schema.json
# TODO: namespace.yaml
# TODO: kubefiles/




###
### Additional values files ($CHART_ROOT/values-files)
###

# Handle additional values files
echo "Checking existence of additional values files ($CHART_ROOT/values-files)"
ADDITIONAL_VALUES_FILES_COMMAND=""
if [ -d "$ADDITIONAL_VALUES_FILES_PATH" ]; then
  echo "Additional values files exist."
  echo "Iterating $ADDITIONAL_VALUES_FILES_PATH:"
  ls $ADDITIONAL_VALUES_FILES_PATH
  echo ""
  for vf in $ADDITIONAL_VALUES_FILES_PATH/*; do
    echo "values-file: $vf"
    ADDITIONAL_VALUES_FILES_COMMAND="$ADDITIONAL_VALUES_FILES_COMMAND -f $vf"
  done
else
  echo "Aditional values files do not exist. Skipping."
fi


echo "cd $CHART_ROOT"
cd $CHART_ROOT

echo "update helm dependencies for $CHART_ROOT"
helm dependency up "$(pwd)" $HELM_DEBUG_COMMAND 






k="kubectl --kubeconfig $KUBECONFIG $KUBECONFIG_CONTEXT_COMMAND_OPTION"

# TODO: check if namespace exists



# helm \
#   upgrade \
#   $HELM_RELEASE_NAME \
#   . \
#   --install \
#   --timeout="$TIMEOUT" \
#   --cleanup-on-fail \
#   --kubeconfig="$KUBECONFIG" \
#   --namespace="$NAMESPACE" \
#   $HELM_DEBUG_COMMAND \
#   $DEFAULT_VALUES_FILE_COMMAND \
#   $DEFAULT_VALUES_VERSIONS_FILE_COMMAND \
#   -f $VALUES_FILE_PATH \
#   $VALUES_VERSIONS_FILE_COMMAND \
#   $VALUES_SECRETS_FILE_COMMAND \
#   $ADDITIONAL_VALUES_FILES_COMMAND