# Plugin creation guide

So you wanna build a BitOps plugin, eh?  Follow along for how to do it locally!

## 1. Create a plugin repo

```sh
cd /path/to/bitops-plugins
mkdir sample-plugin && cd sample-plugin
```

More information on what goes in a plugin [here](../plugins.md).

> Note: If the plugin needs to install tools, you will need to build and run a local version of BitOps.  The first portion of this guide assumes the install.sh script **DOES NOT** needs to be run.  For more information about how to set up BitOps for local development with a plugin that requires an installation, skip to step 5 below.


For this example, we'll keep to a really simple plugin.

To start with, create a file called `bitops.schema.yaml` and add the following content.

```yaml
# /path/to/bitops-plugins/bitops.schema.yaml

sample-plugin:
  options:
    type: object
    properties:
      foo:
        type: string
        export_env: SAMPLE_PLUGIN_FOO
        required: true
        default: foo_value
```

Next, create a simple `deploy.sh` script.  This script does some checks and shows how to use some of the system `BITOPS_` available environment variables then outputs configuration values defined by the `bitops.schema.yaml` in `cli` and `options` sections.

```sh
# /path/to/bitops-plugins/deploy.sh

#!/bin/bash
set -e

echo "Running Sample Plugin deployment script..."

# vars
export BITOPS_SCHEMA_ENV_FILE="$BITOPS_OPSREPO_ENVIRONMENT_DIR/ENV_FILE"

if [ ! -d "$BITOPS_OPSREPO_ENVIRONMENT_DIR" ]; then
  echo "No sample-plugin directory. Skipping."
  exit 0
fi

echo "Deploying sample-plugin..."

if [ ! -f "$BITOPS_SCHEMA_ENV_FILE" ]; then 
  echo "No sample-plugin ENV file found"
else
  source "$BITOPS_SCHEMA_ENV_FILE"
fi

cd $BITOPS_OPSREPO_ENVIRONMENT_DIR

echo "Listing contents of sample-plugin Root: $BITOPS_OPSREPO_ENVIRONMENT_DIR"
ls -al .

echo "Running the plugin CLI: (SKIPPED)"

echo "Options:"
echo "SAMPLE_PLUGIN_FOO: $SAMPLE_PLUGIN_FOO"
# Expected result: "foo_value"
```

> **Note:** Much of the above is best practice boilerplate and is not strictly necessary.

Finally, create a `plugin.config.yaml` to configure how BitOps uses the plugin:

```yaml
# /path/to/bitops-plugins/plugin.config.yaml

plugin:
  deployment:
    language: bash
    deployment_script: deploy.sh
```

## 2. Create an ops repo for testing

Now we'll create an `ops-repo` and `environment` with a directory that matches your tool:

- In this example, we have an `sample-ops-repo` dir as the root. 
- `test-env` is our new environment that we want to test the plugin on.
- Finally we have a directory for the `sample-plugin` plugin itself:

```sh
mkdir -p /path/to/sample-ops-repo/test-env/sample-plugin
cd /path/to/sample-ops-repo/test-env/sample-plugin
```

Populate the tool's `bitops.config.yaml` based on the schema defined above:

```yaml
# /path/to/sample-ops-repo/test-env/sample-plugin/bitops.config.yaml

sample-plugin:
  options:
    foo: baz
```

## 3. Test your plugin

### 3.1. BitOps-level BitOps Config
To test your plugin, you'll need BitOps to run with a `bitops.config.yaml` that has your plugin defined in the `deployments`.

Create a `bitops.config.yaml` at the `test-env` level in your `sample-ops-repo`, and add a `plugins` and `deployments` reference to your plugin:

  - Note the `file:///opt/...` path in the example. This is the path that will result when the plugin is installed into the BitOps Docker container running it - NOT the path on your local machine.

```yaml
# /path/to/sample-ops-repo/test-env/sample-plugin/bitops.config.yaml

bitops:
  plugins:    
    sample-plugin: file:///opt/bitops/scripts/installed_plugins/sample-plugin
  deployments:
    sample-plugin:
      plugin: sample-plugin
```

### 3.2. Run your test
To run BitOps against a local plugin, you'll need to mount the plugin to the location BitOps expects plugins to be:

1. Create a `_scripts` folder at the root level of your `ops-repo` dir.
2. Create a `deploy.local.sh` file to script the upcoming `docker run` command.
3. Make sure to `chmod +x` the deploy script.

    ```sh
    # in /path/to/sample-ops-repo
    mkdir _scripts && cd _scripts
    touch deploy.local.sh
    chmod +x deploy.local.sh
    ```

1. Create a `.gitignore` to keep the deploy file out of the upstream repo:

    ```sh
    # in /path/to/sample-ops-repo
    echo _scripts/deploy.local.sh >> .gitignore
    ```

    <!--
    > **Note:** To see the full code so far, see [docs/examples/plugin-examples/plugin-no-install/duplicate-environment](../docs/examples/plugin-examples/plugin-no-install/duplicate-environment)
    -->

1. Copy this content into `deploy.local.sh`:

    ```sh
    #!/bin/bash

    docker run --rm --name bitops \
    -e BITOPS_ENVIRONMENT="test-env" \
    -v /path/to/sample-ops-repo:/opt/bitops_deployment \
    -v /path/to/bitops-plugins/sample-plugin:/opt/bitops/scripts/installed_plugins/sample-plugin \
    bitovi/bitops:latest
    ```

    > Note the docker-context name of the plugin dir `/path/to/bitops-plugins/sample-plugin:/opt/bitops/scripts/installed_plugins/***sample-plugin***` must exactly match the name in `/path/to/bitops-plugins/bitops.schema.yaml`:
    >
    > ```yaml
    > sample-plugin:
    > ```

