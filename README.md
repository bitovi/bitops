[<img src="docs/assets/images/logo/Bitops(RGB)_L2_Full_4C.png" width="250"/>](docs/assets/images/logo/Bitops(RGB)_L2_Full_4C.png)

---------------------

[![LICENSE](https://img.shields.io/badge/license-MIT-green)](LICENSE.md)
[![Latest Release](https://img.shields.io/github/v/release/bitovi/bitops)](https://github.com/bitovi/bitops/releases)
[![Join our Slack](https://img.shields.io/badge/slack-join%20chat-611f69.svg)](https://www.bitovi.com/community/slack?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

### tl;dr
BitOps is two things; 
- A automated tool [orchestrator](docs/about.md)
- A way to describe [infrastructure](docs/operations-repo-structure.md) for many environments and IaC tools

---------------------

## Features

* **[Configurable](docs/configuration-base.md):** Configure how you want BitOps to deploy your application with yaml or environment variables.
* **[Event Hooks](docs/lifecycle.md):** If BitOps doesn't have built-in support for your usecase, execute arbitrary bash scripts at different points using BitOps' lifecycle.
* **[Pipeline Agnostic](docs/examples.md):** By bundling all logic in bitops, you can have the same experience regardless of which pipeline service runs your deployment pipeline. You can even run BitOps locally!
* **[Customizable](docs/plugins.md):** Configure how what tools you want installed in your BitOps image. Only take what you need, leave the bloat behind. 

## How it works

BitOps is a tool orchestrator packaged in a docker image for DevOps work. An operations repository is mounted to a BitOps image's `/opt/bitops_deployment` directory. BitOps will parse through the operations repo and;

* Auto-detect BitOps configuration files within tool directories
* Loop through each tool and
  * Read in `yaml` configuration
  * Run any pre-execute hooks
  * Execute the tool
  * Run any post-execute hooks

## Quick Start
BitOps is packaged as a docker image and is available on [dockerhub](https://hub.docker.com/r/bitovi/bitops).
```
docker pull bitovi/bitops:latest
cd $YOUR_OPERATIONS_REPO
docker run bitovi/bitops:latest -v .:/opt/bitops_deployment
```

Need an example? We got you! Check out our [Example Operation Repos](https://github.com/bitovi/operations-test)

## Configure BitOps
BitOps is configured in 3 steps:

1. Define [configuration](https://bitovi.github.io/bitops/configuration-base/) for your environments
2. Configure access to your cloud provider
3. Configure how you want your deployment tools to execute

Ready to dive deeper? Check out our [Docs](docs/configuration-base.md)

Still not enough? Why not try building and running a [local version of BitOps](docs/development-local.md)

Need a hand with implementation? We can [help](https://www.bitovi.com/devops-consulting)

## Supported Plugins
* Provision infrastructure with [CloudFormation](https://github.com/bitops-plugins/cloudformation/blob/main/README.md)
* Provision infrastructure with [Terraform](https://github.com/bitops-plugins/terraform/blob/main/README.md)
* Configure infrastructure with [Ansible](https://github.com/bitops-plugins/ansible/blob/main/README.md)
* Deploy to kubernetes with [Helm](https://github.com/bitops-plugins/helm/blob/main/README.md)

## Supported Cloud Providers
* [Amazon Web Services (AWS)](https://github.com/bitops-plugins/aws/blob/main/README.md)
* Microsoft Azure Cloud (Azure) - COMING SOON - https://github.com/bitovi/bitops/issues/13
* Google Cloud Engine (GCE) - COMING SOON - https://github.com/bitovi/bitops/issues/14

## Support / Contributing

We welcome any contributions from the community with open arms. Take a look at our [Contributing](docs/contributing/contributing.md) guide.

Come hangout with us on [Slack](https://www.bitovi.com/community/slack)!

### Updating Documentation

https://bitovi.github.io/bitops/ is auto-generated using [MKDocs](https://www.mkdocs.org/). Updating markdown in `docs/*` and ensuring the page is defined in `mkdocs.yml` will auto update the site when pushed to the `master` branch.

## Release History

See [Releases](https://github.com/bitovi/bitops/releases).

## License

[MIT License](/license).
