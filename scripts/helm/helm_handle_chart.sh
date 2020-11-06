#!/usr/bin/env bash
set -e

export HELM_CHART="$1"
export HELM_CHART_DIRECTORY="$HELM_ROOT/$HELM_CHART"
export DEFAULT_HELM_CHART_DIRECTORY="$DEFAULT_HELM_ROOT/$HELM_CHART"
export HELM_BITOPS_CONFIG="$HELM_CHART_DIRECTORY/bitops.config.yaml" 
export BITOPS_CONFIG_SCHEMA="$SCRIPTS_DIR/helm/bitops.schema.yaml"
export BITOPS_SCHEMA_ENV_FILE="$HELM_CHART_DIRECTORY/ENV_FILE"

echo "Installing charts..."

output_schema_env () {
    echo "Schema ENV"
    cat "$BITOPS_SCHEMA_ENV_FILE"
}
on_exit () {
    output_schema_env
}
trap "{ on_exit; }" EXIT

# Check for Before Deploy Scripts
bash $SCRIPTS_DIR/deploy/before-deploy.sh "$HELM_CHART_DIRECTORY"

# Load bitops.config.yaml
export BITOPS_CONFIG_COMMAND="$(ENV_FILE="$BITOPS_SCHEMA_ENV_FILE" DEBUG="" bash $SCRIPTS_DIR/bitops-config/convert-schema.sh $BITOPS_CONFIG_SCHEMA $HELM_BITOPS_CONFIG)"
echo "BITOPS_CONFIG_COMMAND: $BITOPS_CONFIG_COMMAND"
source "$BITOPS_SCHEMA_ENV_FILE"

# set kube config
if [[ "${KUBE_CONFIG_PATH}" == "" ]] || [[ "${KUBE_CONFIG_PATH}" == "''" ]] || [[ "${KUBE_CONFIG_PATH}" == "None" ]]; then
    if [[ "${FETCH_KUBECONFIG}" == "True" ]]; then
        if [[ "${CLUSTER_NAME}" == "" ]] || [[ "${CLUSTER_NAME}" == "''" ]] || [[ "${CLUSTER_NAME}" == "None" ]]; then
            >&2 echo "{\"error\":\"CLUSTER_NAME config is required.Exiting...\"}"
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
        if [[ "${FETCH_KUBECONFIG}" == "False" ]]; then
            >&2 echo "{\"error\":\"one or more 'kubeconfig' variables are undefined in bitops.config.yaml.Exiting...\"}"
            exit 1
        fi
    fi
else
    if [[ -f "$KUBE_CONFIG_PATH" ]]; then
        echo "$KUBE_CONFIG_PATH exists."
        KUBE_CONFIG_FILE="$KUBE_CONFIG_PATH" \
        KUBECONFIG="$KUBE_CONFIG_FILE" \
        export KUBECONFIG=$KUBECONFIG:$KUBE_CONFIG_FILE
    else
        >&2 echo "{\"error\":\"kubeconfig path variable wrong in bitops.config.yaml.Exiting...\"}"
        exit 1
    fi
fi
export k="kubectl --kubeconfig=$KUBE_CONFIG_FILE"
export h="helm --kubeconfig=$KUBE_CONFIG_FILE"

echo "call validate_env with NAMESPACE: $NAMESPACE"
if [ -n "$HELM_RELEASE_NAME" ]; then
    HELM_RELEASE_NAME="$HELM_CHART"
fi
bash $SCRIPTS_DIR/helm/validate_env.sh

### COPY DEFAULTS
HELM_CHART_DIRECTORY="$HELM_CHART_DIRECTORY" \
DEFAULT_HELM_CHART_DIRECTORY="$DEFAULT_HELM_CHART_DIRECTORY" \
HELM_BITOPS_CONFIG="$HELM_BITOPS_CONFIG" \
bash -x $SCRIPTS_DIR/helm/copy-defaults.sh "$HELM_CHART"

# TODO Check for HELM_UNINSTALL env flag

# Deploy Chart.
echo "Updating dependencies in '$HELM_CHART_DIRECTORY' ..."
helm dep up "$HELM_CHART_DIRECTORY"
bash $SCRIPTS_DIR/helm/helm_deploy_chart.sh

# TODO Uninstall Chart


# Run After Deploy Scripts if any.
bash $SCRIPTS_DIR/deploy/after-deploy.sh $HELM_CHART_DIRECTORY

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
