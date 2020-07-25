#!/usr/bin/env bash

set -ex

HELM_CHART="$1"

# passed in
# HELM_CHART_DIRECTORY
# DEFAULT_HELM_CHART_DIRECTORY
# HELM_BITOPS_CONFIG

# TODO: handle if we should merge vs overwrite

# Copy default CRDs.
if [ "$(shyaml get-value copy_defaults.crds < "$HELM_BITOPS_CONFIG")" == 'True' ]; then
    echo "COPY_DEFAULT_CRDS set"
    if [ -d "$DEFAULT_HELM_CHART_DIRECTORY/crds" ]; then
        echo "default crds/ exist"
        cp -rf "$DEFAULT_HELM_CHART_DIRECTORY/crds/." "$HELM_CHART_DIRECTORY/crds/"
    else
        printf "${ERROR} crds/ does not exist...${NC}"
    fi
else
    echo "COPY_DEFAULT_CRDS not set"
fi

# Copy default Charts.

if [ "$(shyaml get-value copy_defaults.charts < "$HELM_BITOPS_CONFIG")" == 'True' ]; then
    echo "COPY_DEFAULT_CHARTS set"
    if [ -d "$DEFAULT_HELM_CHART_DIRECTORY/charts" ]; then
        echo "default charts/ exist"
        cp -rf "$DEFAULT_HELM_CHART_DIRECTORY/charts/." "$HELM_CHART_DIRECTORY/charts/"
    else
        printf "${ERROR} charts/ does not exist...${NC}"
    fi
else
    echo "COPY_DEFAULT_CHARTS not set"
    printf "${SUCCESS} Helm deployment was successful...${NC}"
fi

# Copy default Templates.

if [ "$(shyaml get-value copy_defaults.templates < "$HELM_BITOPS_CONFIG")" == 'True' ]; then
    echo "COPY_DEFAULT_TEMPLATES set"
    if [ -d "$DEFAULT_HELM_CHART_DIRECTORY/templates" ]; then
        echo "default templates/ exist"
        cp -rf "$DEFAULT_HELM_CHART_DIRECTORY/templates/." "$HELM_CHART_DIRECTORY/templates/"
    else
        printf "${ERROR}  templates/ does not exist...${NC}"
    fi
else
    echo "COPY_DEFAULT_TEMPLATES not set"
fi

# TODO: what's the schema?
# Copy default Schema.
if [ "$(shyaml get-value copy_defaults.schema < "$HELM_BITOPS_CONFIG")" == 'True' ]; then
    echo "COPY_DEFAULT_SCHEMA set"
    if [ -d "$DEFAULT_HELM_CHART_DIRECTORY/schema" ]; then
        echo "default schema/ exists"
        cp -rf "$DEFAULT_HELM_CHART_DIRECTORY/templates/." "$HELM_CHART_DIRECTORY/templates/"
    else
        printf "${ERROR}  schema/ does not exist...${NC}"
    fi
else
    echo "COPY_DEFAULT_SCHEMA not set"
fi
