# Bitops Configuration

Each tool is traditionally controlled with a set of cli arguements. Instead of defining these cli arguments within your pipeline configuration, these arguements can instead either be defined with environment variables or in a `bitops.config.yml` file. While the core schema for a `bitops.config.yml` file is common betwen tools, the specific properties and environment variable equivilants vary from tool to tool.

## Common Configuration
There are some global configuration options that are shared among all tools and cloud providers in a bitops run. These are set via environment variables

-------------------
### environment
* **Environment Variable:** `ENVIRONMENT`
* **default:** `""`
* **required:** yes

Each bitops run is done against a single environment. This property tells bitops which environment to run

-------------------
### kubeconfig_base64
* **Environment Variable:** `KUBECONFIG_BASE64`
* **default:** `""`
* **required:** no

Base64 encodd .kubeconfig file. Allows deployment tools to interact with a kubernetes cluster

-------------------
### debug
* **Environment Variable:** `DEBUG`
* **default:** `""`
* **required:** no

If true, will enable verbose logging

-------------------
## Common schema
All `bitops.config.yml` files share the following structure
```
$tool
  cli: {}
  options: {}
```
* `$tool` - identifies the deployment tool
* `cli` - object that contains cli arguments
* `options` - object that offers additional control over how a tool executes

## Cloud Providers
* [AWS](/docs/configuration/configuration-aws.md)

## Tool Configuration
* [Ansible](/docs/configuration/configuration-ansible.md)
* [Helm](/docs/configuration/configuration-helm.md)
* [Terraform](/docs/configuration/configuration-terraform.md)
* [Cloudformation](/docs/configuration/configuration-cloudformation.md)