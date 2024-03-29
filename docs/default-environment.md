# Default Environment

There are instances where configuration or variable files should be shared between environments. Instead of duplicating common files across different environments, the `_default` environment can be used instead.

Suppose we are working with an operations repo that is exlusviely terraform. We have a `production` and `test` environment that have the same HCL, but different input variables between the two. This is a great candidate for the `_default` environment. The common configuration can be put in the `_default/` environment directory instead of in both `production/` and `test/` environments:

```
├── _default
│   └── terraform
│       └── main.tf
├── production
│   └── terraform
│       └── bitops.config.yaml
│       └── production.auto.tfvars
└── test
    └── terraform
        └── bitops.config.yaml
        └── test.auto.tfvars
```
When `$BITOPS_ENVIRONMENT` is set to `production`, `_default/` will be merged into `production/` at runtime to produce a directory structure that looks this way:
```
├── _default
│   └── terraform
│       └── main.tf
├── production
│   └── terraform
│       └── bitops.config.yaml
│       └── production.auto.tfvars
│       └── main.tf
└── test
    └── terraform
        └── bitops.config.yaml
        └── test.auto.tfvars
```

Things get more complex when files that exist in both the `_default` and `active` environment share the same name. This is why we have file mergers.


## File Mergers [TODO](https://github.com/bitovi/bitops/issues/3)
Different files have different behvaviors based on the file extension + the deployment tool. Some files can be merged together, others can't. This behavior is defined below.

### `.tf` (HCL) Handling
Files that only exist in the `_default` environment will be copied over.

`.tf` files from the `_default` environment that share its name and path with a file in the active environment will both be in the resulting directory with the active environment name having a suffix added to it.

#### Example
Before default merge:
```
├── _default
│   └── terraform
│       └── main.tf
└── test
    └── terraform
        └── bitops.config.yaml
        └── main.tf
```
After default merge:
```
├── _default
│   └── terraform
│       └── main.tf
└── test
    └── terraform
        └── bitops.config.yaml
        └── main.tf.test.tf
        └── main.tf # This comes from default/terraform/main.tf
```
This is accomplished with an `rsync` operation
```
DEFAULT_DIR=_default
ENV_DIR=test
rsync -ab --suffix ".${ENV_DIR}.tf" --include="*/" --include="*.tf" --exclude="*"  $DEFAULT_DIR/ $ENV_DIR/
```

### .sh Handling
Files that only exist in the `_default` environment will be copied over.

`.sh` files from the `_default` environment that share its name and path with a file in the active environment will not be copied over.

#### Example
Before default merge
```
├── _default
│   └── terraform
│       ├── bitops.after-deploy.d
│       │   └── default-after-script.sh
└── test
    └── terraform
        └── bitops.config.yaml
        └── main.tf
```
After default merge
```
├── _default
│   └── terraform
│       ├── bitops.after-deploy.d
│       │   └── default-after-script.sh
└── test
    └── terraform
        ├── bitops.after-deploy.d
        │   └── default-after-script.sh # Copied from default/terraform/bitops.after-deploy.d/default-after-script.sh
        └── main.tf
```

### General .yaml/.yml
Files that only exist in the `_default` environment will be copied over.

Files from the `_default` environment that share its name and path will be merged.

### values.yaml (Helm)
Helm has built in support for merging multiple `values.yaml` files. BitOps will look for files in the following locations and pass them in to helm with the `-f` in the same order they are found:

1. Active environment's `values.yaml`
2. Default environment's `values.yaml`
3. Active environment's `values-versions.yaml`
4. Default environment's `values-versions.yaml`
5. Any yaml in active environment's `$chart/values-files/` directory
6. Any yaml in default environment's `$chart/values-files/` directory

#### Example
The following operations repo structure
```
├── _default
│   └── helm
│       └── my-first-chart
│           ├── values-files
│           │   └── my-first-chart-default-values.yaml
│           ├── values-versions.yaml
│           └── values.yaml
└── test
    └── helm
        ├── bitops.config.yaml
        └── my-first-chart
            ├── values-files
            │   └── my-first-chart-values.yaml
            ├── values-versions.yaml
            └── values.yaml
```
Will produce the following `helm install` command
```
helm install \
$HELM_RELEASE_NAME \ 
my-first-chart \
-f test/helm/my-first-chart/values.yaml \
-f default/helm/my-first-chart/values.yaml \
-f test/helm/my-first-chart/values-versions.yaml \
-f default/helm/my-first-chart/values-versions.yaml \
-f test/helm/my-first-chart/values-files/my-first-chart-values.yaml \
-f default/helm/my-first-chart/values-files/my-first-chart-default-values.yaml
```
