# Bitops

---------------------

![LICENSE](https://img.shields.io/github/license/bitovi/bitops)
![Latest Release](https://img.shields.io/github/v/release/bitovi/bitops)
[![Join our Slack](https://img.shields.io/badge/slack-join%20chat-611f69.svg)](https://www.bitovi.com/community/slack?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Bitops is an opinionated deployment tool that bundles [supported devops tools](#supported-tools) along with a built in understanding of an [operations repository structure](operations-repo-structure.md). The combination of these two things makes it easy to automate the provisionning and configuration of cloud infrastructure from basic VMs to complex kubernetes deployments.

---------------------

## Features

* **[Configurable](configuration-base.md):** Configure how you want bitops to deploy your application with environment variables or yaml
* **[Event Hooks](lifecycle.md):** If bitops doesn't have built-in support for your usecase, execute arbitrary bash scripts at different points in bitops' lifecycle.
* **[Run Anywhere](examples.md):** By bundling all logic in bitops, you can have the same experience regardless of which pipeline service runs your CI. You can even run bitops locally!

## How it works

Bitops is a boiler plate docker image for DevOps work. An operations repository is mounted to a bitops image's `/opt/bitops_deployment` directory. Bitops will

* Auto-detect any configuration belonging to one of its [supported tools](#supported-tools)
* Loop through each tool and
    * Run any pre-execute hooks
    * Read in `yml` configuration
    * Execute the tool
    * Run any post-execute hooks

## Run BitOps
Bitops is packaged as a docker image and is available on [dockerhub](https://hub.docker.com/repository/docker/bitovi/bitops).
```
docker pull bitovi/bitops
cd $YOUR_OPERATIONS_REPO
docker run bitovi/bitops -v $(pwd):/opt/bitops_deployment
```

## Configure Bitops

Bitops is configured in 3 steps:

1. Select your environment
2. Configure aceess to your cloud provider
3. Configure how you want your deployment tools to execute

[Get Started](configuration-base)

## Supported Tools
* [Provision infrastructure with CloudFormation](tool-configuration/configuration-cloudformation.md)
* [Provision infrastructure with Terraform](tool-configuration/configuration-terraform.md)
* [Configure infrastructure with Ansible](tool-configuration/configuration-ansible.md)
* [Deploy to kubernetes with Helm](tool-configuration/configuration-helm.md)

## Supported Cloud Providers

* [Amazon Web Services (AWS)](cloud-configuration/configuration-aws.md)
* Microsoft Azure Cloud (Azure) - [TODO](https://github.com/bitovi/bitops/issues/13)
* Google Cloud Engine (GCE) - [TODO](https://github.com/bitovi/bitops/issues/14)

## Support / Contributing

We welcome any contributions from the community with open arms. Take a look at our [Contributing](contributing/contributing.md) guide.

Come hangout with us on [Slack](https://www.bitovi.com/community/slack)!

## Release History

See [Releases](https://github.com/bitovi/bitops/releases).

## License

[MIT License](license.md).