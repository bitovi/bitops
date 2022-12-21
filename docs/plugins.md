# Plugins
Deployment tools that BitOps can use at deploy time are called Plugins.

A BitOps plugin is a repository with files that tell BitOps how the tool dependencies are installed into a BitOps image and how BitOps can use the tool at deploy time.

You can create your own BitOps image to customize runtime behavior by installing your own plugins.

> Check out the [bitops-plugins](https://github.com/bitops-plugins) org in GitHub to see available plugins!

## Pre-Built Images

BitOps' default image called `omnibus` contains BitOps `base` along with the following pre-installed plugins:

* [bitops-aws-plugin](https://github.com/bitops-plugins/aws)
* [bitops-cloudformation-plugin](https://github.com/bitops-plugins/cloudformation)
* [bitops-terraform-plugin](https://github.com/bitops-plugins/terraform)
* [bitops-ansible-plugin](https://github.com/bitops-plugins/ansible)
* [bitops-helm-plugin](https://github.com/bitops-plugins/helm)
* [bitops-kubectl-plugin](https://github.com/bitops-plugins/kubectl)


> See [prebuilt-config](https://github.com/bitovi/bitops/tree/main/prebuilt-config) for the list of other available pre-built images and [bitops images and versions](versioning.md) to understand how these images are named and tagged on Docker Hub.

## Creating your own BitOps image
To create your own BitOps, you will need two files:

* **[bitops.config.yaml](../bitops.config.yaml)**: Contains configuration attributes that will modify how BitOps behaves
* **[Dockerfile](../prebuilt-config/dockerfile.template)**: Needs to use the BitOps base image in the `FROM` directive


### bitops.config.yaml
Best explained with an example, The default `bitops.config.yaml` looks like this:
```yaml
bitops:
  # The `bitops.config.yaml` file contains the configuration values for the BitOps core.
  #   - Changing values will require that a new image be built
  #   - Customize your BitOps image by modifying the values found in the `bitops.config.yaml`

  fail_fast: true     # When set, will exit if any warning+ is raised, otherwise only exit on critical error
  # LEVELS: [ DEBUG, INFO, WARNING, ERROR, CRITICAL ]
  logging:      
    level: DEBUG              # Sets the logging level
    color:
      enabled: true           # Enables colored logs
    filename: bitops-run      # log filename
    err: bitops.logs          # error logs filename
    path: /var/logs/bitops    # path to log folder
    # Define the secrets to mask
    masks:
      - # regex to search
        # looks for `BITOPS_KUBECONFIG_BASE64={string}`
        search:  (.*BITOPS_KUBECONFIG_BASE64.*\=)(.*\n)
        # replace the value part
        replace: '\1*******\n'
      - # looks for `The namespace kube-system exists`
        search:  (.*The namespace )(kube-system)( exists.*)
        #replace kube-system
        replace: '\1*******\3'
      - # see: https://regex101.com/r/44Ldz7/1
        # looks for `AWS_ACCESS_KEY_ID={string}`
        search: (AWS_ACCESS_KEY_ID=)(\S+)
        replace: \1*******
      - # looks for `AWS_SECRET_ACCESS_KEY={string}`
        search: (AWS_SECRET_ACCESS_KEY=)(\S+)
        replace: \1*******
  default_folder: _default
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

The repo for each plugin must be a `git clone`-able URL. The name can be anything.

The order that plugins run is dependent on the `deployments` section. If a `deployments` section isn't provided, it will attempt to process all folders in the `BITOPS_ENVIRONMENT` directory in alphabetical order.

### Dockerfile
The only content that is needed to create a custom image is:

```
FROM bitovi/bitops:base
```

## Creating your own Plugin
Creating a plugin is easy, you only need 4 files:

* `install.sh` - This script is called during plugin installation (Docker build time). It should be used to install any dependencies needed for your plugin to function 
* `deploy.sh` - The main entrypoint for your plugin at deploy time
* `bitops.schema.yaml` - Defines the parameters users have access to. The corresponding `bitops.config.yaml` within the `BITOPS_ENVIRONMENT` folder will configure the parameter values.
* `plugin.config.yaml` - A file used to describe the plugin configuration.

> For more information, you can look at our [example plugin](https://github.com/bitops-plugins/example-plugin) repo that prints your name and favorite color!

> For more information on developing with plugins locally, see [development/local-plugin-creation](./development/local-plugin-creation.md).
