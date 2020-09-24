# Terraform
Terraform will always run `terraform init` and `terraform plan` on every execution.

## Example bitops.config.yml
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

## CLI Configuration

-------------------
### var-file
* **Bitops Property:** `var-file`
* **CLI Argument:** `--var-file`
* **Environment Variable:** `TF_VAR_FILE`
* **default:** `""`
-------------------
### target
* **Bitops Property:** `target`
* **CLI Argument:** `--target`
* **Environment Variable:** `TF_TARGET`
* **default:** `""`
-------------------

## Options Configuration

-------------------
### version
* **Bitops Property:** `version`
* **Environment Variable:** `TERRAFORM_VERSION`
* **default:** `"0.12.29"`

Allows customziation of which version of terraform to run
-------------------
### command
* **Bitops Property:** `command`
* **Environment Variable:** `TERRAFORM_COMMAND`
* **default:** `"plan"`

Controls what terraform command to run. e.g. `apply`, `destroy`, etc.
-------------------
### workspace
* **Bitops Property:** `workspace`
* **Environment Variable:** `TERRAFORM_WORKSPACE`
* **default:** `""`

Controls what terraform command to run. e.g. `apply`, `destroy`, etc.
-------------------

## Additional Environment Variable Configuration
Although not captured in `bitops.config.yml`, the following environment variables can be set to further customize behaviour
-------------------
### SKIP_DEPLOY_TERRAFORM
Will skill all terraform executions. This superseeds all other configuration
-------------------
### TERRAFORM_APPLY
Will force call `terraform apply`
-------------------
### TERRAFORM_DESTROY
Will force call `terraform destroy`
-------------------