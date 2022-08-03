#!/bin/bash

set -e

# Validation
: ${REGISTRY_URL:? REGISTRY_URL env is required!}
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

# TODO: Remove "v" prefix before the version

if echo "$IMAGE_TAG" | grep '\d.\d.\d-omnibus'; then
  if [ "$TAG_OR_HEAD" == "tags" ]; then # a release
    ADDITIONAL_IMAGE_TAG="latest"
  elif [ "$TAG_OR_HEAD" == "heads" ] && [ "$BRANCH_OR_TAG_NAME" == "$DEFAULT_BRANCH" ]; then # merge to default branch
    IMAGE_TAG="dev"
  fi
fi

# If an IMAGE_PREFIX is not NULL
if [ -n "$IMAGE_PREFIX" ]; then
  export IMAGE_TAG="$IMAGE_PREFIX-$IMAGE_TAG"
fi

echo "###"
echo "### PUBLISH DOCKER"
echo "###"

# Defining the Image name variable
IMAGE_NAME="$REPO_NAME"

# Building the docker image...
echo "Building the docker image"
docker build -t ${IMAGE_NAME} .

# docker image deploy function
echo "docker tag ${IMAGE_NAME} ${REGISTRY_URL}:${IMAGE_TAG}"
docker tag ${IMAGE_NAME} ${REGISTRY_URL}:${IMAGE_TAG}

echo "Pushing the docker image to the repository..."
docker push ${REGISTRY_URL}:${IMAGE_TAG}

if [ -n "$ADDITIONAL_IMAGE_TAG" ]; then
  if [ -n "$IMAGE_PREFIX" ]; then
    export IMAGE_TAG="$IMAGE_PREFIX-$ADDITIONAL_IMAGE_TAG"
  else
    export IMAGE_TAG="$ADDITIONAL_IMAGE_TAG"
  fi
  
  # docker image deploy function
  echo "docker tag ${IMAGE_NAME} ${REGISTRY_URL}:${IMAGE_TAG}"
  docker tag ${IMAGE_NAME} ${REGISTRY_URL}:${IMAGE_TAG}

  echo "Pushing the additional docker image to the repository..."
  docker push ${REGISTRY_URL}:${IMAGE_TAG}
fi
