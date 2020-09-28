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
Files that only exist in the `default` environment will be copied over.

`.tf` files from the `default` environment that share its name and path with a file in the active environment will both be in the resulting directory with the active environment name having a suffix added to it.

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
        └── main.tf.test.tf
        └── main.tf # This comes from default/terraform/main.tf
```
This is accomplished with an `rsync` operation
```
DEFAULT_DIR=default
ENV_DIR=test
rsync -ab --suffix ".${ENV_DIR}.tf" --include="*/" --include="*.tf" --exclude="*"  $DEFAULT_DIR/ $ENV_DIR/
```

### .sh Handling
Files that only exist in the `default` environment will be copied over.

`.sh` files from the `default` environment that share its name and path with a file in the active environment will not be copied over.

#### Example
Before default merge
```
└── default
|   └── terraform
|       ├── bitops.after-deploy.d
|       │   └── default-after-script.sh
└── test
    └── terraform
        └── bitops.config.yml
        └── main.tf
```
After default merge
```
└── default
|   └── terraform
|       ├── bitops.after-deploy.d
|       │   └── default-after-script.sh
└── test
    └── terraform
        ├── bitops.after-deploy.d
        │   └── default-after-script.sh # Copied from default/terraform/bitops.after-deploy.d/default-after-script.sh
        └── main.tf
```

### General .yaml/.yml
Files that only exist in the `default` environment will be copied over.

TODO ytt

### values.yaml (Helm)
helm has built in support for merging multiple `values.yaml` files. Bitops will look for files in the following locations and pass them in to helm with with the `-f` in the same order they are found

1. Active environment's `values.yaml`
2. Default environment's `values.yaml`
3. Active environment's `values-versions.yaml`
4. Default environment's `values-versions.yaml`
5. Any yaml in active environment's `$chart/values-files/` directory
6. Any yaml in default environment's `$chart/values-files/` directory

### Example
The following operations repo structure
```
├── default
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
helm install my-first-chart/
helm install \
$HELM_RELEASE_NAME 
my-first-chart/
-f test/helm/my-first-chart/values.yaml \
-f default/helm/my-first-chart/values.yaml \
-f test/helm/my-first-chart/values-versions.yaml \
-f default/helm/my-first-chart/values-versions.yaml \
-f test/helm/my-first-chart/values-files/my-first-chart-values.yaml \
-f default/helm/my-first-chart/values-files/my-first-chart-default-values.yaml \
```