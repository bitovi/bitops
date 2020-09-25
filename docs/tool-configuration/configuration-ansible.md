# Ansible

## Example bitops.config.yml
```
ansible:
  cli:
    flush-cache: true
    force-handlers: true
    skip-tags: ignore-this-tag
    forks: 20
    inventory: beta
    tags: run-this-tag
  options:
    dryrun: false
```

## CLI Configuration

-------------------
### flush-cache
* **Bitops Property:** `flush-cache`
* **Environment Variable:** `BITOS_ANSIBLE_FLUSH_CACHE`

clear the fact cache for every host in inventory

-------------------
### force-handlers
* **Bitops Property:** `force-handlers`
* **Environment Variable:** `BITOPS_ANSIBLE_FORCE_HANDLERS`

clear the fact cache for every host in inventory

-------------------
### skip-tags
* **Bitops Property:** `skip-tags`
* **Environment Variable:** `BITOPS_ANSIBLE_SKIP_TAGS`

only run plays and tasks whose tags do not match these values

-------------------
### forks
* **Bitops Property:** `forks`
* **Environment Variable:** `BITOPS_ANSIBLE_FORKS`

specify number of parallel processes to use (default=5)

-------------------
### inventory
* **Bitops Property:** `inventory`
* **Environment Variable:** `BITOPS_ANSIBLE_INVENTORY`

specify inventory host path or comma separated host list.

-------------------
### tags
* **Bitops Property:** `tags`
* **Environment Variable:** `BITOPS_ANSIBLE_TAGS`

only run plays and tasks tagged with these values

## Options Configuration

-------------------
### dryrun
* **Bitops Property:** `dryrun`
* **Environment Variable:** `BITOPS_ANSIBLE_DRYRUN`
* **default:** `false`

Will run `--list-tasks` but won't actually execute playbook(s)

## Additional Environment Variable Configuration
Although not captured in `bitops.config.yml`, the following environment variables can be set to further customize behaviour

-------------------
### SKIP_DEPLOY_ANSIBLE
Will skill all ansible executions. This superseeds all other configuration