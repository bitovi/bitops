> ⚠️ For more information on this tool please checkout [Ansible plugin repository](https://github.com/bitops-plugins/ansible).

# Ansible

### Example `bitops.config.yaml`, minimum required: 
```yaml
ansible:
    cli: {}
    options: {}
```

## Example complete `bitops.config.yaml`:
```yaml
ansible:
  cli:
    main-playbook: playbook.yaml
    extra-vars: "@extra-vars.json"
    flush-cache: true
    force-handlers: true
    forks: 20
    inventory: beta
    skip-tags: ignore-this-tag
    tags: run-with-this-tag
    dryrun: false
  options:
    verbosity: 0
    skip-deploy: false
```

## CLI configuration
CLI configuration is used to pass in CLI parameters to the ansible-playbook command.

| **Parameter** | **Environment Variable** | **Type** | **Required** | **Default** | **Description** |
|   |  |   |   |   |   |
| `main-playbook`  | `BITOPS_ANSIBLE_MAIN_PLAYBOOK`    | _string_  | _yes_ | `playbook.yaml` | Specify which playbook to run ansible-playbook with |
| `extra-vars`     | `BITOPS_ANSIBLE_EXTRA_VARS`     | _string_  |   |  | Add additional ansible playbook parameters directly or load via JSON/YAML file. |
| `flush-cache`    | `BITOPS_ANSIBLE_FLUSH_CACHE`    | _boolean_ |   |  | Clear the fact cache for every host in inventory. |
| `force-handlers` | `BITOPS_ANSIBLE_FORCE_HANDLERS` | _boolean_ |   |  | Clear the fact cache for every host in inventory. |
| `forks`          | `BITOPS_ANSIBLE_FORKS`          | _integer_ |   |  | Specify number of parallel processes to use. |
| `inventory`      | `BITOPS_ANSIBLE_INVENTORY`      | _string_  |   |  | Specify inventory host path or comma separated host list. |
| `skip-tags`      | `BITOPS_ANSIBLE_SKIP_TAGS`      | _string_  |   |  | Only run plays and tasks whose tags do not match these values. |
| `tags`           | `BITOPS_ANSIBLE_TAGS`           | _string_  |   |  | Only run plays and tasks tagged with these values. |
| `dryrun`         | `BITOPS_ANSIBLE_DRYRUN`         | _boolean_ |   |  | Don't make any changes; instead, try to predict some of the changes that may occur. |


## Options Configuration
Options configurations are used to export variables without using the CLI generation or for any advanced logic that is not supported by the Ansible CLI.

| **Parameter** | **Environment Variable** | **Type** | **Required** | **Default** | **Description** | 
|  |  |   |   |   |   |
| `skip-deploy` | `ANSIBLE_SKIP_DEPLOY`      | _boolean_ |  |  | If set to "true", regardless of the stack-action, deployment actions will be skipped. | 
| `verbosity`   | `BITOPS_ANSIBLE_VERBOSITY` | _integer_ |  |  | Equivalent to adding `-verbose` or repeating `-v` flags. Will override `[default]` `verbosity=` setting in ansible.cfg. Acceptable values `0\|1\|2\|3\|4`. |
