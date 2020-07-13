#!/usr/bin/env bash
set -xe

output_script="\"script\":\"scripts/ci/docker-login-ecr.sh\""

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  >&2 echo "{${output_script}, \"error\":\"AWS_ACCESS_KEY_ID required\"}"
  exit 1
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  >&2 echo "{${output_script}, \"error\":\"AWS_SECRET_ACCESS_KEY required\"}"
  exit 1
fi
if [ -z "$AWS_DEFAULT_REGION" ]; then
  >&2 echo "{${output_script}, \"error\":\"AWS_DEFAULT_REGION required\"}"
  exit 1
fi
if [ -z "$ECR_ENDPOINT" ]; then
  >&2 echo "{${output_script}, \"error\":\"ECR_ENDPOINT required\"}"
  exit 1
fi

echo "{${output_script}, \"message\":\"Logging into AWS ECR\"}"
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}
export ECR_ENDPOINT=${ECR_ENDPOINT}
eval $(aws ecr get-login --no-include-email --region ${AWS_DEFAULT_REGION}) 