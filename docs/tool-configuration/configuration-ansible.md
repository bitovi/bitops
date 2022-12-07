> ⚠️ Note from the developers: We are currently in the process of moving our documentation and so the below documentation is only partially correct. For more information on this tool please checkout our [plugin documentation](https://github.com/bitops-plugins/ansible).

# Ansible

### Example `bitops.config.yaml`, minimum required: 
```
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
    tags: run-this-tag
    vault-id: [dev@dev-passwordfile, prod@prod-passwordfile]
    vault-password-file: $TEMPDIR/secrets/password_file
  options:
    dryrun: false
    verbosity: 4
```

## CLI Configuration

| Property            | Environmental Variable             | Description                                                  | Default | Required |
| ------------------- | ---------------------------------- | ------------------------------------------------------------ | ------- | -------- |
| main-playbook       | BITOPS_ANSIBLE_MAIN_SCRIPT         | Specify an entry playbook to run ansible-playbook with. |   `playbook.yaml` | Yes |
| extra-vars          | BITOPS_ANSIBLE_EXTRA_VARS          | Add additional ansible playbook parameters directly or load via JSON/YAML file. |         |          |
| flush-cache         | BITOS_ANSIBLE_FLUSH_CACHE          | Clear the fact cache for every host in the inventory.        |         |          |
| force-handlers      | BITOPS_ANSIBLE_FORCE_HANDLERS      | Clear the fact cache for every host in the inventory.        |         |          |
| forks               | BITOPS_ANSIBLE_FORKS               | Specify the number of parallel processes to use              | 5       |          |
| inventory           | BITOPS_ANSIBLE_INVENTORY           | Specify inventory host path or comma-separated host list.    |         |          |
| skip-tags           | BITOPS_ANSIBLE_SKIP_TAGS           | Only run plays and tasks whose tags do not match these values. |         |          |
| tags                | BITOPS_ANSIBLE_TAGS                | Only run plays and tasks tagged with these values.           |         |          |
| vault-id            | BITOPS_ANSIBLE_VAULT_ID            | This is a list.  Specify Ansible vault-id `[dev@dev-passwordfile]` or multiple `[dev@dev-passwordfile, prod@prod-passwordfile]` or password client script `[dev@my-vault-password-client.py]`. Cannot be used with `@prompt` for equivalent `--ask-vault-pass` functionality |         |          |
| vault-password-file | BITOPS_ANSIBLE_VAULT_PASSWORD_FILE | Specify Ansible vault password file for decryption.          |         |          |

## Options Configuration

| Property  | Environmental Variable | Description                                                  | Default | Required |
| --------- | ---------------------- | ------------------------------------------------------------ | ------- | -------- |
| dryrun    | BITOPS_ANSIBLE_DRYRUN  | Will run `--list-tasks` but won't actually execute playbook(s) |  `false` |          |
| verbosity | ANSIBLE_VERBOSITY      | Acceptable values `0|1|2|3|4`. Equivalent to adding `-verbose` or repeating `-v` flags. Will override a pre-existing `ANSIBLE_VERBOSITY` environmental variable or `[default]` `verbosity=` setting in ansible.cfg. | N/A     |          |

## Additional Environment Variable Configuration
Although not captured in `bitops.config.yaml`, the following environment variables can be set to further customize behavior.

| Environmental Variable | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| EXTRA_ENV              | Before Ansible playbook execution, BitOps will look for an `extra_env` file containing additional environment parameters (`FOO=val1`) in the Ansible plugin directory. If found, the values will be exported to the BitOps environment. |
| ANSIBLE_SKIP_DEPLOY    | Will skip all ansible executions. This supersedes all other configurations. |



