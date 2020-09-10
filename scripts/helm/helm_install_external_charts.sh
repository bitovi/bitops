#!/usr/bin/env bash
set -e

#ROOT_DIR="$1"

# Which environment to deploy
# this should correspond to a directory in the operations repo
# which should also be the current working directory
#ENVIRONMENT="$2"

# directory of the helm chart (subdirectory of helm/)
#HELM_SUBDIRECTORY="$3"

echo "Installing external helm charts"
echo "REPOS: $CURRENT_ENVIRONMENT $EXTERNAL_HELM_CHARTS"

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "environment variable (AWS_ACCESS_KEY_ID) not set"
  return 1
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "environment variable (AWS_ACCESS_KEY_ID) not set"
  return 1
fi
if [ -z "$KUBECONFIG_BASE64" ]; then
  echo "environment variable (KUBECONFIG_BASE64) not set"
  return 1
fi
if [ -z "$NAMESPACE" ]; then
  echo "environment variable (NAMESPACE) not set"
  return 1
fi

for chart in "$EXTERNAL_HELM_CHARTS"
do
    echo "Processing Charts: $chart"
    CHART_NAME=$(echo $chart | awk -F\, {'print $1'})
    REPO_KEY=$(echo $chart | awk -F\, {'print $2'})
    URL=$(echo $chart | awk -F\, {'print $3'})
    helm repo add $CHART_NAME $URL --kubeconfig="$KUBE_CONFIG_FILE"
    helm repo update --kubeconfig="$KUBE_CONFIG_FILE"
    helm upgrade --install "$CHART_NAME $CHART_NAME/$REPO_KEY" --kubeconfig="$KUBE_CONFIG_FILE" --namespace="$NAMESPACE"
done
