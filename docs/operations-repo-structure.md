# Operations Repo Structure
Bitops expects an operations repo to be in the following structure
```
├── production-serviceA
│   ├── ansible
│   │   ├── bitops.after-deploy.d
│   │   ├── bitops.before-deploy.d
│   │   └── bitops.config.yml
│   ├── helm
│   │   ├── bitops.after-deploy.d
│   │   ├── bitops.before-deploy.d
│   │   └── bitops.config.yml
│   └── terraform
│       ├── bitops.after-deploy.d
│       ├── bitops.before-deploy.d
│       └── bitops.config.yml
└── test-serviceA
    ├── ansible
    │   ├── bitops.after-deploy.d
    │   ├── bitops.before-deploy.d
    │   └── bitops.config.yml
    ├── helm
    │   ├── bitops.after-deploy.d
    │   ├── bitops.before-deploy.d
    │   └── bitops.config.yml
    └── terraform
        ├── bitops.after-deploy.d
        ├── bitops.before-deploy.d
        └── bitops.config.yml
```

#### Environment Directories
These directories live at the root of an operations repository and are used to separate applications and environments. TODO

#### Tool directories
Within an environment directory are directories grouping supported tools by name. Each of these directories is optional. For example, if your application only requires `terraform/` to execute, you do not need an `ansible/` or `helm/` directory in your environment.

This directory is also where you put your infrastructure code for the tool.

#### Lifecycle directories
Within a tool directory, you can optionally have a `bitops.before-deploy.d/` and/or a `bitops.after-deploy.d/`. TODO

#### bitops.config.yml
Each tool is traditionally controlled with a set of cli arguements. Instead of defining these cli arguments within your pipeline configuration, these arguements can instead be defined using environment variables or within a `bitops.config.yml` file. While the core schema for this file is common betwen tools, the specific properties and environment variable equivilants vary from tool to tool. See [Bitops Configuration](/docs/configuration.md) for details.


