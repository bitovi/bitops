#!/usr/bin/env bash

set -ex

HELM_CHART="$1"
HELM_CHART_DIRECTORY="$HELM_ROOT/$HELM_CHART"
DEFAULT_HELM_CHART_DIRECTORY="$DEFAULT_HELM_ROOT/$HELM_CHART"
HELM_BITOPS_CONFIG="$HELM_CHART_DIRECTORY/bitops.config.yaml" 
BITOPS_CONFIG_SCHEMA="$SCRIPTS_DIR/helm/bitops.schema.yaml"
BITOPS_SCHEMA_ENV_FILE="$HELM_CHART_DIRECTORY/ENV_FILE"
IMG_REPO=""

echo "Installing charts..."

output_schema_env () {
    echo "Schema ENV"
    cat "$BITOPS_SCHEMA_ENV_FILE"
}
on_exit () {
    output_schema_env
}
trap "{ on_exit; }" EXIT

BITOPS_CONFIG_COMMAND="$(ENV_FILE="$BITOPS_SCHEMA_ENV_FILE" DEBUG="" bash $SCRIPTS_DIR/bitops-config/convert-schema.sh $BITOPS_CONFIG_SCHEMA $HELM_BITOPS_CONFIG)"
echo "BITOPS_CONFIG_COMMAND: $BITOPS_CONFIG_COMMAND"
source "$BITOPS_SCHEMA_ENV_FILE"

# set kube config
if [[ "${FETCH_KUBECONFIG}" == "True" ]]; then
  if [[ "${CLUSTER_NAME}" == "None" ]]; then
    >&2 echo "{\"error\":\"CLUSTER_NAME variable is required\"}"
    exit 1
  else
        # always get the kubeconfig (whether or not we applied)
        echo "Attempting to fetch KUBECONFIG from cloud provider..."
        CLUSTER_NAME="$CLUSTER_NAME" \
        KUBECONFIG="$KUBE_CONFIG_FILE" \
        bash $SCRIPTS_DIR/aws/eks.update-kubeconfig.sh
        export KUBECONFIG=$KUBECONFIG:$KUBE_CONFIG_FILE
  fi
else
    >&2 echo "{\"error\":\"FETCH_KUBECONFIG variable mandatory in bitops.config.yaml\"}"
    exit 1
fi

echo "call validate_env with NAMESPACE: $NAMESPACE"
NAMESPACE="$NAMESPACE" \
bash $SCRIPTS_DIR/helm/validate_env.sh

# Check for Before Deploy Scripts
bash -x $SCRIPTS_DIR/deploy/before-deploy.sh $HELM_CHART_DIRECTORY


# Initialize values files

VALUES_FILE_PATH="$HELM_CHART_DIRECTORY/values.yaml"
DEFAULT_VALUES_FILE_PATH="$DEFAULT_HELM_CHART_DIRECTORY/values.yaml"
VALUES_SECRETS_FILE_PATH="$HELM_CHART_DIRECTORY/values-secrets.yaml"

VALUES_VERSIONS_FILE_PATH="$HELM_CHART_DIRECTORY/values-versions.yaml"
DEFAULT_VALUES_VERSIONS_FILE_PATH="$DEFAULT_HELM_CHART_DIRECTORY/values-versions.yaml"

ADDITIONAL_VALUES_FILES_PATH="$HELM_CHART_DIRECTORY/values-files"
DEFAULT_ADDITIONAL_VALUES_FILES_PATH="$DEFAULT_HELM_CHART_DIRECTORY/values-files"


### COPY DEFAULTS
HELM_CHART_DIRECTORY="$HELM_CHART_DIRECTORY" \
DEFAULT_HELM_CHART_DIRECTORY="$DEFAULT_HELM_CHART_DIRECTORY" \
HELM_BITOPS_CONFIG="$HELM_BITOPS_CONFIG" \
bash -x $SCRIPTS_DIR/helm/copy-defaults.sh "$HELM_CHART"


# TODO: fix below here

VALUES_FILES_ORDER="
$DEFAULT_VALUES_FILE_PATH
$VALUES_FILE_PATH
$VALUES_VERSIONS_FILE_PATH
$VALUES_SECRETS_FILE_PATH
"
# Initialize values command.
MAIN_VALUES_FILES_COMMAND=""
for values_file in $VALUES_FILES_ORDER; do
    if [ -e "$values_file" ] && [[ -s "$values_file" ]]; then
        MAIN_VALUES_FILES_COMMAND="$MAIN_VALUES_FILES_COMMAND -f $values_file "
    else
        echo "echo values file not found."
    fi
done

###
### Additional values files
###
VALUES_FILES_COMMAND=""

