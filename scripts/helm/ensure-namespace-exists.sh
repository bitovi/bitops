#!/usr/bin/env bash

set -ex

# passed in
# 
# k
# NAMESPACE
# HELM_CHART
# HELM_CHART_DIRECTORY


# TODO: check for $HEML_CHART_DIRECTORY/namespace.yaml (apply if exists)

# Check if namespace exists and create it if it doesn't.
if [ -n "$($k get namespaces | grep $NAMESPACE)" ]; then
    echo "The namespace $NAMESPACE exists. Skipping creation..."
else
    echo "The namespace $NAMESPACE does not exists. Creating..."
    $k create namespace $NAMESPACE
fi
