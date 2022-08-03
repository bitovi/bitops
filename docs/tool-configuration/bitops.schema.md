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
## <ins>ops_repo</ins>
## ops_repo.source
#### *Expected Values*
  - "local"
  - A https url to project code (Github)
    - example: https://github.com/PhillypHenning/test-opsrepo.git
#### *Usage*
  ````
  ```
  bitops:
    source: local
  ```
  ````
---

## <ins>fail_fast</ins>
Sets a internal flag which if true will exit the application if an exception occurs. 

#### *Expected Values*
  - [`True or False`]
#### *Usage*
  ````
  ```
  bitops:
    fail_fast: True
  ```
  ````
---

## <ins>logging</ins>
Describes the logging configuration BitOps will use during execution.
## logging.level
What logging level BitOps will run with.

#### *Expected Values*
  - DEBUG
  - INFO
  - WARN
  - ERROR
  - CRITICAL

#### *Usage*
  ````
  ```
  bitops:
    logging:
      level: DEBUG
  ```
  ````
  ---

## **<ins>plugins</ins>**
## plugins.plugin_seq
Describes the sequence of execution that will be performed during the deployment tools execution.

#### *Expected Values*
- Should use the same values as the alias names given to the deployment tools.

#### *Usage*
  ````
  ```
  bitops:
    plugins:
      plugin_seq:
        - deployment_tool1
        - deployment_tool2
      tools:
        deployment:
          deployment_tool1:
            source: foobar
          deployment_tool2:
            source: foobar
  ```
  ````
  ---

## **plugins.tools**
## plugins.tools.cloudproviders
Describes the cloudprovider that will be installed and used to deploy

#### *Usage*
````
  ```
  bitops:
    plugins:
      tools:
        cloudproviders:
          aws:
            source: foobar
  ```
  ````
  ---

## plugins.tools.deployment
Describes the deployment tools that will be installed and used to deploy

#### *Usage*
````
  ```
  bitops:
    plugins:
      plugin_seq:
        - deployment_tool1
        - deployment_tool2
      tools:
        deployment:
          deployment_tool1:
            source: foobar
          deployment_tool2:
            source: foobar
  ```
  ````