# default
echo "Processing default additional values directory ($DEFAULT_ADDITIONAL_VALUES_FILES_PATH)"
if [ -d "$DEFAULT_ADDITIONAL_VALUES_FILES_PATH" ]; then
    echo "Default Additional values directory exists."
    for values_file in `ls "$DEFAULT_ADDITIONAL_VALUES_FILES_PATH"`; do
        echo "processing default values-file: $values_file"
        VALUES_FILES_COMMAND="$VALUES_FILES_COMMAND -f $DEFAULT_ADDITIONAL_VALUES_FILES_PATH/$values_file "
    done
else 
    echo "No default values file directory. Skipping..."
fi

# chart specific
echo "Processing additional values directory ($ADDITIONAL_VALUES_FILES_PATH)"
if [ -d "$ADDITIONAL_VALUES_FILES_PATH" ]; then
    echo "Additional values directory exists."
    for values_file in `ls "$ADDITIONAL_VALUES_FILES_PATH"`; do
        echo "processing values-file: $values_file"
        VALUES_FILES_COMMAND="$VALUES_FILES_COMMAND -f $ADDITIONAL_VALUES_FILES_PATH/$values_file "
    done
else 
    echo "No values file directory. Skipping..."
fi


# Deploy Chart.
echo "Updating dependencies in '$HELM_CHART_DIRECTORY' ..."
helm dep up "$HELM_CHART_DIRECTORY"


if [ -n "HELM_RELEASE_NAME" ]; then
    HELM_RELEASE_NAME="$HELM_CHART"
fi
k="kubectl --kubeconfig=$KUBE_CONFIG_FILE"
h="helm --kubeconfig=$KUBE_CONFIG_FILE"


# Check if namespace exists and create it if it doesn't.
k="$k" \
NAMESPACE="$NAMESPACE" \
HELM_CHART="$HELM_CHART" \
HELM_CHART_DIRECTORY="$HELM_CHART_DIRECTORY" \
bash -x $SCRIPTS_DIR/helm/ensure-namespace-exists.sh


# TODO: helm lint


RESULT=""
$h list --all --all-namespaces > /tmp/check_release.txt

if [ -n "$(grep "$HELM_RELEASE_NAME" /tmp/check_release.txt)" ]; then 
    echo "Checking last deployment status"
    $h history \
    $HELM_RELEASE_NAME \
    --namespace $NAMESPACE

    RESULT="$($h history $HELM_RELEASE_NAME --namespace $NAMESPACE --output yaml | shyaml get-value -1 | shyaml get-value status)"
    echo "Helm deployment status: $RESULT "
else
    echo "No history"
fi

if [ "$RESULT" == "complete" ] || [ "$RESULT" == "deployed" ]; then
    echo "Upgrading Release: $HELM_RELEASE_NAME"
    $h upgrade \
    $HELM_RELEASE_NAME \
    $HELM_CHART_DIRECTORY \
    --cleanup-on-fail \
    --install \
    $BITOPS_CONFIG_COMMAND \
    $MAIN_VALUES_FILES_COMMAND \
    $VALUES_FILES_COMMAND
else
    if [ -z "$RESULT" ]; then
        echo 'New installation...'
        $h install \
        $HELM_RELEASE_NAME \
        $HELM_CHART_DIRECTORY \
        $BITOPS_CONFIG_COMMAND \
        $MAIN_VALUES_FILES_COMMAND \
        $VALUES_FILES_COMMAND
    else
        # TODO: build this into bitops.schema.yaml
        HELM_DEBUG_COMMAND=""
        if [ -n "$HELM_DEBUG" ]; then
            HELM_DEBUG_COMMAND="--debug"
        fi


        echo "The previous instalation failed. Rolling back to last successful release."
        $h rollback \
        $HELM_RELEASE_NAME 0 \
        --namespace $NAMESPACE \
        --cleanup-on-fail \
        $HELM_DEBUG_COMMAND
    fi
fi

# Run After Deploy Scripts if any.

bash -x $SCRIPTS_DIR/deploy/after-deploy.sh $HELM_CHART_DIRECTORY

printf "${SUCCESS} Helm deployment was successful...${NC}"


# TODO: do we need this?
# if [ -z "$EXTERNAL_HELM_CHARTS" ]; then 
#     echo "EXTERNAL_HELM_CHARTS directory not set."
# else
#     echo "Running External Helm Charts."
#     bash -x $SCRIPTS_DIR/helm/helm_install_external_charts.sh
# fi

# if [ -z "$HELM_CHARTS_S3" ]; then
#     echo "HELM_CHARTS_S3 not set."
# else
#     echo "Adding S3 Helm Repo."
#     bash -x $SCRIPTS_DIR/helm/helm_install_charts_from_s3.sh 
# fi
