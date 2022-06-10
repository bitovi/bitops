[<img src="docs/assets/images/logo/Bitops(RGB)_L2_Full_4C.png" width="250"/>](docs/assets/images/logo/Bitops(RGB)_L2_Full_4C.png)

---------------------

[![LICENSE](https://img.shields.io/badge/license-MIT-green)](LICENSE.md)
[![Latest Release](https://img.shields.io/github/v/release/bitovi/bitops)](https://github.com/bitovi/bitops/releases)
[![Join our Slack](https://img.shields.io/badge/slack-join%20chat-611f69.svg)](https://www.bitovi.com/community/slack?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

BitOps is a way to describe the infrastructure and things deployed onto that infrastructure for multiple environments in a single place called an [Operations Repo](docs/operations-repo-structure.md).

https://bitovi.github.io/bitops/

---------------------

## Features

* **[Configurable](docs/configuration-base.md):** Configure how you want bitops to deploy your application with environment variables or yaml
* **[Event Hooks](docs/lifecycle.md):** If bitops doesn't have built-in support for your usecase, execute arbitrary bash scripts at different points in bitops' lifecycle.
* **[Pipeline Agnostic](docs/examples.md):** By bundling all logic in bitops, you can have the same experience regardless of which pipeline service runs your CI. You can even run bitops locally!

## How it works

BitOps is a boiler plate docker image for DevOps work. An operations repository is mounted to a bitops image's `/opt/bitops_deployment` directory. BitOps will

* Auto-detect any configuration belonging to one of its [supported tools](#supported-tools)
* Loop through each tool and
  * Run any pre-execute hooks
  * Read in `yml` configuration
  * Execute the tool
  * Run any post-execute hooks

## Run BitOps
BitOps is packaged as a docker image and is available on [dockerhub](https://hub.docker.com/r/bitovi/bitops).
```
docker pull bitovi/bitops
cd $YOUR_OPERATIONS_REPO
docker run bitovi/bitops -v .:/opt/bitops_deployment
```

## Configure BitOps

BitOps is configured in 3 steps:

1. Select your environment
2. Configure aceess to your cloud provider
3. Configure how you want your deployment tools to execute

[Docs](docs/configuration-base.md)

## Supported Tools
* [Provision infrastructure with CloudFormation](docs/tool-configuration/configuration-cloudformation.md)
* [Provision infrastructure with Terraform](docs/tool-configuration/configuration-terraform.md)
* [Configure infrastructure with Ansible](docs/tool-configuration/configuration-ansible.md)
* [Deploy to kubernetes with Helm](docs/tool-configuration/configuration-helm.md)

## Supported Cloud Providers

* [Amazon Web Services (AWS)](docs/cloud-configuration/configuration-aws.md)
* Microsoft Azure Cloud (Azure) - TODO - https://github.com/bitovi/bitops/issues/13
* Google Cloud Engine (GCE) - TODO - https://github.com/bitovi/bitops/issues/14

## Support / Contributing

We welcome any contributions from the community with open arms. Take a look at our [Contributing](docs/contributing/contributing.md) guide.

Come hangout with us on [Slack](https://www.bitovi.com/community/slack)!

### Updating Documentation

https://bitovi.github.io/bitops/ is auto-generated using [MKDocs](https://www.mkdocs.org/). Updating markdown in `docs/*` and ensuring the page is defined in `mkdocs.yml` will auto update the site when pushed to the `master` branch.

## Release History

See [Releases](https://github.com/bitovi/bitops/releases).

## License

[MIT License](/license).





<hr/>

[<img src="docs/assets/images/logo/Bitops(RGB)_L2_Full_4C.png" width="250"/>](docs/assets/images/logo/Bitops(RGB)_L2_Full_4C.png)

---------------------

[![LICENSE](https://img.shields.io/badge/license-MIT-green)](LICENSE.md)
[![Latest Release](https://img.shields.io/github/v/release/bitovi/bitops)](https://github.com/bitovi/bitops/releases)
[![Join our Slack](https://img.shields.io/badge/slack-join%20chat-611f69.svg)](https://www.bitovi.com/community/slack?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

BitOps is a way to describe the infrastructure and things deployed onto that infrastructure for multiple environments in a single place called an [Operations Repo](docs/operations-repo-structure.md).

https://bitovi.github.io/bitops/



... CONTENT ...


## Using BitOpsV2

## Features that need to be noted; 
Run modes = install, deploy, setting-test
Variables are set in the following order; ENV_VAR, config_file, default


### Rapid Testing
#### Build the core image
```
docker build -t bitops-core:latest -f Dockerfile-core .
```

#### Build the plugins image
```
docker build -t test-plugins:latest -f Dockerfile-plugins .
```

#### Run Plugins image
```
docker run \
-e ENVIRONMENT=test-simple  \
-v /Users/philh/Documents/Bitovi/test-ops:/opt/bitops_deployment    \
test-plugins:latest 2> dockerplugins-run.logs
```

**What does this do?**

OS/Arch: `linux/386`

Installed tools: 
  - unzip
  - git
  - jq
  - curl
  - wget
  - python3.8.6
  - pip

Source folders copied:
  - bitops.config.yaml
  - requirements.txt
  - scripts/

[Docker OnBuild](https://docs.docker.com/engine/reference/builder/#onbuild) instructions:
  - Changes workdir to `/opt/bitops`
  - Copies files/folders:
    - `scripts/`
    - `bitops.config.yaml`
  - Runs BitOps install




#### Visual
*Docker container*
|-----------------------------|
| /opt/bitops                 |
| /opt/bitops/scripts/plugins |
|                             |
| /opt/bitops_deployment      |
|-----------------------------|

**/opt/bitops**
Contains the BitOps core

**/opt/bitops/scripts/plugins**
Contains the plugins that are installed

**/opt/bitops_deployment**
Contains the Operations Repo


*Docker container layers*
**BitOps Core**
|-------------------------------|
|         BitOps Core           |
| CLI:                          |
|   python3                     |
|   curl                        |
|   jq                          |
|   git                         |
|   unzip                       |
|   wget                        |
|-------------------------------|

**Plugins**
*Docker container layers*
|-------------------------------|
|         BitOps Core           |
|-------------------------------|
|-------------------------------|
|           Plugins             |
| CLI:                          |
|   Plugin CLI tool             |
| Plugin Files:                 |
|   install.sh / install.py     |
|   deploy.sh / deploy.py       |
|   plugin.schema.yaml          |                    
| Bitops Files:                 |
|   bitops.config.yaml          |
|   scripts/                    |
|-------------------------------|



**Runtime**
|-------------------------------|
|         BitOps Core           |
|-------------------------------|
|-------------------------------|
|           Plugins             |
|-------------------------------|
|          Operations           |
| Mounts:                       |
|   operations repo             |
|     /opt/bitops_deployment    |
|   bitops                      |
|     /opt/bitops               |
|-------------------------------|
