#!/bin/bash

set -e

# Validation
: ${REGISTRY_URL:? REGISTRY_URL env variable is required!}
: ${IMAGE_TAG:? IMAGE_TAG env variable is required!}

# Docker login
echo "$DOCKER_PASS" | docker login --username="$DOCKER_USER" --password-stdin
echo "logged into dockerhub registry"

###
### PUBLISH - environment setup
###

# Defining the Default branch variable
if [ -z "$DEFAULT_BRANCH" ]; then
    DEFAULT_BRANCH="main"
fi

REPO_NAME=$(echo $GITHUB_REPOSITORY | sed 's/^.*\///')
ORG_NAME=$(echo $GITHUB_REPOSITORY | sed 's/\/.*//')
TAG_OR_HEAD="$(echo $GITHUB_REF | cut -d / -f2)"
BRANCH_OR_TAG_NAME=$(echo $GITHUB_REF | cut -d / -f3)
echo "REPO_NAME: $REPO_NAME"
echo "ORG_NAME: $ORG_NAME"
echo "TAG_OR_HEAD: $TAG_OR_HEAD"
echo "BRANCH_OR_TAG_NAME: $BRANCH_OR_TAG_NAME"


# if omnibus tag, use tag and `latest`
# if base tag, use tag and `base`
# if default `main` branch merge, use `dev`
# See: https://github.com/bitovi/bitops/wiki/BitOps-Image#versioning

# Remove "v" prefix before the version
if [[ "${IMAGE_TAG:0:1}" == "v" ]]; then
  IMAGE_TAG="${IMAGE_TAG:1}"
fi

if echo "$IMAGE_TAG" | grep 'omnibus$'; then
  if [ "$TAG_OR_HEAD" == "tags" ]; then # a release
    ADDITIONAL_IMAGE_TAG="latest"
  elif [ "$TAG_OR_HEAD" == "heads" ] && [ "$BRANCH_OR_TAG_NAME" == "$DEFAULT_BRANCH" ]; then # merge to default branch
    IMAGE_TAG="dev"
  fi
fi

echo "###"
echo "### PUBLISH DOCKER"
echo "###"

echo -e "\033[32mBuilding the docker image \033[1m${REGISTRY_URL}:${IMAGE_TAG}\033[0m\033[32m...\033[0m"
docker build -t ${REGISTRY_URL}:${IMAGE_TAG} .

echo -e "\033[32mPushing the docker image \033[1m${REGISTRY_URL}:${IMAGE_TAG}\033[0m\033[32m to the repository...\033[0m"
docker push ${REGISTRY_URL}:${IMAGE_TAG}

if [ -n "$ADDITIONAL_IMAGE_TAG" ]; then
  echo -e "\033[32mAdding the additional docker tag \033[1m${REGISTRY_URL}:${ADDITIONAL_IMAGE_TAG}\033[0m"
  docker tag ${REGISTRY_URL}:${IMAGE_TAG} ${REGISTRY_URL}:${ADDITIONAL_IMAGE_TAG}

  echo -e "\033[32mPushing the additional docker image \033[1m${REGISTRY_URL}:${ADDITIONAL_IMAGE_TAG}\033[0m\033[32m to the repository...\033[0m"
  docker push ${REGISTRY_URL}:${ADDITIONAL_IMAGE_TAG}
fi
