#!/usr/bin/env bash
set -e

terraform output kubeconfig > "$KUBE_CONFIG_FILE"
export KUBECONFIG_BASE64=$(cat "$KUBE_CONFIG_FILE" | base64)
