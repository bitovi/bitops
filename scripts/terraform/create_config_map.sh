#!/usr/bin/env bash
set -e

echo "Terraform - Creating config map..."

CF_TEMPLATE="https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/aws-auth-cm.yaml"

curl -o aws-auth-cm.yaml $CF_TEMPLATE
TMP_WORKER_ROLE=$(shyaml get-value role < "$TERRAFORM_BITOPS_CONFIG")
AWS_ROLE_PREFIX=$(echo $TMP_WORKER_ROLE | awk -F\/ {'print $1'})
ROLE_NAME=$(echo $TMP_WORKER_ROLE | awk -F\/ {'print $2'})
WORKER_ROLE=$AWS_ROLE_PREFIX'\/'$ROLE_NAME

cat aws-auth-cm.yaml | sed 's/ARN of instance role (not instance profile)//g' | sed 's/[<]/'"$ROLE"'/g' | sed 's/[>]//g' > aws-auth-cm.yaml-tmp
rm -rf aws-auth-cm.yaml
mv aws-auth-cm.yaml-tmp aws-auth-cm.yaml
kubectl apply --kubeconfig="$KUBE_CONFIG_FILE" -f aws-auth-cm.yaml

echo "Terraform - Creating config map...Done"