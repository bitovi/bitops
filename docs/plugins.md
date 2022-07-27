# Plugins

BitOps' default image contains BitOps base along with pre-installed plugins:
* [bitops-terraform-plugin](https://github.com/bitops-plugins/terraform)
* [bitops-ansible-plugin](https://github.com/bitops-plugins/ansible)
* [bitops-cloudformation-plugin](https://github.com/bitops-plugins/cloudformation)
* [bitops-helm-plugin](https://github.com/bitops-plugins/helm)

You can create your own BitOps image to customize runtime behavior by installing your own plugins

## Creating your own BitOps
To create your own BitOps, you will need two files;
* **[bitops.configuration.yaml](../bitops.config.yaml)**: Contains configuration attributes that will modify how BitOps behaves
* **[Dockerfile.local](../prebuilt-config/dockerfile.template)**: Needs to source bitops as the latest image


### bitops.config.yaml
Best explained with an example, The default `bitops.config.yaml` looks like this:
```
bitops:
  # The `bitops.config.yaml` file contains the configuration values for the BitOps core.
  #   - Changing values will require that a new image be built
  #   - Customize your BitOps image by modifying the values found in the `bitops.config.yaml`

  fail_fast: true     # When set, will exit if any warning+ is raised, otherwise only exit on critical error
  run_mode: default   # (Unused for now)
  # LEVELS: [ DEBUG, INFO, WARNING, ERROR, CRITICAL ]
  logging:      
    level: DEBUG              # Sets the logging level
    color:
      enabled: true           # Enables colored logs
    filename: bitops-run      # log filename
    err: bitops.logs          # error logs filename
    path: /var/logs/bitops    # path to log folder
  opsrepo_root_default_dir: _default
  plugins:    
    aws:
      source: https://github.com/bitops-plugins/aws
    terraform:
      source: https://github.com/bitops-plugins/terraform
    cloudformation:
      source: https://github.com/bitops-plugins/cloudformation
    helm:
      source: https://github.com/bitops-plugins/helm
    kubectl:
      source: https://github.com/bitops-plugins/kubectl
    ansible:
      source: https://github.com/bitops-plugins/ansible
  deployments:
    cloudformation:
      plugin: cloudformation
    terraform:
      plugin: terraform
    helm:
      plugin: helm
    ansible:
      plugin: ansible

```
The repo for each plugin must be a `git clone`-able url. The name can be anything.

The order that plugins run is dependent on the `deployments` section. If a `depoyments` section isn't provided, it will attempt to process all folders in the BITOPS_ENVIRONMENT directory in alphabetical order.

**Dockerfile**
The only content that is needed to create a custom image is;

```
FROM bitovi/bitops:latest
```

## Creating your own Plugin
Creating a plugin is easy, you only need 4 files:
* `install.sh` - This script is called during plugin installation (docker build time). It should be used to install any dependencies needed for your plugin to function 
* `deploy.sh` - The main entrypoint for your plugin
* `bitops.schema.yaml` - Defines the parameters users have access to. The corresponding `bitops.config.yaml` within the BITOPS_ENVIRONMENT folder will configure the parameter values.
For more information, you can look at our [example plugin](https://github.com/bitops-plugins/example-plugin) repo that prints your name and favorite color!
* `plugin.config.yaml` - A file used to describes the plugin configuration to BitOps 