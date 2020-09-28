# Operations Repo Structure
Bitops expects an operations repo to be in the following structure
```
├── production-serviceA
│   ├── ansible
│   │   ├── bitops.after-deploy.d
│   │   ├── bitops.before-deploy.d
│   │   └── bitops.config.yml
│   ├── cloudformation
│   │   ├── bitops.after-deploy.d
│   │   ├── bitops.before-deploy.d
│   │   └── bitops.config.yml
│   ├── helm
│   │   ├── chartA
│   │   │   └── bitops.config.yml
│   │   └── chartB
│   │       └── bitops.config.yml
│   │   └── bitops.config.yml
│   └── terraform
│       ├── bitops.after-deploy.d
│       ├── bitops.before-deploy.d
│       └── bitops.config.yml
└── test-serviceA
    ├── ansible
    │   ├── bitops.after-deploy.d
    │   ├── bitops.before-deploy.d
    │   └── bitops.config.yml
    │   ├── cloudformation
    │   ├── bitops.after-deploy.d
    │   ├── bitops.before-deploy.d
    │   └── bitops.config.yml
    ├── helm
    │   ├── chartA
    │   │   └── bitops.config.yml
    │   └── chartB
    │       └── bitops.config.yml
    │   └── bitops.config.yml
    └── terraform
        ├── bitops.after-deploy.d
        ├── bitops.before-deploy.d
        └── bitops.config.yml
```
#### Environment Directories
These directories live at the root of an operations repository and are used to separate applications and environments. Depending on your usecase, you may have an environment for `production`, `test` and `dev` or these traditional environments may be further separated into individual services. This pattern is preferential to having a branch for each environment as this allows the state of all your infrastructure to be managed from one location without merging potentially breaking an environment.

When running bitops, you provide the environment variable `ENVIRONMENT`. This tells bitops what environment to work in for that run. A full CI/CD pipeline may call bitops multiple times if it requires one environment to run as a pre-requisite for another.

#### Tool directories
Within an environment directory are directories grouping supported tools by name. Each of these directories is optional. For example, if your application only requires `terraform/` to execute, you do not need an `ansible/`, `cloudformation/` or `helm/` directory in your environment.

This directory is also where you put your infrastructure code associated with the respective tool.

Helm has additional capabilities here. You can nest multiple charts within the `helm/` directory of a given environment. Bitops will auto-detect and install these charts in alphabetical order.

#### Lifecycle directories
Within a tool directory, you can optionally have a `bitops.before-deploy.d/` and/or a `bitops.after-deploy.d/`. You can put arbitrary `*.sh` scripts in here and they will be run before or after the tool executes. More for information see [lifecycle](lifecycle.md) docs.

If bitops is reporting it can't find your scripts, make sure the scripts have execute permissions.
```
chmod +x bitops.before-deploy.d/*
chmod +x bitops.after-deploy.d/*
```

#### bitops.config.yml
Each tool is traditionally controlled with a set of cli arguements. Instead of defining these cli arguments within your pipeline configuration, these arguements can instead be defined using environment variables or within a `bitops.config.yml` file. While the core schema for this file is common betwen tools, the specific properties and environment variable equivilants vary from tool to tool. See [Bitops Configuration](configuration-base.md) for details.


