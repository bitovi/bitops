Each tool is traditionally controlled with a set of cli arguements. Instead of defining these cli arguments within your pipeline configuration, these arguements can instead either be defined with environment variables or in a `bitops.config.yml` file. While the core schema for a `bitops.config.yml` file is common betwen tools, the specific properties and environment variable equivilants vary from tool to tool.

# Common schema
All `bitops.config.yml` files share the following structure
```
$tool
  cli: {}
  options: {}
```
* `$tool` - identifies the deployment tool
* `cli` - object that contains cli arguments
* `options` - object that offers additional control over how a tool executes

# Cloud Providers
* [AWS](/docs/configuration/configuration-aws.md)

# Tool Configuration
* [Ansible](/docs/configuration/configuration-ansible.md)
* [Helm](/docs/configuration/configuration-helm.md)
* [Terraform](/docs/configuration/configuration-terraform.md)
