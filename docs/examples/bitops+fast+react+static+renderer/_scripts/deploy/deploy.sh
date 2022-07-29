#!/bin/bash

set -e


echo "In deploy.sh"

# TODO: use env file instead of directly mapping each env var?
#  need to handle local PATH and such..
# cleanup () {

#   echo "cleaning up deploy/deploy.sh..."
#   rm -rf env_file_for_docker
# }
# trap "{ cleanup "$TEMPDIR"; }" EXIT

# env >> env_file_for_docker
# # sed -i 's/ /_/g' env_file_for_docker



# todo: map this in the gitlab pipeline
if [ -n "$GITHUB_WORKSPACE" ]; then
    REPO_PATH="$GITHUB_WORKSPACE"
fi


if [ -z "$REPO_PATH" ]; then
    echo "Required env var REPO_PATH: not set"
    exit 1
fi


echo "Running BitOps for env: $ENVIRONMENT"
docker run --rm --name bitops \
-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
-e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" \
-e ENVIRONMENT="${ENVIRONMENT}" \
-e ENVIRONMENT_HELM_SUBDIRECTORY="${ENVIRONMENT_HELM_SUBDIRECTORY}" \
-e SKIP_DEPLOY_TERRAFORM="${SKIP_DEPLOY_TERRAFORM}" \
-e SKIP_DEPLOY_HELM="${SKIP_DEPLOY_HELM}" \
-e TF_STATE_BUCKET="${TF_STATE_BUCKET}" \
-e KUBECONFIG_BASE64="$KUBECONFIG_BASE64" \
-e PROVIDERS="$PROVIDERS" \
-e DEFAULT_FOLDER_NAME="_default" \
-e HELM_S3_REGION="${HELM_S3_REGION}" \
-v $(echo $REPO_PATH):/opt/bitops_deployment \
$ADDITIONAL_MOUNT_STRING \
bitovi/bitops:v1.0.13
