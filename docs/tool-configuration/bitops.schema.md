# Summary
## Schema
```
bitops:
  ops_repo:
    source: <value>
  fail_fast: <value>
  logging:
    level: <value>
  plugins:
    plugin_seq:
      - <value>
      - <value>
    tools:
      cloudprovider:
        <cloudprovider>:
          source: <value>
      tools:
        <tool>:
          source: <value>
          source_tag: <value>
          source_branch: <value>
          install_script: <value>
          deploy_script: <value>
```

# <ins>Configuration explanation</ins>
---


| Property                            | Values allowed                                               | Description                                                  | Default | Required |
| ----------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------- | -------- |
| bitops.ops_repo.source              | `local` or URL to Project code example: https://github.com/PhillypHenning/test-opsrepo.git | Location of the Operations Repository                        |         |          |
| bitops.failfast                     | `True` or `False`                                            | Sets an internal flag which if true will exit the application if an exception occurs. |         |          |
| bitops.logging.level                | `DEBUG`, `INFO`, `WARN`, `ERROR`,  `CRITICAL`                | The logging level                                            |         |          |
| bitops.plugins.plugin_seq           | List of values using the same alias names given to the deployment tools. | The sequence of execution for the plugins                    |         |          |
| bitops.plugins.tools.cloudproviders |                                                              | Describes the cloud provider that will be installed and used to deploy |         |          |
| bitops.plugins.tools.deployment     |                                                              | Describes the deployment tools that will be installed and used to deploy |         |          |

