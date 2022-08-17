# Versioning
BitOps Docker images are packaged and hosted on [Docker Hub](https://hub.docker.com/r/bitovi/bitops).
Here is how these images are named, versioned and tagged.

* An image with a version tag containing a [semver](https://semver.org) (e.g. `2.0.0`) is immutable and refers to the [stable release](https://github.com/bitovi/bitops/releases).
* A version tag equal to `latest` is always mutable and points to the latest [stable release](https://github.com/bitovi/bitops/releases).
* A version tag containing `dev` is always mutable and refers to the current development state in the [`main`](https://github.com/bitovi/bitops/tree/main) repository branch.
* A version tag containing `omnibus` points to the default image that includes recommended DevOps tools.
* A version tag containing `base` refers to a minimal image with no other tools. You can build a [custom BitOps image](plugins.md) from it.

## Official Images
To clear up any potential confusion regarding the versioning of the [`bitovi/bitops`](https://hub.docker.com/r/bitovi/bitops) image, we use the following table.

| Image Name | PreInstalled Tools| Docker image name | Supported Cloud provider | Additional stable image tags | Development image tags (`main` branch) |
|-|-|-|-|-|-|
| omnibus | Terraform <br/> Cloudformation <br/> Ansible <br/> Helm <br/> Kubectl <br/> AWS CLI| `bitovi/bitops:2.0.0-omnibus` | AWS | `latest` <br/> `2.0.0` | `dev` |
| | | | | | | | 
| aws-terraform | Terraform <br/> AWS CLI | `bitovi/bitops:2.0.0-aws-terraform` | AWS | | |
| aws-ansible   | Ansible <br/> AWS CLI | `bitovi/bitops:2.0.0-aws-ansible` | AWS | | | 
| aws-helm      | Helm <br/> Terraform <br/> AWS CLI | `bitovi/bitops:2.0.0-aws-helm` | AWS | | |
| | | | | | |
| base | BitOps source | `bitovi/bitops:2.0.0-base` | - | `base` | `dev-base` |

## Version Pinning
* We always recommend pinning the stable version of BitOps to avoid any breaking changes like `bitovi/bitops:2.0.0`.
* If the security is higher priority for you, use sha256 digest like `bitovi/bitops:sha256:82becede498899ec668628e7cb0ad87b6e1c371cb8a1e597d83a47fac21d6af3`.

See more in the [docker documentation](https://docs.docker.com/engine/reference/commandline/pull/#pull-an-image-by-digest-immutable-identifier).
