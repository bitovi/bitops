#!/usr/bin/env bash
set -xe

### TODO: make pipeline runner agnostic 
### (i.e. move CIRCLECI specific stuff and use env vars instead)
### example: instead of CIRCLE_PROJECT_REPONAME, use `DOCKER_IMAGE_NAME`
### and then in .circleci/config.yml, set DOCKER_IMAGE_NAME: $CIRCLE_PROJECT_REPONAME




if [ -z "$REGISTRY_URL" ]; then
  >&2 echo "{\"script\":\"scripts/ci/publish.sh\", \"error\":\"REGISTRY_URL required\"}"
  exit 1
fi

if [ -n "$BITOPS_PUBLISH_ECR" ]; then
  ./scripts/ci/docker-login-ecr.sh
fi


####
#### set up tagging
####


# allow custom branching
if [ -n "$BITOPS_DOCKER_IMAGE_PUBLISH_TAG" ]; then
  echo "{\"script\":\"scripts/ci/publish.sh\", \"tag\": \"${BITOPS_DOCKER_IMAGE_PUBLISH_TAG}\"}"
  docker tag ${CIRCLE_PROJECT_REPONAME}:latest ${REGISTRY_URL}:${BITOPS_DOCKER_IMAGE_PUBLISH_TAG}
else
  # handle git tag
  if [ -n "$CIRCLE_TAG" ]; then
    echo "{\"script\":\"scripts/ci/publish.sh\", \"tag\": \"${CIRCLE_TAG}\"}"
    docker tag ${CIRCLE_PROJECT_REPONAME}:latest ${REGISTRY_URL}:${CIRCLE_TAG}

  # if master, tag latest
  elif [ "$CIRCLE_BRANCH" == "master" ]; then
    echo "{\"script\":\"scripts/ci/publish.sh\", \"tag\": \"${latest}\"}"
    docker tag ${CIRCLE_PROJECT_REPONAME}:latest ${REGISTRY_URL}:latest

    
  # fall back to the sha
  elif [ -z "$BITOPS_DOCKER_IMAGE_PUBLISH_SKIP_SHA" ]; then
    echo "{\"script\":\"scripts/ci/publish.sh\", \"tag\": \"${CIRCLE_SHA1}\"}"
    docker tag ${CIRCLE_PROJECT_REPONAME}:latest ${REGISTRY_URL}:${CIRCLE_SHA1}
  
  # don't tag anything
  else
    echo "{\"script\":\"scripts/ci/publish.sh\", \"tag\": \"\"}"
  fi
fi


# push everything
docker push ${REGISTRY_URL}
