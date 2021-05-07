# About

---------------------
## How BitOps works

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
docker run bitovi/bitops -v $(pwd):/opt/bitops_deployment
```

## Configure BitOps

BitOps is configured in 3 steps:

1. Select your environment
2. Configure aceess to your cloud provider
3. Configure how you want your deployment tools to execute

[Get Started](configuration-base.md)

## Supported Tools
* [Provision infrastructure with CloudFormation](tool-configuration/configuration-cloudformation.md)
* [Provision infrastructure with Terraform](tool-configuration/configuration-terraform.md)
* [Configure infrastructure with Ansible](tool-configuration/configuration-ansible.md)
* [Deploy to kubernetes with Helm](tool-configuration/configuration-helm.md)

## Supported Cloud Providers

* [Amazon Web Services (AWS)](cloud-configuration/configuration-aws.md)
* Microsoft Azure Cloud (Azure) - [TODO](https://github.com/bitovi/bitops/issues/13)
* Google Cloud Engine (GCE) - [TODO](https://github.com/bitovi/bitops/issues/14)

## Guides and Other Reources

Bitops already has several guides demonstrating deploying a webserver or a pre-configured application using different combinations of the available Bitops tools. If you're looking for a quick-start, check out some of the options available in the [Examples](examples.md) section.

## Support / Contributing

We welcome any contributions from the community with open arms. Take a look at our [Contributing](contributing/contributing.md) guide.

Come hangout with us on [Slack](https://www.bitovi.com/community/slack)!

## Release History

See [Releases](https://github.com/bitovi/bitops/releases).

## License

[MIT License](license.md).