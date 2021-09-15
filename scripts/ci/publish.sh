#!/usr/bin/env bash
set -xe


####
#### validation
####
echo "REGISTRY_URL: ${REGISTRY_URL}"
if [ -z "$REGISTRY_URL" ]; then
  >&2 echo "{\"script\":\"scripts/ci/publish.sh\", \"error\":\"REGISTRY_URL required\"}"
  exit 1
fi




####
#### docker login
####
if [ -n "$BITOPS_PUBLISH_ECR" ]; then
  ./scripts/ci/docker-login-ecr.sh

else
  echo "$DOCKER_PASS" | docker login --username="$DOCKER_USER" --password-stdin
  echo "logged into dockerhub registry"
fi

####
#### docker build
####
./scripts/ci/docker-build.sh


####
#### set up tagging
####

BITOPS_GIT_TAG=plugin
# allow custom branching
if [ -n "$BITOPS_DOCKER_IMAGE_PUBLISH_TAG" ]; then
  echo "{\"script\":\"scripts/ci/publish.sh\", \"tag\": \"${BITOPS_DOCKER_IMAGE_PUBLISH_TAG}\"}"
  docker tag ${BITOPS_DOCKER_IMAGE_NAME}:latest ${REGISTRY_URL}:${BITOPS_DOCKER_IMAGE_PUBLISH_TAG}
else
  # handle git tag
  if [ -n "$BITOPS_GIT_TAG" ]; then
    echo "{\"script\":\"scripts/ci/publish.sh\", \"tag\": \"${BITOPS_GIT_TAG}\"}"
    docker tag ${BITOPS_DOCKER_IMAGE_NAME}:latest ${REGISTRY_URL}:${BITOPS_GIT_TAG}

  # if master, tag latest
  elif [ "$BITOPS_GIT_BRANCH" == "$BITOPS_GIT_BASE_BRANCH" ]; then
    echo "{\"script\":\"scripts/ci/publish.sh\", \"tag\": \"${latest}\"}"
    docker tag ${BITOPS_DOCKER_IMAGE_NAME}:latest ${REGISTRY_URL}:${BITOPS_DOCKER_IMAGE_PUBLISH_TAG}

    
  # fall back to the sha
  elif [ -z "$BITOPS_DOCKER_IMAGE_PUBLISH_SKIP_SHA" ]; then
    echo "{\"script\":\"scripts/ci/publish.sh\", \"tag\": \"${BITOPS_GIT_SHA}\"}"
    docker tag ${BITOPS_DOCKER_IMAGE_NAME}:latest ${REGISTRY_URL}:${BITOPS_GIT_SHA}
  
  # don't tag anything
  else
    echo "{\"script\":\"scripts/ci/publish.sh\", \"tag\": \"\"}"
  fi
fi


# push everything
echo "REGISTRY_URL: ${REGISTRY_URL}"
docker push ${REGISTRY_URL}
