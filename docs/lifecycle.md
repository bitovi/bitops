# Execution Lifecycle

## Lifecycle hooks
Within each tool directory, you can optionally have a `bitops.before-deploy.d/` and/or a `bitops.after-deploy.d/`. If any shell scripts exist within these directories, bitops will execute them first.

This is a useful way to extend the functionality of bitops. A popular usecase we've seen is loading secrets or dynamically editing `bitops.config.yml`

## Detailed Execution Flow

![lifecycle diagram](assets/images/lifecycle.png)

A single run of BitOps will:

### 1. Copy contents of bitops_deployment to tempdir
Copys the contents of `/opt/bitops_deployment` to a temporary working directory.

### 2. Setup Cloud Provider
Attempts to setup a cloud provider (AWS) using the credentials passed in at container execution time.

### 3. Check for Terraform Schema
If a `terraform/` directory exists within the selected environment:

* Run any `bitops.before-deploy.d/*.sh` scripts 
* Load `bitops.config.yml` and set environment
* Merge contents with [Default environment](default-environment.md) - [TODO](https://github.com/bitovi/bitops/issues/18)
* Select terraform version
* Run `terraform init`
* Select `terraform workspace`
* Run `terraform plan`
* Run `terraform apply` or `terraform destroy`
* Run any `bitops.after-deploy.d/*.sh` scripts

### 4. Check for Ansible Schema
If an `ansible/` directory exists within the selected environment:

* Run any `bitops.before-deploy.d/*.sh` scripts
* Load `ansible/extra_env` environment config file if exists
* Load `bitops.config.yml` and set environment
* Merge contents with [Default environment](default-environment.md) - [TODO](https://github.com/bitovi/bitops/issues/18)
* Run `ansible-playbook $playbook` for each `*.yaml` or `*.yml` file in `$env/ansible/` 
* Run any `bitops.after-deploy.d/*.sh` scripts

### 5. Check for Helm Schema
If a `helm/` directory exists within the selected environment:

* Run the following for `$env/helm/$ENVIRONMENT_HELM_SUBDIRECTORY/` or for all charts in `$env/helm/`
* Run any `bitops.before-deploy.d/*.sh` scripts
* Load `bitops.config.yml` and set environment
* Merge contents with [Default environment](default-environment.md)
* Use `$KUBE_CONFIG_PATH` if defined, if not use aws cli to build .kubeconfig
* Gather all values files - TODO document
* Run `helm dep up`
* Run `helm upgrade` or `helm install`
* Run `helm rollback` on failure
* Run any `bitops.after-deploy.d/*.sh` scripts
* TODO `helm_install_external_charts` and `helm_install_charts_from_s3` never run!

### 6. Check for Cloudformation Schema
If a `cloudformation/` directory exists within the selected environment:

* Run any `bitops.before-deploy.d/*.sh` scripts
* Load `bitops.config.yml` and set environment
* Merge contents with [Default environment](default-environment.md) - [TODO](https://github.com/bitovi/bitops/issues/18)
* Run cfn template validation
* Create or delete cfn stack. Wait for completion
* Run any `bitops.after-deploy.d/*.sh` scripts
