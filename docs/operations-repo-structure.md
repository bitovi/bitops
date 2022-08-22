# Operations Repo Structure
BitOps expects an operations repo to be in the following structure, where each environment is in the root of the repository.  Each environment then contains folders for each tool, and each tool has a `bitops.config.yaml`.  There are also directories that can contain _before_ and _after_ scripts for each tool.
```
├── production
│   ├── ansible
│   │   ├── bitops.after-deploy.d
│   │   ├── bitops.before-deploy.d
│   │   └── bitops.config.yaml
│   ├── cloudformation
│   │   ├── bitops.after-deploy.d
│   │   ├── bitops.before-deploy.d
│   │   └── bitops.config.yaml
│   ├── helm
│   │   ├── chartA
│   │   │   └── bitops.config.yaml
│   │   └── chartB
│   │       └── bitops.config.yaml
│   │   └── bitops.config.yaml
│   └── terraform
│       ├── bitops.after-deploy.d
│       ├── bitops.before-deploy.d
│       └── bitops.config.yaml
└── dev
    ├── ansible
    │   ├── bitops.after-deploy.d
    │   ├── bitops.before-deploy.d
    │   └── bitops.config.yaml
    ├── cloudformation
    │   ├── bitops.after-deploy.d
    │   ├── bitops.before-deploy.d
    │   └── bitops.config.yaml
    ├── helm
    │   ├── chartA
    │   │   └── bitops.config.yaml
    │   └── chartB
    │       └── bitops.config.yaml
    │   └── bitops.config.yaml
    └── terraform
        ├── bitops.after-deploy.d
        ├── bitops.before-deploy.d
        └── bitops.config.yaml
```
#### Environment Directories
These directories live at the root of an operations repository and are used to separate applications and environments. Depending on your use case, you may have an environment for `production`, `test` and `dev` or these traditional environments may be further separated into individual services such as `test_service_a` and `test_serice_b`. This pattern is preferential to having a branch for each environment as this allows the state of all your infrastructure to be managed from one location without merging potentially breaking an environment.

When running BitOps, you provide the environment variable `BITOPS_ENVIRONMENT`. This tells BitOps what environment to work in for that run. A full CI/CD pipeline may call BitOps multiple times if it requires one environment to run as a pre-requisite for another.

#### Environment Directory Naming Convention
Sometimes it is useful to have directories in your operations repo that are not deployable environments such as common scripts that can be referenced from any environment's [before or after hooks](lifecycle.md).

BitOps allows you to name your environment directories whatever you want.  However, to better reason about which directories are environments and which aren't a good convention is to prefix any non-deployable-environment directory with an underscore (e.g. `_scripts` or `_terraform`).

The directory `_default` is special in BitOps.  This directory is merged into your environment directory before deployment. You can control the default folder name through an environment variable `BITOPS_DEFAULT_FOLDER` or through a BitOps configuration attribute `bitops.default_folder`.

#### Tool directories
Within an environment directory are tool directories that group supported tools by name. Each of these directories is optional. For example, if your application only requires `terraform/` to execute, you do not need an `ansible/`, `cloudformation/` or `helm/` directory in your environment.

This directory is also where you put your infrastructure code associated with the respective tool.

Helm has additional capabilities here. You can nest multiple charts within the `helm/` directory of a given environment. BitOps will auto-detect and install these charts in alphabetical order.

#### Lifecycle directories
Within a tool directory, you can optionally have a `bitops.before-deploy.d/` and/or a `bitops.after-deploy.d/`. You can put arbitrary `*.sh` scripts in here and they will be run before or after the tool executes. More for information see [lifecycle](lifecycle.md) docs.

If BitOps is reporting it can't find your scripts, make sure the scripts have execute permissions.
```
chmod +x bitops.before-deploy.d/*
chmod +x bitops.after-deploy.d/*
```

#### bitops.config.yaml
Each tool is traditionally controlled with a set of CLI arguments. Instead of defining these CLI arguments within your pipeline configuration, these arguments can instead be defined using environment variables or within a `bitops.config.yaml` file. While the core schema for this file is common between tools, the specific properties and environment variable equivalents vary from tool to tool. See [BitOps Configuration](configuration-base.md) for details.
