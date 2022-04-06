#!/usr/bin/env bash
set -e

echo "Creating AWS Profile"

bash $SCRIPTS_DIR/aws/validate_env.sh

mkdir -p /root/.aws
cat <<EOF > /root/.aws/credentials
[default]
aws_access_key_id = "${AWS_ACCESS_KEY_ID}"
aws_secret_access_key = "${AWS_SECRET_ACCESS_KEY}"
EOF

if [ -n "$AWS_SESSION_TOKEN" ]; then
  echo "aws_session_token = $AWS_SESSION_TOKEN" >> /root/.aws/credentials
fi

cat <<EOF > /root/.aws/config
[default]
region = "$AWS_DEFAULT_REGION"
output = json
EOF