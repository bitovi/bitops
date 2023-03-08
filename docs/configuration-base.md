# Base Configuration

Each deployment tool is traditionally controlled with a set of CLI arguments. Instead of defining arguments within your pipeline configuration, they can instead either be defined with environment variables or in a `bitops.config.yaml` file. While the core schema for a `bitops.config.yaml` file is common between tools, the specific properties and environment variable equivalents vary from tool to tool.

> For more information on tool configuration, see [plugins](plugins.md).

-------------------
## Base Schema
All `bitops.config.yaml` files share the following structure
```
$tool
  cli: {}
  options: {}
```

* `$tool` - identifies the deployment tool
* `cli` - object that contains CLI arguments
* `options` - an object that offers additional control over how a tool executes

## Environment Variable Defaulting
Plugin environment variables are automatically mapped to the `bitops.config.yaml` keys. This means that you can use the same environment variable names as in the plugin config. For example, if you want to override the `ansible.cli.skip-tags` value, you can use the `BITOPS_ANSIBLE_SKIP_TAGS` environment variable. In this case, `BITOPS` is the prefix, `ANSIBLE` is the plugin name, and `SKIP_TAGS` is the key name (note hypens are replaced with underscores).

The precedence order is: `ENV` vars > `bitops.config.yaml` values > `bitops.config.schema.yaml` defaults. This way, ENV variables specified by user are taking highest precedence over config values and defaults. We recommend using them dynamically in CI/CD pipelines to control the deployment based on condition (PR run, branch, etc) or manually passing to the the BitOps docker container.

## OpsRepo configuration override
BitOps configuration is overridable by OpsRepo level `bitops.config.yaml` configuration files. The OpsRepo BitOps configuration file is expected to be found in the `OpsRepo/ENVIRONMENT` directory.

These configuration files use the same schema as the `bitops/bitops.schema.yaml`, all values in the bitops schema can be configured from the OpsRepo level `bitops.config.yaml`. The [bitops/bitops.config.yaml](https://github.com/bitovi/bitops/blob/main/bitops.config.yaml) file sets the default run pattern for bitops and can be used as an example to write OpsRepo bitops configuration.

*Example OpsRepo config file path*
```
OpsRepo/
|___ Dev/
|       bitops.config.yaml
|_______terraform/
|_______ansible/
```

*Example BitOps configuration override*
```
bitops:
  deployments:
    deploy-part-1:
      plugin: terraform
    deploy-part-2:
      plugin: terraform
    deploy-part-3:
      plugin: ansible
```

## Arbitrary Environment Variables
During the docker run command, you can specify an ENV var and it will be accessible during all processing stages of BitOps. This is useful for passing in secrets or other custom values used in the workflows.

## Common Configuration
There are some global configuration options that are shared among all tools and cloud providers during a BitOps run. These are set via environment variables

| Property          | Environment Variable | Description                                                  | Default | Required |
| ----------------- | -------------------- | ------------------------------------------------------------ | ------- | -------- |
| environment       | BITOPS_ENVIRONMENT   | Each BitOps run is done against a single environment. This property tells BitOps which environment to run. For more information on environments, see [Operations Repo Structure](operations-repo-structure.md#environment-directories). |         | Yes      |
| kubeconfig_base64 | KUBECONFIG_BASE64    | Base64 encoded `kubeconfig` file. Allows deployment tools to interact with a Kubernetes cluster. | `null`  | No       |

-------------------
## Cloud Providers
* [AWS](cloud-configuration/configuration-aws.md)

## Tool Configuration
* [Ansible](tool-configuration/configuration-ansible.md)
* [Helm](tool-configuration/configuration-helm.md)
* [Terraform](tool-configuration/configuration-terraform.md)
* [Cloudformation](tool-configuration/configuration-cloudformation.md)
