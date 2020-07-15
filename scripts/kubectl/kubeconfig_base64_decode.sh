#!/usr/bin/env bash
set -xe


echo "KUBECONFIG_BASE64 - checking if set"
if [ -z "$KUBECONFIG_BASE64" ]; then
  echo "KUBECONFIG_BASE64 not set. Skipping..."
  exit 0
fi

kubeconfig_root="$TEMPDIR/.kube"
kubeconfig_path="$kubeconfig_root/config"

mkdir -p "$kubeconfig_root"
echo "${KUBECONFIG_BASE64}" | base64 -d > "$kubeconfig_path"


echo "kubeconfig created from KUBECONFIG_BASE64: $kubeconfig_path (TMPDIR/.kube/config)"