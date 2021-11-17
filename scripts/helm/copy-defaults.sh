#!/usr/bin/env bash
set -e

HELM_CHART="$1"

# passed in
# HELM_CHART_DIRECTORY
# DEFAULT_HELM_CHART_DIRECTORY
# HELM_BITOPS_CONFIG

# TODO: handle if we should merge vs overwrite

# Value of $ERROR = \033[0;31m
# Value of $NC = \033[0m

printf "COPY_DEFAULT_CRDS set..."
if [ -d "$DEFAULT_HELM_CHART_DIRECTORY/crds" ]; then
    printf "default crds/ exists.\n"
    cp -rf "$DEFAULT_HELM_CHART_DIRECTORY/crds/." "$HELM_CHART_DIRECTORY/crds/"
else
    printf "${ERROR} crds/ does not exist.${NC}\n"
fi


printf "COPY_DEFAULT_CHARTS set..."
if [ -d "$DEFAULT_HELM_CHART_DIRECTORY/charts" ]; then
    printf "default charts/ exists.\n"
    cp -rf "$DEFAULT_HELM_CHART_DIRECTORY/charts/." "$HELM_CHART_DIRECTORY/charts/"
else
    printf "${ERROR} charts/ does not exist.${NC}\n"
fi


printf "COPY_DEFAULT_TEMPLATES set..."
if [ -d "$DEFAULT_HELM_CHART_DIRECTORY/templates" ]; then
    printf "default templates/ exists.\n"
    cp -rf "$DEFAULT_HELM_CHART_DIRECTORY/templates/." "$HELM_CHART_DIRECTORY/templates/"
else
    printf "${ERROR}  templates/ does not exist.${NC}\n"
fi


printf "COPY_DEFAULT_SCHEMA set..."
if [ -d "$DEFAULT_HELM_CHART_DIRECTORY/schema" ]; then
    printf "default schema/ exists.\n"
    cp -rf "$DEFAULT_HELM_CHART_DIRECTORY/templates/." "$HELM_CHART_DIRECTORY/templates/"
else
    printf "${ERROR}  schema/ does not exist.${NC}\n"
fi
