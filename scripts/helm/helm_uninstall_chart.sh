#!/usr/bin/env bash
set -e

echo "Running helm uninstall..."
$h list --all --namespace $NAMESPACE > /tmp/check_release.txt
if [ -n "$(grep "$HELM_RELEASE_NAME" /tmp/check_release.txt)" ]; then 
  $h uninstall $HELM_RELEASE_NAME --namespace $NAMESPACE
else
  printf "${WARN}${HELM_RELEASE_NAME} does not exist in namespace ${NAMESPACE} ${NC}\n"
fi