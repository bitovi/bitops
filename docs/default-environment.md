# Default Environment

There are instances where configuration or variable files should be shared between environments. Instead of duplicating common files across different environments, the `default` environment can be used instead.

Suppose we are working with an operations repo that is exlusviely terraform. We have a `production` and `test` environment that have the same HCL, but different input variables between the two. This is a great candidate for the `default` environment. The common configuration can be put in the `default/` environment directory instead of in both `production/` and `test/` environments:

```
├── default
│   └── terraform
│       └── main.tf
├── production
│   └── terraform
│       └── bitops.config.yml
│       └── production.auto.tfvars
└── test
    └── terraform
        └── bitops.config.yml
        └── test.auto.tfvars
```
When `$ENVIRONMENT` is set to `production`, `default/` will be merged in to `production/` at runtime to produce a directory structure that looks like
```
├── default
│   └── terraform
│       └── main.tf
├── production
│   └── terraform
│       └── bitops.config.yml
│       └── production.auto.tfvars
│       └── main.tf
└── test
    └── terraform
        └── bitops.config.yml
        └── test.auto.tfvars
```

Things get more complex when files exist in both the `default` and `active` environment share the same name. This is why we have file mergers.


## File Mergers [TODO](https://github.com/bitovi/bitops/issues/3)
Different files have different behvaviors based on the file extension + the deployment tool. Some files can be merged together, others can't. This behavior is defined below.

### `.tf` (HCL) Handling
Because of the complexity around merging `.tf` files, Files from the `default` environment that share the names with a file in the active environment will both be in the resulting directory with the active environment name having a suffix added to it.

#### Example
Before default merge
```
├── default
│   └── terraform
│       └── main.tf
└── test
    └── terraform
        └── bitops.config.yml
        └── main.tf
```
After default merge
```
├── default
│   └── terraform
│       └── main.tf
└── test
    └── terraform
        └── bitops.config.yml
        └── main.tf.test
        └── main.tf # This comes from default/terraform/main.tf
```
This is accomplished with an `rsync` operation
```
DEFAULT_DIR=default
ENV_DIR=test
rsync -ab --suffix ".${ENV_DIR}" --include="*/" --include="*.tf" --exclude="*"  $DEFAULT_DIR/ $ENV_DIR/
```

### General .sh

### General .yaml/.yml

### values.yaml (Helm)