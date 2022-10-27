> ⚠️ Note from the developers: We are currently in the process of moving our documentation and so the below documentation is only partially correct. For more information on this tool please checkout our [plugin documentation](https://github.com/bitops-plugins/cloudformation).

# Cloudformation

## Example bitops.config.yaml
```yaml
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

| Property         | Environmental Variable | Description                                               | Default  | Required |
| ---------------- | ---------------------- | --------------------------------------------------------- | -------- | -------- |
| validate-cfn     | FN_TEMPLATE_VALIDATION | Calls `aws cloudformation validate-template`              | `true`   |          |
| cfn-stack-action | CFN_STACK_ACTION       | Controls what CloudFormation action to apply on the stack | `deploy` |          |

## Options Configuration

| Property             | Environmental Variable | Description                                                  | Default | Required |
| -------------------- | ---------------------- | ------------------------------------------------------------ | ------- | -------- |
| cfn-stack-name       | CFN_STACK_NAME         | Cloudformation stack name                                    | `null`  |          |
| capabilities         | CFN_CAPABILITY         | Allows you to use CloudFormation nested stacks. Both properties must be set in order to use nested stacks. | `null`  |          |
| cfn-s3-bucket        | CFN_TEMPLATE_S3_BUCKET |                                                              | `null`  |          |
| cfn-s3-prefix        | CFN_S3_PREFIX          |                                                              | `null`  |          |
| cfn-merge-parameters |                        | Cloudformation capabilities                                  |         |          |

-------------------
## cfn-files
* **BitOps Property:** `cfn-files`

Allows for param files to be used. Has the following child-properties
| Property                                 | Environmental Variable       | Description                                                  | Default      | Required |
| ---------------------------------------- | ---------------------------- | ------------------------------------------------------------ | ------------ | -------- |
| cfn-files.template-file                  |                              | Template file to apply the params against                    |              |          |
| cfn-files.parameters                     |                              | Additional parameters.                                       |              |          |
| cfn-files.parameters.enabled             | CFN_PARAMS_FLAG              |                                                              | `true`       |          |
| cfn-files.parameters.template-param-file | CFN_TEMPLATE_PARAMS_FILENAME |                                                              | `null`       |          |
| cfn-merge-parameters                     |                              | Allows for param files to be used. Has the following child-properties |              |          |
| cfn-files.enabled                        | CFN_MERGE_PARAMETER          | True if optional option should be used.                      | `false`      |          |
| cfn-files.directory                      | CFN_MERGE_DIRECTORY          | The directory within the ansible workspace that contains json files that will be merged. | `parameters` |          |

-------------------

## Additional Environment Variable Configuration
Although not captured in `bitops.config.yaml`, the following environment variables can be set to further customize the behaviour

-------------------
### SKIP_DEPLOY_CLOUDFORMATION
Will skill all CloudFormation executions. This supersedes all other configuration
