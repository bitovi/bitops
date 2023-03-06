Here is the list of upgrade notes for major breaking changes that you need to be aware of when migrating between the BitOps versions.

## v2.4
* `ANSIBLE_ROOT` ENV var in Ansible plugin was removed. Use `BITOPS_OPSREPO_ENVIRONMENT_DIR` instead, which is consistent across all plugins.
* Plugin environment variables are now automatically mapped to the plugin schema. This means that you can now use the same environment variable names as in the plugin schema. For example, if you want to override the `ansible.cli.skip-tags` value, you can now use the `BITOPS_ANSIBLE_SKIP_TAGS` environment variable. This is true for all the plugins. The precedence order is: `ENV` vars > `bitops.config.yaml` values > `bitops.config.schema.yaml` defaults.
Keep the new convention in mind when upgrading to `v2.4` as it may clash with your existing environment variables.

## v2.2
* Terraform plugin `stack-action` was moved from `options` to `cli` section in `bitops.config.yaml`.
You need to update your configuration from old:
```yaml
terraform:
  cli: {}
  options:
    stack-action: "plan"
```
to the new format:
```yaml
terraform:
  cli:
    stack-action: "plan"
  options: {}
```

* ENV variables used to skip an individual plugin deployment were updated to follow a common consistent format:
    - `SKIP_DEPLOY_TERRAFORM` -> `TERRAFORM_SKIP_DEPLOY`
    - `SKIP_DEPLOY_HELM` -> `HELM_SKIP_DEPLOY`
    - `SKIP_DEPLOY_ANSIBLE` -> `ANSIBLE_SKIP_DEPLOY`
    - `SKIP_DEPLOY_CLOUDFORMATION` -> `CFN_SKIP_DEPLOY`

---------
## v2.0

### BitOps Core

#### CHANGED: `ENVIRONMENT` -> `BITOPS_ENVIRONMENT` var
BitOps is no longer using the `ENVIRONMENT` value, it instead uses `BITOPS_ENVIRONMENT`.
Please rename your variables.

#### CHANGED: `BITOPS_` Export Prefixes
BitOps core exported environment variables now have a prefix of `BITOPS_`.

**Examples**

- `BITOPS_TERRAFORM_ENV_VAR`
- `BITOPS_ANSIBLE_ENV_VAR`

#### CHANGED: `bitops.config.yaml` stack-action
Ops repo level `bitops.config.yaml` have had one important update; The CLI attribute `stack-action` has been added. This attribute is used to tell the BitOps plugin which method it is invoking.

For example, the terraform plugin has 3 stack-actions: `plan`, `apply`, `destroy`.

**Old method**
```
terraform:
  cli: {}
  options:
    command: apply
```

**New method**
```
terraform:
  cli: {}
  options:
    stack-action: apply
```

This pattern is now used by BitOps to standardize how a plugin specifies an action.

#### NEW: Default Folder Configuration
A new attribute was added to `bitops.config.yaml` to define the default folder name. This attribute is evaluated when building a BitOps custom image.

**New method**
```
bitops:
  default_folder: _default
```

The compatible environment variable to override this setting is `BITOPS_DEFAULT_FOLDER`.

### Plugins
#### Ansible
*depreciated attributes*

- `ansible.cli.vault_id`
- `ansible.cli.vault_password`
- `ansible.options.verbosity`

<hr/>

#### Terraform
*new attributes*

- `ansible.options.init-upgrade`

<hr/>

#### Helm
*changed attributes*

- `helm.options.uninstall-charts` --> Changed to --> `helm.options.uninstall`
- `helm.options.kubeconfig.fetch.enabled` --> Changed to --> `helm.options.k8s.fetch.kubeconfig`

*new attributes*

- `helm.options.default-root-dir`
- `helm.options.default-dir-flag`
- `helm.options.default-sub-dir`

<hr/>

#### Cloudformation
*changed attributes*

- `cloudformation.options.cfn-files.parameters.enabled` --> Changed to --> `cloudformation.options.cfn-files.parameters.template-param-flag`
- `cloudformation.options.cfn-files.parameters.template-file` --> Changed to --> `cloudformation.options.cfn-files.parameters.template-param-file`

*new attributes*

- `cloudformation.options.s3bucket`
- `cloudformation.options.s3prefix`
