Note from the developers: We are currently in the process of moving our documentation and so the below documentation is only partially correct. For more information on this tool please checkout our [plugin documentation](https://github.com/bitops-plugins/terraform) 

# Terraform
Terraform will always run `terraform init` and `terraform plan` on every execution.

## Example bitops.config.yaml
```
terraform:
    cli:
        var-file: my-vars.tfvars
        target: terraform.module.resource
        backend-config:
            - KEY1=foo
            - KEY2=bar
    options:
        command: apply
        version: "0.13.2"
        workspace: test
```

## CLI Configuration

-------------------
### var-file
* **BitOps Property:** `var-file`
* **CLI Argument:** `--var-file`
* **Environment Variable:** `TF_VAR_FILE`
* **default:** `""`

-------------------
### target
* **BitOps Property:** `target`
* **CLI Argument:** `--target`
* **Environment Variable:** `TF_TARGET`
* **default:** `""`

-------------------
### backend-config
* **BitOps Property:** `backend-config`
* **CLI Argument:** `--KEY1=foo --KEY2=bar`
* **Environment Variable:** ``
* **default:** `""`

-------------------

## Options Configuration

-------------------
### version
* **BitOps Property:** `version`
* **Environment Variable:** `TERRAFORM_VERSION`
* **default:** `"0.12.29"`

Allows customziation of which version of terraform to run

-------------------
### command
* **BitOps Property:** `command`
* **Environment Variable:** `TERRAFORM_COMMAND`
* **default:** `"plan"`

Controls what terraform command to run. e.g. `apply`, `destroy`, etc.

-------------------
### workspace
* **BitOps Property:** `workspace`
* **Environment Variable:** `TERRAFORM_WORKSPACE`
* **default:** `""`

Will select a terraform workspace using `terraform workspace new $TERRAFORM_WORKSPACE || terraform workspace select $TERRAFORM_WORKSPACE` prior to running other terraform commands.

-------------------

## Additional Environment Variable Configuration
Although not captured in `bitops.config.yaml`, the following environment variables can be set to further customize behaviour

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
### INIT_UPGRADE
Will add `--upgrade` flag to the init command