1. Run it!

    ```sh
     # in /path/to/sample-ops-repo/_scripts
     ./deploy.local.sh
    ```

    If things go well, the output should look like this:

    ```sh
    > ./deploy.local.sh
    2023-05-15 18:37:12,675 bitops-logger WARNING 
        Optional file was not found. Consider adding the following file:
     [/opt/bitops/scripts/installed_plugins/azure/plugin.config.yaml]
    Running Azure Plugin deployment script...
    Deploying azure plugin...
    No azure plugin ENV file found
    Listing contents of azure plugin Root: /tmp/tmpj5lv41jw/test-env/azure
    total 12
    drwxr-xr-x    2 root     root          4096 May 15 16:19 .
    drwxr-xr-x    3 root     root          4096 May 15 18:11 ..
    -rw-r--r--    1 root     root            31 May 15 18:36 bitops.config.yaml
    Running the plugin CLI: (SKIPPED)
    Options:
    AZURE_FOO: foo_value
    BitOps has finished!
    ```

## 4. Handling the Plugin Install Script

If your new plugin needs to run some install scripts (e.g. to install a CLI tool), you'll need to build your own version of BitOps locally.

> **Note:** For more information on how to do this, see [plugins](../plugins.md).

### 4.1 Update the Plugin to Add an Install Script

Add the `install` configuration to your plugin's `plugin.config.yaml`

```yaml
plugin:
  # this plugin has install instructions
  install: 
    language: bash
    install_script: install.sh

  deployment:
    language: bash
    deployment_script: deploy.sh
```

Create your install script:

```sh
# /path/to/bitops-plugins/install.sh

#!/bin/bash
set -e

echo "In the install script for the sample-plugin"

apk update && apk upgrade
# add your actual installers here
```

### 4.2. Build a BitOps image

Create a new directory to hold your custom BitOps config. 

In this case we're putting it in our `bitops-plugins` parent dir, but you could put it anywhere.

```sh
IMAGE_PATH=/path/to/bitops-plugins/bitops-images/sample-plugin-image

mkdir -p $IMAGE_PATH && cd $IMAGE_PATH
```

#### 4.2.1 Add the BitOps config

First, add your BitOps level `bitops.config.yaml` and include a reference to your local file dependency via the `plugins` and  `deployments` sections:

```yaml
# /path/to/bitops-plugins/bitops-images/sample-plugin-image/bitops.config.yaml
# Note that again these are docker-context paths, not local paths.

bitops:
  plugins:    
    sample-plugin:
      source: file:///opt/bitops-local-plugins/sample-plugin
  deployments:
    sample-plugin:
      plugin: sample-plugin
```

> **Note:** This is the same file as above (`/path/to/ops-repo/test-env/sample-plugin/bitops.config.yaml`), but we've updated the `plugins.sample-plugin` object to include a `file://` source.
>
> **Note:** The path of the source is reserved by BitOps for locally developed plugins.  When you build a custom BitOps image, if there is a `plugins` directory as a sibling to the `Dockerfile`, BitOps will copy that file into the container at `/opt/bitops-local-plugins`.

#### 4.2.2 Add your Dockerfile

```Dockerfile
# /path/to/bitops-plugins/bitops-images/sample-plugin-image/Dockerfile

FROM bitovi/bitops:base
```

#### 4.2.3 Copy plugin code to the BitOps directory

In order for the build to have access to your local plugin files, they'll need to be in the same directory as the `Dockerfile`.  One quick way to do this is to set up a simple script to run prior to your docker build to clean and re-copy the plugin files:

```sh
# /path/to/bitops-images/copy-plugins.sh

#!/bin/bash

PLUGIN_NAME=sample-plugin
PLUGIN_ROOT_PATH=/path/to/bitops-plugins

CUSTOM_IMAGE_PATH="$PLUGIN_ROOT_PATH/bitops-images/$PLUGIN_NAME-plugin-image"
PLUGIN_PATH="$PLUGIN_ROOT_PATH/$PLUGIN_NAME"

mkdir -p "$CUSTOM_IMAGE_PATH/plugins"

# clean and copy to the image build dir
rm -rf $CUSTOM_IMAGE_PATH/plugins/$PLUGIN_NAME
cp -r $PLUGIN_PATH "$CUSTOM_IMAGE_PATH/plugins/$PLUGIN_NAME"

```

#### 4.2.4 Build the image

```sh
./copy-plugins.sh

docker build --tag bitovi/bitops:local-sample-plugin --no-cache .
```

#### 4.2.5. Test your plugin

```sh
PATH_ROOT=~/Bitovi/github/bitops-plugins # modify to your path here

docker run --rm --name bitops \
-e BITOPS_ENVIRONMENT="test-env" \
-v $PATH_ROOT/sample-ops-repo:/opt/bitops_deployment \
-v $PATH_ROOT/sample-plugin:/opt/bitops/scripts/installed_plugins/sample-plugin \
bitops:local-sample-plugin
```

## 5. Fully Remote Development

An alternative to local plugin development is to host the plugin code remotely and specify the plugin via url instead of `file://` like:

```yaml
bitops:
  plugins:    
    sample-plugin:
      source: https://github.com/your-org/sample-plugin
  deployments:
    sample-plugin:
      plugin: sample-plugin
```

Then, you can follow the steps in #5 above (without the `copy-plugins.sh` script).
