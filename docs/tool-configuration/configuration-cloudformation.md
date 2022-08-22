> ⚠️ Note from the developers: We are currently in the process of moving our documentation and so the below documentation is only partially correct. For more information on this tool please checkout our [plugin documentation](https://github.com/bitops-plugins/cloudformation).

# Cloudformation

## Example bitops.config.yaml
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
* **BitOps Property:** `validate-cfn`
* **Environment Variable:** `CFN_TEMPLATE_VALIDATION`
* **default:** `true`

Calls `aws cloudformation validate-template` 

-------------------
### cfn-stack-action
* **BitOps Property:** `cfn-stack-action`
* **Environment Variable:** `CFN_STACK_ACTION`
* **default:** `deploy`

Controls what cloudformation action to apply on the stack

-------------------

## Options Configuration

-------------------
### cfn-stack-action
* **BitOps Property:** `cfn-stack-name`
* **Environment Variable:** `CFN_STACK_NAME`
* **default:** `""`

Cloudformation stack name

-------------------
### cfn-stack-action
* **BitOps Property:** `cfn-stack-name`
* **Environment Variable:** `CFN_STACK_NAME`
* **default:** `""`

Cloudformation stack name

-------------------
### capabilities
* **BitOps Property:** `capabilities`
* **Environment Variable:** `CFN_CAPABILITY`
* **default:** `""`

Allows you to use CloudFormation nested stacks. Both properties must be set in order to use nested stacks.

-------------------

### cfn-s3-bucket
* **BitOps Property:** `cfn-s3-bucket`
* **Environment Variable:** `CFN_TEMPLATE_S3_BUCKET`
* **default:** `""`

### cfn-s3-prefix
* **BitOps Property:** `cfn-s3-prefix`
* **Environment Variable:** `CFN_S3_PREFIX`
* **default:** `""`

### cfn-merge-parameters
* **BitOps Property:** `cfn-merge-parameters`


Cloudformation capabilities

-------------------
### cfn-files
* **BitOps Property:** `cfn-files`

Allows for param files to be used. Has the following child-properties
#### template-file
* **BitOps Property:** `cfn-files.template-file`

Template file to apply the params against
#### parameters
* **BitOps Property:** `cfn-files.parameters`

Additional parameters.
###### enabled
* **BitOps Property:** `cfn-files.parameters.enabled`
* **Environment Variable:** `CFN_PARAMS_FLAG`
* **default:** `true`
###### template-param-file
* **BitOps Property:** `cfn-files.parameters.template-param-file`
* **Environment Variable:** `CFN_TEMPLATE_PARAMS_FILENAME`
* **default:** `""`

-------------------
### cfn-merge-parameters
* **BitOps Property:** `cfn-merge-parameters`

Allows for param files to be used. Has the following child-properties
#### enabled
* **BitOps Property:** `cfn-files.enabled`
* **Environment Variable:** `CFN_MERGE_PARAMETER`
* **default:** `false`

True if optional option should be used.
#### directory
* **BitOps Property:** `cfn-files.directory`
* **Environment Variable:** `CFN_MERGE_DIRECTORY`
* **default:** `parameters`

The directory within the ansible workspace that contains json files that will be merged.

-------------------

## Additional Environment Variable Configuration
Although not captured in `bitops.config.yaml`, the following environment variables can be set to further customize behaviour

-------------------
### SKIP_DEPLOY_CLOUDFORMATION
Will skill all cloudformation executions. This superseeds all other configuration
