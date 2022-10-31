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

| Property       | Environment Variable | CLI Argument          | Description             | Default | Required |
| -------------- | -------------------- | --------------------- | ----------------------- | ------- | -------- |
| var-file       | BITOPS_TF_VAR_FILE   | --var-file            | Terraform Varaible file | `null`  | No       |
| target         | BITOPS_TF_TARGET     | --target              |                         | `null`  | No       |
| backend-config |                      | --KEY1=foo --KEY2=bar |                         | `null`  | No       |


## Options Configuration

| Property     | Environment Variable       | Description                                                  | Default | Required |
| ------------ | -------------------------- | ------------------------------------------------------------ | ------- | -------- |
| stack-action | BITOPS_TERRAFORM_COMMAND   | Controls what terraform command to run. e.g. `apply`, `destroy`, etc. | `plan`  | No       |
| workspace    | BITOPS_TERRAFORM_WORKSPACE | Will select a terraform workspace using `terraform workspace new $TERRAFORM_WORKSPACE ||terraform workspace select $TERRAFORM_WORKSPACE` prior to running other terraform commands. | `null`  | No       |

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
