# Bitovi CI/CD Runner

The Bitovi CI/CD Runner is deployment tool for Kubernetes Deployments. We support the big three Cloud Platorms: Amazon Web Services (AWS), Microsoft Azure Cloud (Azure) and Google Cloud Engine (GCE). The Bitovi runner will deploy your application as a Helm Chart on either platform. Simply pass the appropriate options to our deployment script to select Cloud Provider - (AWS, AC, GCE) or CI/CD Provider (Jenkins, AWS, GitLab, Travis). See our configuration section below.

## How it works.

The Bitovi CI/CD Runner is a boiler plate docker image for traditional DevOps 
work. It can handle Amazon AWS, Microsoft Azure.

BitOps is a docker container, built as a boiler plate devops engine for deploying kubernetes applications from a cloud native/agnostic point of view.

## Configuration Options

```bash

- Required Environment Variables:
  AWS_ACCESS_KEY_ID - Your AWS Access Key.
  AWS_SECRET_ACCESS_KEY - Your AWS Secret Access Key.
  AWS_DEFAULT_REGION - The AWS Region where you want to launch your resources.
  ENVIRONMENT - The environment to use: qa or prod etc.
  KUBECONFIG_BASE64 - The Base 64 value of the contents of your ./kube/config


- Optional Environment variables:
  ANSIBLE_DIRECTORY - The directory containing your ansible playbooks.
  ANSIBLE_PLAYBOOKS - The name of your ansible playbook.
  DEBUG - Set this option to 1 to enable debugging your Helm Stack.
  EXTERNAL_HELM_CHARTS - External Helm chart you need to install. The arguments for each repo should be separated a comma. Use the form: <NAME>,<REPO_KEY>,<REPO_URL>.
  TERRAFORM_DIRECTORY - Location of the terraform directory.
  TF_APPLY - Set this option to true to deploy your Terraform stack. 
  NAMESPACE - The namespace for the helm chart.


```

## AWS Examples.

- Using the runner to deploy a Helm Chart.

```bash
docker run --rm --name qa-bitops \
  -e KUBECONFIG_BASE64=$(cat /tmp/cluster.yaml | base64) \
  -e TF_APPLY=true -e CLUSTER_NAME=qa-bitops \
  -e ENVIRONMENT=qa -e AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID> \
  -e AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> \
  -e AWS_DEFAULT_REGION=<REGION> -e HELM_CHARTS=true \
  -v $(pwd):/opt/bitops_deployment qa-bitops:latest
```

- Using the runner to deploy Terraform.

```bash
docker run --rm --name qa-bitops \
  -e KUBECONFIG_BASE64=$(cat /tmp/cluster.yaml | base64) \
  -e TF_APPLY=true -e CLUSTER_NAME=qa-bitops \
  -e ENVIRONMENT=qa -e AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID> \
  -e AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> \
  -e AWS_DEFAULT_REGION=<REGION> \
  -v $(pwd):/opt/bitops_deployment qa-bitops:latest \
  --entrypoint="/bin/sh" /opt/bitops/scripts/terraform/terraform_apply.sh
```