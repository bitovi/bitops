# Execution Lifecycle

## Lifecycle hooks
Within each tool directory, you can optionally have a `bitops.before-deploy.d/` and/or a `bitops.after-deploy.d/`. As shown above, if any shell scripts exist within these directories, bitops will execute them first.

This is a useful way to extend the functionality of bitops. A popular usecase we've seen is loading secrets or dynamically editing `bitops.config.yml`

## Detailed Execution Flow
A single run of Bitops will

1. Copy the contents of `/opt/bitops_deployment` to a temporary working directory
2. Attempt to setup a cloud provider
3. If a `terraform/` directory exists within the selected environment
    * Run any `bitops.before-deploy.d/*.sh` scripts - [TODO](https://github.com/bitovi/bitops/issues/17) 
    * Load `bitops.config.yml` and set environment
    * Merge contents with [Default environment](default-environment.md) - [TODO](https://github.com/bitovi/bitops/issues/18)
    * Select terraform version
    * Run `terraform init`
    * Select `terraform workspace`
    * Run `terraform plan`
    * Run `terraform apply` or `terraform destroy`
    * Run any `bitops.after-deploy.d/*.sh` scripts - [TODO](https://github.com/bitovi/bitops/issues/17)
4. If a `ansible/` directory exists within the selected environment
    * Run any `bitops.before-deploy.d/*.sh` scripts - [TODO](https://github.com/bitovi/bitops/issues/17)
    * Load `bitops.config.yml` and set environment - [TODO](https://github.com/bitovi/bitops/issues/17)
    * Merge contents with [Default environment](default-environment.md) - [TODO](https://github.com/bitovi/bitops/issues/18)
    * Run `ansible-playbook $playbook` for each `*.yaml` or `*.yml` file in `$env/ansible/` 
    * Run any `bitops.after-deploy.d/*.sh` scripts - [TODO](https://github.com/bitovi/bitops/issues/17)
4. If a `helm/` directory exists within the selected environment
    * Run the following for `$env/helm/$ENVIRONMENT_HELM_SUBDIRECTORY/` or for all charts in `$env/helm/`
        * Run any `bitops.before-deploy.d/*.sh` scripts - [TODO](https://github.com/bitovi/bitops/issues/17)
        * Load `bitops.config.yml` and set environment
        * Merge contents with [Default environment](default-environment.md)
        * Use `$KUBE_CONFIG_PATH` if defined, if not use aws cli to build .kubeconfig
        * Gather all values files - TODO document
        * Run `helm dep up`
        * Run `helm upgrade` or `helm install`
        * Run `helm rollback` on failure
        * Run any `bitops.after-deploy.d/*.sh` scripts
        * TODO `helm_install_external_charts` and `helm_install_charts_from_s3` never run!
4. If a `cloudformation/` directory exists within the selected environment
    * Run any `bitops.before-deploy.d/*.sh` scripts - [TODO](https://github.com/bitovi/bitops/issues/17)
    * Load `bitops.config.yml` and set environment
    * Merge contents with [Default environment](default-environment.md) - [TODO](https://github.com/bitovi/bitops/issues/18)
    * Run cfn template validation
    * Create or delete cfn stack. Wait for completion
    * Run any `bitops.after-deploy.d/*.sh` scripts - [TODO](https://github.com/bitovi/bitops/issues/17)
