#!/usr/bin/env bash
set -xe

# Global vars
export PATH=/root/.local/bin:$PATH
export ENVROOT="$TEMPDIR/$ENVIRONMENT"
export BITOPS_DIR="/opt/bitops"
export SCRIPTS_DIR="$BITOPS_DIR/scripts"

# Logging
export ERROR='\033[0;31m'
export SUCCESS='\033[0;32m'
export WARN='\033[1;33m'
export NC='\033[0m'


###
### Global Validation
###
if [ -z "$ENVIRONMENT" ]; then
  printf "${ERROR}environment variable (ENVIRONMENT) not set ${NC}"
  exit 1
fi
if [ -z "$DEBUG" ]; then
  echo "environment variable (DEBUG) not set"
  export DEBUG=0
fi

# TODO: these should be put in their proper 'plugin' folders
if [ -z "$CLUSTER_NAME" ]; then
  echo "environment variable (CLUSTER_NAME) not set "
  CREATE_CLUSTER=true
fi
if [ -z "$KUBECONFIG_BASE64" ]; then
  echo "environment variable (KUBECONFIG_BASE64) not set"
fi




###
### Setup
###
echo "making a temporary directory"
export TEMPDIR=$( mktemp -d )
echo "TEMPDIR: $TEMPDIR"

###
### Teardown
###
cleanup () {
  # call all teardown scripts
  /bin/bash $SCRIPTS_DIR/aws/teardown.sh


  echo "cleaning up..."
  local tmpdir=$1
  echo $TEMPDIR

  echo "removing temporary directory: $TEMPDIR"
  rm -rf $TEMPDIR

  printf "BitOps Completed.${NC}"
}
trap "{ cleanup $TEMPDIR; }" EXIT


# put everything in the temp directory
if ! cp -rf /opt/bitops_deployment/. $TEMPDIR; then 
  echo "failed to copy repo to: $TEMPDIR"
else 
  echo "Successfully Copied repo to $TEMPDIR "
fi

# ops repo paths
export ROOT_DIR="$TEMPDIR"
export ENVROOT="$ROOT_DIR/$ENVIRONMENT"




# Setup bashrc
if [ ! -f !/.bashrc ]; then
  echo "#!/usr/bin/env bash" > ~/.bashrc
  echo "" >> ~/.bashrc
fi
echo "$PATH" >> ~/.bashrc


# Setup AWS profile
/bin/bash $SCRIPTS_DIR/aws/setup.sh

# Setup kubeconfig
bash $SCRIPTS_DIR/kubectl/kubeconfig_base64_decode.sh
export KUBE_CONFIG_FILE="$TEMPDIR/.kube/config"



# Run Tests
echo "Running tests"
if [ -n "$TEST" ]; then
  printf "${SUCCESS} all arguments parsed successfully. Exiting... ${NC}" 
  # Todo: Add more tests.

  exit 0
fi



echo "Running deployments"




# run terraform (should be first)
if [ -d "$ENVROOT/terraform" ]; then
  echo "calling terraform/deploy ..."
  bash $SCRIPTS_DIR/terraform/deploy.sh
fi

# run ansible (should be after terraform and before helm)
if [ -d "$ENVROOT/ansible" ]; then
  echo "calling ansible/deploy ..."
  bash $SCRIPTS_DIR/ansible/deploy.sh
fi

# run helm (should be after terraform and ansible)
if [ -d "$ENVROOT/helm" ]; then
  echo "calling helm/deploy ..."
  bash $SCRIPTS_DIR/helm/deploy.sh
fi




