# Getting Started
To get started, you’ll need
- Docker locally
- The BitOps repo on your local machine
- An Operations Repository on your local machine
- [optional] A BitOps plugin on your local machine

## General Idea

To test and work on BitOps locally, a common approach is to pull the latest (or most recent versioned) BitOps image and then mount your local repos to the relevant locations when you run the BitOps container.

Additionally, you might want to make use of the “dry-run” functionality (dry-run: true for Helm, plan for Terraform, for example) for your deployments so that you are not modifying external resources during your testing.

It’s also useful to modify the BitOps or Plugin code to output extra debugging information or to bypass the actual deployment once you’ve pinpointed where the issue might be.

Be sure to **remove all debugging code/modifications** prior to merging!



## Create your branches

Check out each of your repos (BitOps, your Operations Repo, and your BitOps Plugin repo).

For each repo, create a branch locally to capture your changes.

## Pull latest BitOps

In this example, we’ll pull BitOps version 2.1.0 since, at the time of this writing, 2.1.0 is the most recent version, so that’s where we want to start.

```
docker pull bitovi/bitops:2.1.0
```

## Craft your deploy script

Build a Docker run command to mount all the repos and kick off a BitOps deployment locally:

```
docker run --rm --name bitops \
-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
-e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
-e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" \
-e BITOPS_ENVIRONMENT="prod" \
-e BITOPS_ENVIRONMENT_HELM_SUBDIRECTORY="aws-auth" \
-e TERRAFORM_SKIP_DEPLOY="true" \
-e HELM_SKIP_DEPLOY="" \
-e DEFAULT_FOLDER_NAME="_default" \
-v /path/to/operations-repo:/opt/bitops_deployment \
-v /path/to/bitops:/opt/bitops \
-v /path/to/bitops/prebuilt-config/omnibus/bitops.config.yaml:/opt/bitops/bitops.config.yaml \
-v /opt/bitops/scripts/plugins/aws \
-v /opt/bitops/scripts/plugins/terraform \
-v /opt/bitops/scripts/plugins/cloudformation \
-v /opt/bitops/scripts/plugins/kubectl \
-v /opt/bitops/scripts/plugins/ansible \
-v /path/to/bitops-plugins/helm:/opt/bitops/scripts/plugins/helm \
bitovi/bitops:2.1.0
```

### Breaking down the deploy script
| Command | Description |
| --------- | --- |
| `docker run --rm --name bitops \` | Run the docker container, name it bitops, and remove the container when it exits|
| -e AWS_ACCESS_KEY_ID="\${AWS_ACCESS_KEY_ID}" \ <br/> -e AWS_SECRET_ACCESS_KEY="\${AWS_SECRET_ACCESS_KEY}" \ <br/> -e AWS_SESSION_TOKEN="\${AWS_SESSION_TOKEN}" \ | AWS credentials/config|
| `-e BITOPS_ENVIRONMENT="prod" \` | Set the BitOps environment to deploy (in this example, prod) |
| `-e BITOPS_ENVIRONMENT_HELM_SUBDIRECTORY="aws-auth" \` | Set the specific Helm chart to deploy (in this example, aws-auth). | This is quite useful for iterating quickly if you’ve got an ops repo environment with many Helm charts but only want to focus on a single one. | 
| -e TERRAFORM_SKIP_DEPLOY="true" \ <br/> -e HELM_SKIP_DEPLOY="" \ | Skip the Terraform deployment but not the Helm deployment (you could also omit HELM_SKIP_DEPLOY). | This is useful if you want to deploy only a single tool in the environment. | 
| `-e DEFAULT_FOLDER_NAME="_default" \` | Define the directory to pull defaults from.  Default should be _default, so this could be omitted if your default environment is _default. |
| -v /path/to/operations-repo:/opt/bitops_deployment \ | Mount your local operations repo to the location BitOps expects it to be. |
| -v /path/to/bitops:/opt/bitops \ | Mount your local BitOps repo to the location BitOps expects it to be (i.e. /opt/bitops).  This way, you can make changes to the BitOps code locally, and changes will be reflected when you run the docker run command. |
| `-v /path/to/bitops/prebuilt-config/omnibus/bitops.config.yaml:/opt/bitops/bitops.config.yaml \` | Specify a specific bitops.config.yaml from the prebuilt-config so that BitOps knows how to handle deployments. BitOps looks for a bitops.config.yaml in the root directory to determine how (i.e. in which order) to execute deployments.  The bitops.config.yaml in the root directory has empty deployments, so we need content there.  This line mounts one of the prebuilt-config’s bitops.config.yaml (namely, the omnibus bitops.config.yaml) to the root of the repo. |
| -v /opt/bitops/scripts/plugins/aws \ <br/> -v /opt/bitops/scripts/plugins/terraform \ <br/> -v /opt/bitops/scripts/plugins/cloudformation \ <br/> -v /opt/bitops/scripts/plugins/kubectl \ <br/> -v /opt/bitops/scripts/plugins/ansible \ | These lines essentially tell Docker to use the specified directories from within the container rather than from the host.  Since we are mounting the entire BitOps directory to a container that should have plugins but we’re not running a build to perform a plugin install, we need to use the plugins that were installed into the container as they do not exist on the host. |
| `-v /path/to/bitops-plugins/helm:/opt/bitops/scripts/plugins/helm \` | This mounts your local plugin repo (in this example, helm) to the appropriate location within the container. |
| `bitovi/bitops:2.1.0` | Use a specific BitOps version as the basis for your work.  You’ll want to ensure you’re working against the most recent release (either the most recent versioned image or latest) |


## Linting
Before submitting a PR it is recommended that you locally run a linter to ensure code standards are met. 

```
tox -e black
tox -e pylint
```

## Python Debugging with VSCode
If you are using VSCode, you can rely on the Python and Docker extensions to [debug your code](https://code.visualstudio.com/docs/containers/debug-python).

This VSCode config (in `.vscode/`) allows running the Python debugging in a BitOps container, sharing the directories with the local python source code and plugin code.

### Instructions

* The BitOps repository contains two configuration files in the `.vscode/` directory: `launch.json` and `tasks.json`. These files are used by VSCode to configure the debugging environment.
* The new Launch button `Docker: bitops deploy` should be now available under the `Run & Debug` (left panel) of VSCode
* Set the breakpoints in the code
* Run it

<video width=800  src="https://user-images.githubusercontent.com/1533818/229613747-2ab62348-06d7-4e78-8731-2e931a79b387.mp4" controls preload></video>
