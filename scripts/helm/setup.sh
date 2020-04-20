#!/usr/bin/env bash

TEMPDIR="$1"
CHART_ROOT="$2"

# TODO: prep the deployment.  setup should do the following:
#     - move all env helm files ($CHART_ROOT) to $TEMPDIR
#     - decode $KUBECONFIG_BASE64 into $TEMPDIR/kube/config
#     - decode $HELM_SECRETS_FILE_BASE64 into $TEMPDIR/values-secrets.yaml
echo 'TODO...'