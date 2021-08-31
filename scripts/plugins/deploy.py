#!/usr/bin/env bash
set -e
if [ "$DEBUG" = true ]; then
  set -x
fi

# Logging
export ERROR='\033[0;31m'
export SUCCESS='\033[0;32m'
export WARN='\033[1;33m'
export NC='\033[0m'
export PATH=$PATH:/usr/local/bin
export TIMEOUT="${WAIT_TIMEOUT:-600}"

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


# Global vars
export PATH=/root/.local/bin:$PATH
export ENVROOT="$TEMPDIR/$ENVIRONMENT"
export BITOPS_DIR="/opt/bitops"
export SCRIPTS_DIR="$BITOPS_DIR/scripts"
export KUBE_CONFIG_FILE="$TEMPDIR/.kube/config"
export PLUGINS_DIR="$BITOPS_DIR/scripts/plugins"


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



# put everything in the temp directory
if ! cp -rf /opt/bitops_deployment/. $TEMPDIR; then 
  echo "failed to copy repo to: $TEMPDIR"
else 
  echo "Successfully Copied repo to $TEMPDIR "
fi

if [ -z "$DEFAULT_FOLDER_NAME" ]; then
  DEFAULT_FOLDER_NAME="default"
fi

# ops repo paths
export ROOT_DIR="$TEMPDIR"
export ENVROOT="$ROOT_DIR/$ENVIRONMENT"
export DEFAULT_ENVROOT="$ROOT_DIR/$DEFAULT_FOLDER_NAME"


# Setup bashrc
if [ ! -f !/.bashrc ]; then
  echo "#!/usr/bin/env bash" > ~/.bashrc
  echo "" >> ~/.bashrc
fi
echo "$PATH" >> ~/.bashrc

# Run plugins
python $SCRIPTS_DIR/plugins/deploy.py