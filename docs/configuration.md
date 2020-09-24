Each tool is traditionally controlled with a set of cli arguements. Instead of defining these cli arguments within your pipeline configuration, these arguements can instead be defined using environment variables or within a `bitops.config.yml` file. While the core schema for this file is common betwen tools, the specific properties and environment variable equivilants vary from tool to tool.

## Common schema
All `bitops.config.yml` files share the following structure
```
$tool
  cli: {}
  options: {}
```
`$tool` - identifies the deployment tool
`cli` - object that contains cli arguments
`options` - object that offers additional control over how a tool executes

## Cloud Providers
TODO

## Tool Congiuration

### Ansible

#### Schema

##### CLI Configuration
TODO

##### Options Configuration
TODO

##### Example bitops.config.yml
TODO

### Helm

#### Schema

##### CLI Configuration
TODO

##### Options Configuration
TODO

##### Example bitops.config.yml
TODO

### Terraform
Terraform will always run `terraform init` and `terraform plan` on every execution

#### Schema

##### CLI Configuration

##### var-file
**Bitops Property**: `var-file`
**CLI Argument**: `--var-file`
**Environment Variable**: `TF_VAR_FILE`
**default**: `""`

##### target
**Bitops Property**: `target`
**CLI Argument**: `--target`
**Environment Variable**: `TF_TARGET`
**default**: `""`

##### Options Configuration

##### version
**Bitops Property**: `version`
**Environment Variable**: `TERRAFORM_VERSION`
**default**: `"0.12.29"`
Allows customziation of which version of terraform to run

##### command
**Bitops Property**: `command`
**Environment Variable**: `TERRAFORM_COMMAND`
**default**: `"plan"`
Controls what terraform command to run. e.g. `apply`, `destroy`, etc.

##### workspace
**Bitops Property**: `workspace`
**Environment Variable**: `TERRAFORM_WORKSPACE`
**default**: `""`
Controls what terraform command to run. e.g. `apply`, `destroy`, etc.

##### Example bitops.config.yml
```
terraform:
    cli:
        var-file: my-vars.tfvars
        target: terraform.module.resource
    options:
        command: apply
        version: "0.13.2"
        workspace: test
```