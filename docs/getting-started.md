# Getting Started

---------------------
## What is BitOps?

There are 2 components to BitOps.  First, we have an [Operations Repository](operations-repo-structure.md) (OpsRepo) where we store the code for our various tools. The second part is the BitOps Docker container that you can run to automate the deployment of the code in our OpsRepo.  Now with a single command, you can deploy infrastructure and software.

The second part of BitOps is a boilerplate docker image for DevOps work. When you mount an Operations Repository to a BitOps image's `/opt/bitops_deployment` directory, BitOps will:

* Auto-detect any configuration belonging to one of its [supported tools](#supported-tools)
* Loop through each tool and
    * Run any pre-execute hooks
    * Read in `yaml` configuration
    * Execute the tool
    * Run any post-execute hooks

## Configure BitOps

BitOps is configured in 4 steps:

1. Create an Operations Repository
2. Select your environment
3. Configure access to your cloud provider
4. Configure how you want your deployment tools to execute

[Get Started](configuration-base.md)

## Run BitOps

BitOps is packaged as a docker image and is available on [dockerhub](https://hub.docker.com/r/bitovi/bitops).

```
docker pull bitovi/bitops
cd $YOUR_OPERATIONS_REPO
docker run bitovi/bitops -v $(pwd):/opt/bitops_deployment
```



## Supported Tools
* [Provision infrastructure with CloudFormation](tool-configuration/configuration-cloudformation.md)
* [Provision infrastructure with Terraform](tool-configuration/configuration-terraform.md)
* [Configure infrastructure with Ansible](tool-configuration/configuration-ansible.md)
* [Deploy to kubernetes with Helm](tool-configuration/configuration-helm.md)

## Supported Cloud Providers

* [Amazon Web Services (AWS)](cloud-configuration/configuration-aws.md)
* Microsoft Azure Cloud (Azure) - [Coming soon!](https://github.com/bitovi/bitops/issues/13)
* Google Cloud Engine (GCE) - [Coming Soon!](https://github.com/bitovi/bitops/issues/14)

## Guides and Other Resources

BitOps already has several guides demonstrating deploying a web server or a pre-configured application using different combinations of the available BitOps tools. If you're looking for a quick start, check out some of the options available in the [Examples](examples.md) section.

