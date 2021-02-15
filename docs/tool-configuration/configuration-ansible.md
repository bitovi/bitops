# Ansible

## Example bitops.config.yml
```
ansible:
  cli:
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
```

## CLI Configuration

-------------------
### extra-vars
* **BitOps Property:** `extra-vars`
* **Environment Variable:** `BITOPS_ANSIBLE_EXTRA_VARS`

Add additional ansible playbook parameters directly or load via JSON/YAML file.

-------------------
### flush-cache
* **BitOps Property:** `flush-cache`
* **Environment Variable:** `BITOS_ANSIBLE_FLUSH_CACHE`

Clear the fact cache for every host in inventory.

-------------------
### force-handlers
* **BitOps Property:** `force-handlers`
* **Environment Variable:** `BITOPS_ANSIBLE_FORCE_HANDLERS`

Clear the fact cache for every host in inventory.

-------------------
### forks
* **BitOps Property:** `forks`
* **Environment Variable:** `BITOPS_ANSIBLE_FORKS`

Specify number of parallel processes to use (default=5).

-------------------
### inventory
* **BitOps Property:** `inventory`
* **Environment Variable:** `BITOPS_ANSIBLE_INVENTORY`

Specify inventory host path or comma separated host list.

-------------------
### skip-tags
* **BitOps Property:** `skip-tags`
* **Environment Variable:** `BITOPS_ANSIBLE_SKIP_TAGS`

Only run plays and tasks whose tags do not match these values.

-------------------
### tags
* **BitOps Property:** `tags`
* **Environment Variable:** `BITOPS_ANSIBLE_TAGS`

Only run plays and tasks tagged with these values.

-------------------
### vault-id
* **BitOps Property:** `vault-id`
* **Environment Variable:** `BITOPS_ANSIBLE_VAULT_ID`
* **type:** `list`

Specify Ansible vault-id `[dev@dev-passwordfile]` or multiple `[dev@dev-passwordfile], [prod@prod-passwordfile]` or password client script `[dev@my-vault-password-client.py]`. Cannot be used with `@prompt` for equivalent `--ask-vault-pass` functionality

-------------------
### vault-password-file
* **BitOps Property:** `vault-password-file`
* **Environment Variable:** `BITOPS_ANSIBLE_VAULT_PASSWORD_FILE`

Specify Ansible vault password file for decryption.

## Options Configuration

-------------------
### dryrun
* **BitOps Property:** `dryrun`
* **Environment Variable:** `BITOPS_ANSIBLE_DRYRUN`
* **default:** `false`

Will run `--list-tasks` but won't actually execute playbook(s)

## Additional Environment Variable Configuration
Although not captured in `bitops.config.yml`, the following environment variables can be set to further customize behaviour.

-------------------
### SKIP_DEPLOY_ANSIBLE
Will skill all ansible executions. This superseeds all other configuration.