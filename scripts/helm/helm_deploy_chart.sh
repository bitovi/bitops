#!/usr/bin/env bash
set -e

# Initialize values files
VALUES_FILE_PATH="$HELM_CHART_DIRECTORY/values.yaml"
DEFAULT_VALUES_FILE_PATH="$DEFAULT_HELM_CHART_DIRECTORY/values.yaml"
VALUES_SECRETS_FILE_PATH="$HELM_CHART_DIRECTORY/values-secrets.yaml"

VALUES_VERSIONS_FILE_PATH="$HELM_CHART_DIRECTORY/values-versions.yaml"
DEFAULT_VALUES_VERSIONS_FILE_PATH="$DEFAULT_HELM_CHART_DIRECTORY/values-versions.yaml"

ADDITIONAL_VALUES_FILES_PATH="$HELM_CHART_DIRECTORY/values-files"
DEFAULT_ADDITIONAL_VALUES_FILES_PATH="$DEFAULT_HELM_CHART_DIRECTORY/values-files"

# Setup helm values-secrets from base64
echo "HELM_SECRETS_BASE64 - checking if set"
if [ -z "$HELM_SECRETS_BASE64" ]; then
  echo "HELM_SECRETS_BASE64 not set. Skipping..."
else
  echo "${HELM_SECRETS_BASE64}" | base64 -d > "$VALUES_SECRETS_FILE_PATH"
  echo "helm values-secrets created from HELM_SECRETS_BASE64: $VALUES_SECRETS_FILE_PATH"
fi

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

    set +e
    helm_history_output="$($h history $HELM_RELEASE_NAME --namespace $NAMESPACE 2>&1)"
    helm_history_output_test="$(echo -e "$helm_history_output" | grep "Error: release: not found")"
    set -e

    if [ -n "$helm_history_output_test" ]; then
        echo "release not found"
        RESULT=""
    else
        echo "release found"
        RESULT="$($h history $HELM_RELEASE_NAME --namespace $NAMESPACE --output yaml | shyaml get-value -1 | shyaml get-value status)"
    fi

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