> ⚠️ Note from the developers: We are currently in the process of moving our documentation and so the below documentation is only partially correct. For more information on this tool please checkout our [plugin documentation](https://github.com/bitops-plugins/terraform).

# Bitops Plugin for Terraform
## Deployment

`terraform` plugin uses `bitops.config.yaml` located in the operations repo when deploying resources using terraform scripts.

### Example `bitops.config.yaml`, minimum required
```
terraform: {}
```

### Example 2 `bitops.config.yaml`
```
terraform:
    cli:
        var-file: my-vars.tfvars
        target: terraform.module.resource
        backend-config:
            - KEY1=foo
            - KEY2=bar
    options:
        stack-action: "plan"
        workspace: test
```

The `terraform` plugin will run `terraform init` and `terraform plan` on every execution.

Run BitOps with the environmental variable `TERRAFORM_APPLY` set to `true` or set `stack-action` in the `bitops.config.yaml` file to apply to run `terraform apply`.

## CLI and options configuration of Terraform `bitops.schema.yaml`

### Terraform BitOps Schema

[bitops.schema.yaml](https://github.com/bitops-plugins/terraform/blob/main/bitops.schema.yaml)

-------------------
### var-file
* **BitOps Property:** `var-file`
* **CLI Argument:** `--var-file`
* **Environment Variable:** `BITOPS_TF_VAR_FILE`
* **default:** `""`
* **Required:** `false`
* **Description:** Terraform Varaible file

-------------------
### target
* **BitOps Property:** `target`
* **CLI Argument:** `--target`
* **Environment Variable:** `BITOPS_TF_TARGET`
* **default:** `""`
* **Required:** `false`
* **Description:**

-------------------
### backend-config
* **BitOps Property:** `backend-config`
* **CLI Argument:** `--KEY1=foo --KEY2=bar`
* **Environment Variable:** ``
* **default:** `""`
* **Required:** `false`
* **Description:**

-------------------


## Options Configuration

-------------------

### stack-action
* **BitOps Property:** `stack-action`
* **Environment Variable:** `BITOPS_TERRAFORM_COMMAND`
* **default:** `"plan"`
* **Required:** `false`
* **Description:** Controls what terraform command to run. e.g. `apply`, `destroy`, etc. 


-------------------
<!-- ### version
* **BitOps Property:** `version`
* **Environment Variable:** `BITOPS_TERRAFORM_VERSION`
* **default:** `"1.2.2"`
* **Required:** `false`
* **Description:** Allows customziation of which version of terraform to run

* **NOTE:** `This feature currently not supported.`  -->

-------------------
### workspace
* **BitOps Property:** `workspace`
* **Environment Variable:** `BITOPS_TERRAFORM_WORKSPACE`
* **default:** `""`
* **Required:** `false`
* **Description:** Will select a terraform workspace using `terraform workspace new $TERRAFORM_WORKSPACE || terraform workspace select $TERRAFORM_WORKSPACE` prior to running other terraform commands.

-------------------

## Additional Environment Variable Configuration
Although not captured in `bitops.config.yaml`, the following environment variables can be set to further customize behaviour.  Set the value of the environental variable to `true` to enable its behavior.

-------------------
### SKIP_DEPLOY_TERRAFORM
Will skip all terraform executions. This superseeds all other configuration.

-------------------
### TERRAFORM_APPLY
Will force call `terraform apply`.

-------------------
### TERRAFORM_DESTROY
Will force call `terraform destroy`.

-------------------
### INIT_UPGRADE
Will add `--upgrade` flag to the init command.
