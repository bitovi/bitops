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

echo "Checking if secret exists: ${AWS_SECRETS_SECRET_NAME}"
set +e
EXISTING_SECRET="$(AWS_SECRETS_OUTPUT="$AWS_SECRETS_OUTPUT" \
AWS_SECRETS_REGION="$AWS_SECRETS_REGION" \
AWS_SECRETS_SECRET_NAME="$AWS_SECRETS_SECRET_NAME" \
bash $ROOT_DIR/_scripts/secrets/aws/get.sh 2>&1)" 
MISSING_SECRET="$(echo "$EXISTING_SECRET" | grep "Secrets Manager can't find the specified secret.")"
set -e

if [ -n "$MISSING_SECRET" ]; then
    echo "  Secret not found. Creating."
    AWS_SECRETS_OUTPUT="$AWS_SECRETS_OUTPUT" \
    AWS_SECRETS_REGION="$AWS_SECRETS_REGION" \
    AWS_SECRETS_SECRET_NAME="$AWS_SECRETS_SECRET_NAME" \
    AWS_SECRETS_SECRET_VALUE="$AWS_SECRETS_SECRET_VALUE" \
    AWS_SECRETS_SECRET_DESCRIPTION="$AWS_SECRETS_SECRET_DESCRIPTION" \
    bash $ROOT_DIR/_scripts/secrets/aws/create.sh
else
    echo "  Secret found. Updating."
    AWS_SECRETS_OUTPUT="$AWS_SECRETS_OUTPUT" \
    AWS_SECRETS_REGION="$AWS_SECRETS_REGION" \
    AWS_SECRETS_SECRET_NAME="$AWS_SECRETS_SECRET_NAME" \
    AWS_SECRETS_SECRET_VALUE="$AWS_SECRETS_SECRET_VALUE" \
    AWS_SECRETS_SECRET_DESCRIPTION="$AWS_SECRETS_SECRET_DESCRIPTION" \
    bash $ROOT_DIR/_scripts/secrets/aws/update.sh
fi



