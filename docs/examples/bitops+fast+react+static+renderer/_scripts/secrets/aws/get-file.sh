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


echo "Getting secret: $AWS_SECRETS_SECRET_NAME"
AWS_SECRETS_SECRET_VALUE_RAW="$(AWS_SECRETS_OUTPUT="$AWS_SECRETS_OUTPUT" \
AWS_SECRETS_REGION="$AWS_SECRETS_REGION" \
AWS_SECRETS_SECRET_NAME="$AWS_SECRETS_SECRET_NAME" \
bash $ROOT_DIR/_scripts/secrets/aws/get.sh)"


set +e
SHYAML_RESULT=$(which shyaml)
YQ_RESULT=$(which yq)
set -e

if [ -n "$SHYAML_RESULT" ]; then
    AWS_SECRETS_SECRET_VALUE="$(echo "$AWS_SECRETS_SECRET_VALUE_RAW" | shyaml get-value SecretString)"
elif [ -n "$YQ_RESULT" ]; then
    AWS_SECRETS_SECRET_VALUE="$(echo "$AWS_SECRETS_SECRET_VALUE_RAW" | yq ".SecretString")"
fi

echo "Storing secret in: $AWS_SECRETS_SECRET_FILE"
echo "$AWS_SECRETS_SECRET_VALUE" > "$AWS_SECRETS_SECRET_FILE"