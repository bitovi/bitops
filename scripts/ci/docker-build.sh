#!/usr/bin/env bash
set -e


####
#### validation
####
if [ -z "$BITOPS_DOCKER_IMAGE_NAME" ]; then
  >&2 echo "{\"script\":\"scripts/ci/docker-build.sh\", \"error\":\"BITOPS_DOCKER_IMAGE_NAME required\"}"
  exit 1
fi

####
#### docker build
####
docker build -t ${BITOPS_DOCKER_IMAGE_NAME}:plugin .
