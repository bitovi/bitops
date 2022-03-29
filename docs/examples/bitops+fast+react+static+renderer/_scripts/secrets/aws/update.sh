#!/bin/bash

set -e


# validation
if [ -z "$AWS_SECRETS_SECRET_NAME" ]; then
    echo "Environment Variable Required: AWS_SECRETS_SECRET_NAME"
    exit 1
fi
if [ -z "$AWS_SECRETS_SECRET_VALUE" ]; then
    echo "Environment Variable Required: AWS_SECRETS_SECRET_VALUE"
    exit 1
fi

region_command=""
if [ -n "$AWS_SECRETS_REGION" ]; then
    region_command="--region ${AWS_SECRETS_REGION}"
fi

output_command="--output yaml"
if [ -n "$AWS_SECRETS_OUTPUT" ]; then
    output_command="--output ${AWS_SECRETS_OUTPUT}"
fi

echo "Updating Secret: $AWS_SECRETS_SECRET_NAME"
aws secretsmanager \
$region_command \
$output_command \
--no-cli-pager \
put-secret-value \
--secret-id $AWS_SECRETS_SECRET_NAME \
--secret-string "$AWS_SECRETS_SECRET_VALUE"
