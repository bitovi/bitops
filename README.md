# Bitovi CI/CD Runner

The Bitovi CI/CD Runner is deployment tool for Kubernetes Deployments. We support the big three Cloud Platorms: Amazon Web Services (AWS), Microsoft Azure Cloud (Azure) and Google Cloud Engine (GCE). The Bitovi runner will deploy your application as a Helm Chart on either platform. Simply pass the appropriate options to our deployment script to select Cloud Provider - (AWS, AC, GCE) or CI/CD Provider (Jenkins, AWS, GitLab, Travis). See our configuration section below.

## How it works.

The Bitovi CI/CD Runner is a boiler plate docker image for traditional DevOps 
work. It can handle Amazon AWS, Microsoft Azure.

BitOps is a docker container, built as a boiler plate devops engine for deploying kubernetes applications from a cloud native/agnostic point of view.

## Configuration Options

To customize the defaults in the docker 

```bash

./scripts/deploy/run_deployments.sh --help

options:
--help 	 Show options for this script
--kubeconfig 	 Pass in the environment variable containing the kubernetes config. If left empty, terraform will create a new kubernetes cluster.
--terraform-directory 	 The directory for the terraform deployment.
--environment 	  The environment to use: qa or prod
--terraform-plan 	  Run Terraform plan. Expected values: true or false.
--terraform-apply 	 Deploy terraform. Expected values: true or false.
--terraform-destroy 	 Destroy terraform stack. Expected values: true or false.
--helm-charts 	 The directory containing the helm charts.
--ansible-directory 	 The directory containing your ansible playbooks.
--install-prometheus 	 Install Prometheus on the cluster. Expected values: true or false
--install-grafana 	 Install Grafana on the cluster. Expected values: true or false.
--install-loki 	 Install Loki on the cluster. Expected values: true or false.
--domain-name 	 Set the domain name. Required for Prometheus and Grafana.
--namespace 	 Set the namespace to be used by Prometheus and Grafana.
--install-default-charts 	 Install Prometheus, Grafana and Loki on the cluster. Expected values: true or false.

```

## Examples

- Using the runner to deploy a Helm Chart.

```bash
docker-compose exec -T bitops /bin/bash -cx "scripts/deploy/run_deployments.sh --helm-charts /opt/deploy/qa/microservices/helm-chart --environment qa"
```

- Using the runner to deploy Terraform.

```bash
docker-compose exec -T bitops /bin/bash -cx "scripts/deploy/run_deployments.sh --terraform-directory /opt/deploy/terraform --terraform-apply true"
```