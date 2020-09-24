# Bitops

---------------------

![LICENSE](https://img.shields.io/github/license/bitovi/bitops)
![Latest Release](https://img.shields.io/github/v/release/bitovi/bitops)

Bitops is an opnionated deployment tool that bundles [supported devops tools](#supported-tools) along with a built in understanding of an [operations repository structure](/docs/operations-repo.md). The combination of these two things makes it easy to automate the provisionning and configuration of cloud infrastructure from basic VMs to complex kubernetes deployments.

---------------------

## Features

* **[Configurable](/docs/configuration/configuration.md):** Configure how you want bitops to deploy your application with environment variables or yaml
* **[Event Hooks](/docs/operations-repo.md#lifecycle-directories):** If bitops doesn't have built-in support for your usecase, execute arbitrary bash scripts at different points in bitops'

## How it works

BitOps is a boiler plate docker image for traditional DevOps work. An operations repository is mounted to the bitops image's `/opt/bitops_deployment` directory.  Bitops will
* Auto-detect any configuration belonging to one of its [supported tools](#supported-tools)
* Loop through each tool and
  * Run any pre-execute hooks
  * Read in `yml` configuration
  * Execute the tool
  * Run any post-execute hooks

## Install BitOps
Bitops is packaged as a docker image and is available on dockerhub.
```
docker pull bitovi/bitops
cd $YOUR_OPERATIONS_REPO
docker run bitovi/bitops -v .:/opt/bitops_deployment
```

## Configure Bitops
[Docs](/docs/configuration/configuration.md)


## Supported Tools
* Provision infrastructure with [Terraform](https://www.terraform.io/)
* Configure infrastructure with [Ansible](https://www.ansible.com/)
* Deploy to kubernetes with [Helm](https://helm.sh/)

## Supported Cloud Providers

* Amazon Web Services (AWS)
* Microsoft Azure Cloud (Azure) - TODO - https://github.com/bitovi/bitops/issues/13
* Google Cloud Engine (GCE) - TODO - https://github.com/bitovi/bitops/issues/14

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
  TERRAFORM_APPLY - Set this option to true to deploy your Terraform stack. 
  NAMESPACE - The namespace for the helm chart.


```

## AWS Examples.

- Using the runner to deploy a Helm Chart.

```bash
docker run --rm --name qa-bitops \
  -e KUBECONFIG_BASE64=$(cat /tmp/cluster.yaml | base64) \
  -e TERRAFORM_APPLY=true -e CLUSTER_NAME=qa-bitops \
  -e ENVIRONMENT=qa -e AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID> \
  -e AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> \
  -e AWS_DEFAULT_REGION=<REGION> -e HELM_CHARTS=true \
  -v $(pwd):/opt/bitops_deployment qa-bitops:latest
```

- Using the runner to deploy Terraform.

```bash
docker run --rm --name qa-bitops \
  -e KUBECONFIG_BASE64=$(cat /tmp/cluster.yaml | base64) \
  -e TERRAFORM_APPLY=true -e CLUSTER_NAME=qa-bitops \
  -e ENVIRONMENT=qa -e AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID> \
  -e AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> \
  -e AWS_DEFAULT_REGION=<REGION> \
  -v $(pwd):/opt/bitops_deployment qa-bitops:latest \
  --entrypoint="/bin/sh" /opt/bitops/scripts/terraform/terraform_apply.sh
```