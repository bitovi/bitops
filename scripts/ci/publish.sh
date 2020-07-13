#!/usr/bin/env bash
set -xe


####
#### validation
####
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
  >&2 echo "{\"script\":\"scripts/ci/publish.sh\", \"error\":\"TODO: docker login\"}"
  exit 1
fi

####
#### docker build
####
./scripts/ci/docker-build.sh


####
#### set up tagging
####


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
    docker tag ${BITOPS_DOCKER_IMAGE_NAME}:latest ${REGISTRY_URL}:latest

    
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
docker push ${REGISTRY_URL}
