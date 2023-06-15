#!/bin/bash

set -e


# validation
if [ -z "$AWS_SECRETS_SECRET_NAME" ]; then
    echo "Environment Variable Required: AWS_SECRETS_SECRET_NAME"
    exit 1
fi
if [ -z "$AWS_SECRETS_SECRET_FILE" ]; then
    echo "Environment Variable Required: AWS_SECRETS_SECRET_FILE"
    exit 1
fi
if [ ! -f "$AWS_SECRETS_SECRET_FILE" ]; then
    echo "Environment Variable should be a file: AWS_SECRETS_SECRET_FILE ($AWS_SECRETS_SECRET_FILE)"
    exit 1
fi
if [ -z "$AWS_SECRETS_SECRET_DESCRIPTION" ]; then
    echo "Environment Variable Required: AWS_SECRETS_SECRET_DESCRIPTION"
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

if [ -z "$ROOT_DIR" ]; then
    ROOT_DIR="$(pwd)"
fi


AWS_SECRETS_SECRET_VALUE="$(cat "$AWS_SECRETS_SECRET_FILE")"

AWS_SECRETS_OUTPUT="$AWS_SECRETS_OUTPUT" \
AWS_SECRETS_REGION="$AWS_SECRETS_REGION" \
AWS_SECRETS_SECRET_NAME="$AWS_SECRETS_SECRET_NAME" \
AWS_SECRETS_SECRET_VALUE="$AWS_SECRETS_SECRET_VALUE" \
AWS_SECRETS_SECRET_DESCRIPTION="$AWS_SECRETS_SECRET_DESCRIPTION" \
bash $ROOT_DIR/_scripts/secrets/aws/save.sh
