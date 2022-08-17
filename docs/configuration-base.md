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

## Arbitrary Environment Variables
During the docker run command, you can specify an ENV var and it will be accessible during all processing stages of BitOps. 

## Common Configuration
There are some global configuration options that are shared among all tools and cloud providers during a BitOps run. These are set via environment variables

-------------------
### environment
* **Environment Variable:** `BITOPS_ENVIRONMENT`
* **required:** yes

Each BitOps run is done against a single environment. This property tells BitOps which environment to run. For more information on environments, see [Operations Repo Structure](operations-repo-structure.md#environment-directories).

-------------------
### kubeconfig_base64
* **Environment Variable:** `KUBECONFIG_BASE64`
* **default:** `""`
* **required:** no

Base64 encoded `kubeconfig` file. Allows deployment tools to interact with a Kubernetes cluster.

-------------------
### default_replace
* **Environment Variable:** `BITOPS_DEFAULT_REPLACE`
* **default:** `false`

If true, [file mergers](default-environment.md) will replace instead of creating a copy during a merge.

-------------------
### skip_if_no_environment_changes
* **Environment Variable:** `SKIP_IF_NO_ENVIRONMENT_CHANGES`
* **default:** `""`
* **required:** no

If non-empty, it will evaluate the `git diff` to see if there are any changes in the specified `BITOPS_ENVIRONMENT` and will `exit 0` if not.

-------------------
## Cloud Providers
* [AWS](cloud-configuration/configuration-aws.md)

## Tool Configuration
* [Ansible](tool-configuration/configuration-ansible.md)
* [Helm](tool-configuration/configuration-helm.md)
* [Terraform](tool-configuration/configuration-terraform.md)
* [Cloudformation](tool-configuration/configuration-cloudformation.md)
