#!/usr/bin/env bash
set -xe


echo "KUBECONFIG_BASE64 - checking if set"
if [ -z "$KUBECONFIG_BASE64" ]; then
  echo "KUBECONFIG_BASE64 not set. Skipping..."
  exit 0
fi


echo "${KUBECONFIG_BASE64}" | base64 -d > "$KUBE_CONFIG_FILE"


echo "kubeconfig created from KUBECONFIG_BASE64: $KUBE_CONFIG_FILE"