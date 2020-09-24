# Cloudformation

## Example bitops.config.yml
```
cloudformation:
  cli:
    validate-cfn: true
    cfn-stack-action: deploy
  options:
    cfn-stack-name: bitops-edgelambda-test
    capabilities: CAPABILITY_NAMED_IAM
    cfn-files:
      template-file: template.yaml
      parameters:
        enabled: true
        template-param-file: parameters.json
```

## CLI Configuration

-------------------
### validate-cfn
* **Bitops Property:** `validate-cfn`
* **Environment Variable:** `CFN_TEMPLATE_VALIDATION`
* **default:** `true`
Calls `aws cloudformation validate-template` 
-------------------
### cfn-stack-action
* **Bitops Property:** `cfn-stack-action`
* **Environment Variable:** `CFN_STACK_ACTION`
* **default:** `deploy`
Controls what cloudformation action to apply on the stack
-------------------

## Options Configuration

-------------------
### cfn-stack-action
* **Bitops Property:** `cfn-stack-name`
* **Environment Variable:** `CFN_STACK_NAME`
* **default:** `""`
Cloudformation stack name
-------------------
### cfn-stack-action
* **Bitops Property:** `cfn-stack-name`
* **Environment Variable:** `CFN_STACK_NAME`
* **default:** `""`
Cloudformation stack name
-------------------
### capabilities
* **Bitops Property:** `capabilities`
* **Environment Variable:** `CFN_CAPABILITY`
* **default:** `""`
Cloudformation capabilities
-------------------
### cfn-files
* **Bitops Property:** `cfn-files`
Allows for param files to be used. Has the following child-properties
#### template-file
* **Bitops Property:** `cfn-files.template-file`
Template file to apply the params against
#### parameters
* **Bitops Property:** `cfn-files.parameters`
Additional parameters.
###### enabled
* **Bitops Property:** `cfn-files.parameters.enabled`
* **Environment Variable:** `CFN_PARAMS_FLAG`
* **default:** `true`
###### template-param-file
* **Bitops Property:** `cfn-files.parameters.template-param-file`
* **Environment Variable:** `CFN_TEMPLATE_PARAMS_FILENAME`
* **default:** `""`
-------------------

## Additional Environment Variable Configuration
Although not captured in `bitops.config.yml`, the following environment variables can be set to further customize behaviour
-------------------
### SKIP_DEPLOY_CLOUDFORMATION
Will skill all cloudformation executions. This superseeds all other configuration
