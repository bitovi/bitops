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
    extra-vars: "@extra-vars.json"
  options:
    dryrun: false
```

## CLI Configuration

-------------------
### extra-vars
* **BitOps Property:** `extra-vars`
* **Environment Variable:** `BITOPS_ANSIBLE_EXTRA_VARS`

add additional ansible playbook parameters directly or load via JSON/YAML file

-------------------
### flush-cache
* **BitOps Property:** `flush-cache`
* **Environment Variable:** `BITOS_ANSIBLE_FLUSH_CACHE`

clear the fact cache for every host in inventory

-------------------
### force-handlers
* **BitOps Property:** `force-handlers`
* **Environment Variable:** `BITOPS_ANSIBLE_FORCE_HANDLERS`

clear the fact cache for every host in inventory

-------------------
### forks
* **BitOps Property:** `forks`
* **Environment Variable:** `BITOPS_ANSIBLE_FORKS`

specify number of parallel processes to use (default=5)

-------------------
### inventory
* **BitOps Property:** `inventory`
* **Environment Variable:** `BITOPS_ANSIBLE_INVENTORY`

specify inventory host path or comma separated host list.

-------------------
### skip-tags
* **BitOps Property:** `skip-tags`
* **Environment Variable:** `BITOPS_ANSIBLE_SKIP_TAGS`

only run plays and tasks whose tags do not match these values

-------------------
### tags
* **BitOps Property:** `tags`
* **Environment Variable:** `BITOPS_ANSIBLE_TAGS`

only run plays and tasks tagged with these values

## Options Configuration

-------------------
### dryrun
* **BitOps Property:** `dryrun`
* **Environment Variable:** `BITOPS_ANSIBLE_DRYRUN`
* **default:** `false`

Will run `--list-tasks` but won't actually execute playbook(s)

## Additional Environment Variable Configuration
Although not captured in `bitops.config.yml`, the following environment variables can be set to further customize behaviour

-------------------
### EXTRA_ENV
Before Ansible playbook execution, BitOps will look for an `extra_env` file containing additional environment parameters (`FOO=val1`) in the Ansible plugin directory. If found, the values will be exported to the BitOps environment.

-------------------
### SKIP_DEPLOY_ANSIBLE
Will skill all ansible executions. This superseeds all other configuration