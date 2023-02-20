# Execution Lifecycle

## Lifecycle hooks
Within each tool directory, you can optionally have a `bitops.before-deploy.d/` and/or a `bitops.after-deploy.d/`. If any shell scripts exist within these directories, BitOps will execute them in alphanumeric order.

This is a useful way to extend the functionality of BitOps. A popular use case we've seen is loading secrets, preparing the environment or dynamically editing `bitops.config.yaml`.

## Detailed Execution Flow

![lifecycle diagram](assets/images/lifecycle.png)

### Main Execution Flow
A single run of BitOps will:

1. Copy the contents of `/opt/bitops_deployment` to a temporary working directory
2. Attempt to setup a cloud provider
3. If a `terraform/` directory exists within the selected environment:
    * Run any `bitops.before-deploy.d/*.sh` scripts 
    * Load `bitops.config.yaml` and set environment
    * Merge contents with [Default environment](default-environment.md) - [TODO](https://github.com/bitovi/bitops/issues/18)
    * Select terraform version
    * Run `terraform init`
    * Select `terraform workspace`
    * Run `terraform plan`
    * Run `terraform apply` or `terraform destroy`
    * Run any `bitops.after-deploy.d/*.sh` scripts
4. If a `ansible/` directory exists within the selected environment:
    * Run any `bitops.before-deploy.d/*.sh` scripts
    * Load `bitops.config.yaml` and set environment
    * Merge contents with [Default environment](default-environment.md) - [TODO](https://github.com/bitovi/bitops/issues/18)
    * Run `ansible-playbook playbook.yaml` in `$env/ansible/` 
    * Run any `bitops.after-deploy.d/*.sh` scripts
4. If a `helm/` directory exists within the selected environment:
    * Run the following for `$env/helm/$ENVIRONMENT_HELM_SUBDIRECTORY/` or for all charts in `$env/helm/`
        * Run any `bitops.before-deploy.d/*.sh` scripts
        * Load `bitops.config.yaml` and set environment
        * Merge contents with [Default environment](default-environment.md)
        * Use `$KUBE_CONFIG_PATH` if defined, if not use AWS CLI to build `.kubeconfig`
        * Gather all values files - TODO document
        * Run `helm dep up`
        * Run `helm upgrade` or `helm install`
        * Run `helm rollback` on failure
        * Run any `bitops.after-deploy.d/*.sh` scripts
        * TODO `helm_install_external_charts` and `helm_install_charts_from_s3` never run!
4. If a `cloudformation/` directory exists within the selected environment:
    * Run any `bitops.before-deploy.d/*.sh` scripts
    * Load `bitops.config.yaml` and set environment
    * Merge contents with [Default environment](default-environment.md) - [TODO](https://github.com/bitovi/bitops/issues/18)
    * Run cfn template validation
    * Create or delete cfn stack. Wait for completion
    * Run any `bitops.after-deploy.d/*.sh` scripts

### Imported Environment Variables
The plugin config values and defaults are overriden by user environment variables passed to BitOps by prefixing them with `BITOPS_`. For example, `BITOPS_ANSIBLE_SKIP_TAGS=tag1,tag2` will set the plugin's config `ansible.cli.skip-tags` value to `tag1,tag2`.
See [Environemnt Variables Defaulting](configuration-base.md#environemnt-variables-defaulting) for more information.

### Exported Environment Variables
BitOps exports the environment variables to the plugin when a ENV var name is specified in `bitops.schema.yaml` via `export_env`. This is useful for passing values to lifecycle hooks, custom scripts, or directly to the plugin executable.
