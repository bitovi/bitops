#!/usr/bin/env bash
set -xe

echo "Creating AWS Profile"

bash $SCRIPTS_DIR/aws/validate_env.sh

mkdir -p /root/.aws
cat <<EOF > /root/.aws/credentials
[default]
aws_access_key_id = "${AWS_ACCESS_KEY_ID}"
aws_secret_access_key = "${AWS_SECRET_ACCESS_KEY}"
EOF

cat <<EOF > /root/.aws/config
[default]
region = "$AWS_DEFAULT_REGION"
output = json
EOF