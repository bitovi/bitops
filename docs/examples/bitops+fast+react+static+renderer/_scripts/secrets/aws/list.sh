#!/bin/bash

set -e

region_command=""
if [ -n "$AWS_SECRETS_REGION" ]; then
    region_command="--region ${AWS_SECRETS_REGION}"
fi

output_command="--output yaml"
if [ -n "$AWS_SECRETS_OUTPUT" ]; then
    output_command="--output ${AWS_SECRETS_OUTPUT}"
fi

aws secretsmanager \
$region_command \
$output_command \
--no-cli-pager \
list-secrets
