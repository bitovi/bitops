# Base Configuration

Each deployment tool is traditionally controlled with a set of cli arguments. Instead of defining arguments within your pipeline configuration, they
 can instead either be defined with environment variables or in a `bitops.config.yml` file. While the core schema for a `bitops.config.yml` file is common betwen tools, the specific properties and environment variable equivilants vary from tool to tool.

-------------------
## Base Schema
All `bitops.config.yml` files share the following structure
```
$tool
  cli: {}
  options: {}
```
* `$tool` - identifies the deployment tool
* `cli` - object that contains cli arguments
* `options` - object that offers additional control over how a tool executes

## Common Configuration
There are some global configuration options that are shared among all tools and cloud providers in a bitops run. These are set via environment variables

-------------------
### environment
* **Environment Variable:** `ENVIRONMENT`
* **default:** `""`
* **required:** yes

Each bitops run is done against a single environment. This property tells bitops which environment to run. For more information on environments, see [Operations Repo Structure](operations-repo-structure.md#environment-directories).

-------------------
### kubeconfig_base64
* **Environment Variable:** `KUBECONFIG_BASE64`
* **default:** `""`
* **required:** no

Base64 encoded `kubeconfig` file. Allows deployment tools to interact with a kubernetes cluster

-------------------
### debug
* **Environment Variable:** `DEBUG`
* **default:** `""`
* **required:** no

If true, will enable verbose logging

-------------------
### default_replace
* **Environment Variable:** `BITOPS_DEFAULT_REPLACE`
* **default:** `false`

If true, [file mergers](default-environment.md) will replace instead of create a copy during a merge

-------------------
## Cloud Providers
* [AWS](cloud-configuration/configuration-aws.md)

## Tool Configuration
* [Ansible](tool-configuration/configuration-ansible.md)
* [Helm](tool-configuration/configuration-helm.md)
* [Terraform](tool-configuration/configuration-terraform.md)
* [Cloudformation](tool-configuration/configuration-cloudformation.md)