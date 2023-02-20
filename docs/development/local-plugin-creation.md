# Plugin creation guide

So you wanna build a BitOps plugin, eh?  Follow along for how to do it locally!

## 1. Create a plugin repo
```sh
cd /path/to/bitops-plugins
mkdir my-plugin
cd my-plugin
```
More information on what goes in a plugin [here](../plugins.md).

> Note: If the plugin needs to install tools, you will need to build and run a local version of BitOps.  The first portion of this guide assumes the install.sh script **DOES NOT** needs to be run.  For more information about how to set up BitOps for local development with a plugin that requires an installation, skip to step 5 below.


For this example, we'll keep to a really simple plugin.

To start with, create a file called `bitops.schema.yaml` and add the following content.
```yaml
duplicate-environment:
    type: object
    properties:
      # CLI properties will composed into a CLI string and exported as "${BITOPS_MY_PLUGIN_CLI}"
      cli:
        type: object
        properties:
          # positional argument, if no `parameter` set
          # ex: "run"
          command:
            type: string
            default: run
            required: true
          # cli argument
          # ex: "--key=value"
          key:
            parameter: key
            type: string
          # boolean flag, set if value is `true`
          # ex: "--bar"
          bar:
            parameter: bar
            type: boolean
            default: true
      options:
        type: object
        properties:
          foo:
            type: string
            export_env: DUPLICATE_ENVIRONMENT_FOO
            required: true
            default: foo_value
```

Next, create a simple `deploy.sh` script.  This script does some checks and shows how to use some of the available environment variables then outputs a configuration value defined by the `bitops.schema.yaml`.
```sh
#!/bin/bash
set -ex

echo "Running Duplicate Environment Plugin deployment script..."

# vars
export BITOPS_SCHEMA_ENV_FILE="$BITOPS_OPSREPO_ENVIRONMENT_DIR/ENV_FILE"

if [ ! -d "$BITOPS_OPSREPO_ENVIRONMENT_DIR" ]; then
  echo "No duplicate-environment directory.  Skipping."
  exit 0
fi

printf "Deploying duplicate-environment..."

if [ ! -f "$BITOPS_SCHEMA_ENV_FILE" ]; then 
  echo "No duplicate-environment ENV file found"
else
  source "$BITOPS_SCHEMA_ENV_FILE"
fi

cd $BITOPS_OPSREPO_ENVIRONMENT_DIR

echo "Listing contents of duplicate-environment Root: $BITOPS_OPSREPO_ENVIRONMENT_DIR"
ls -al .


echo "Running the plugin CLI:"
# plugin_command run --key=value --bar
echo plugin_command "${BITOPS_MY_PLUGIN_CLI}"

echo "Options:"
echo "DUPLICATE_ENVIRONMENT_FOO"
echo "$DUPLICATE_ENVIRONMENT_FOO"

```
> **Note:** Much of the above is best practice boilerplate and is not strictly necessary.

> **Important:** Be sure to `chmod +x deploy.sh`

Finally, create a `plugin.config.yaml` to configure how BitOps uses the plugin.
```yaml
plugin:
  deployment:
    language: bash
    deployment_script: deploy.sh
    core_schema_parsing: true
    life_cycle_scripts: true
```


## 2. Create an ops repo for testing
```sh
cd /path/to/ops-repos
mkdir duplicate-environment
cd duplicate-environment
```

From there, you'll need to create an environment with a directory that matches your tool.

`mkdir -p /path/to/ops-repo/plugin-no-install/duplicate-environment`

Populate the tool's `bitops.config.yaml` based on the schema defined above:
`/path/to/ops-repo/plugin-no-install/duplicate-environment/bitops.config.yaml`
```yaml
duplicate-environment:
  cli:
    command: run
    key: value
    bar: true
  options:
    foo: baz
```

## 3. Test your plugin

### 3.1. BitOps-level BitOps Config
To test your plugin, you'll need BitOps to run with a BitOps-level BitOps config that has your plugin defined in the `deployments`.

Create a `bitops.config.yaml` somewhere (say: `/path/to/ops-repo/plugin-no-install/duplicate-environment/bitops-level/bitops.config.yaml`), and add a `plugins` and `deployments` reference to your plugin:
```yaml
bitops:
  fail_fast: true
  logging:      
    level: DEBUG              # Sets the logging level
    color:
      enabled: true           # Enables colored logs
  plugins:    
    duplicate-environment: {}
  deployments:
    duplicate-environment:
      plugin: duplicate-environment
```
> **NOTE:** `plugins.duplicate-environment` is empty because it's only used as a reference for `deployments.duplicate-environment`.

### 3.2. Run your test
To run BitOps against a local plugin, you'll need to mount the plugin to the location BitOps expects plugins to be.
```sh
docker run --rm --name bitops \
-e BITOPS_ENVIRONMENT="duplicate-environment" \
-v /path/to/bitops:/opt/bitops \
-v /path/to/ops-repo/plugin-no-install:/opt/bitops_deployment \
-v /path/to/bitops-level/bitops.config.yaml:/opt/bitops/bitops.config.yaml \
-v /opt/bitops/scripts/plugins/terraform \
-v /path/to/bitops-plugins/duplicate-environment:/opt/bitops/scripts/installed-plugins/duplicate-environment \
bitovi/bitops:dev
```

> **Note:** To see the full code so far, see [docs/examples/plugin-examples/plugin-no-install/duplicate-environment](../docs/examples/plugin-examples/plugin-no-install/duplicate-environment)



## 4. Handling the Plugin Install Script
If your new plugin needs to run some install scripts (e.g. to install a CLI tool, for example), you'll need to build your own version of BitOps locally.

> **Note:** For more information on how to do this, see [plugins](../plugins.md).


### 4.1. Update the Plugin to Add an Install Script
Add the `install` configuration to your plugin's `plugin.config.yaml`
```yaml
plugin:
  install: 
    language: bash
    install_script: install.sh

  deployment:
    language: bash
    deployment_script: deploy.sh
    core_schema_parsing: true
    life_cycle_scripts: true
```

Add your install script:

`install.sh`
```sh
#!/bin/bash
set -e

echo ""
echo "When including a plugin in a BitOps install, this script will be called during docker build."
echo "It should be used to install any dependencies required to actually run your plugin."
echo "BitOps uses alpine linux as its base, so you'll want to use apk commands (Alpine Package Keeper)"
echo ""

apk info

echo "In the install script for the duplicate-environment"

echo "Install your things here"
```


### 4.2. Build a BitOps image

Create a new directory to hold your custom BitOps config:
```sh
mkdir /path/to/bitops-custom
cd /path/to/bitops-custom
```

#### 4.2.1. Add the BitOps config
First, add your BitOps level `bitops.config.yaml` and include a reference to your local file dependency (via `plugins`) and a reference in the `deployments` section:
```yaml
bitops:
  fail_fast: true
  run_mode: default   # (Unused for now)
  logging:      
    level: DEBUG              # Sets the logging level
    color:
      enabled: true           # Enables colored logs
    filename: bitops-run      # log filename
    err: bitops.logs          # error logs filename
    path: /var/logs/bitops    # path to log folder
  default_folder: _default
  plugins:    
    duplicate-environment:
      source: file:///opt/bitops-local-plugins/duplicate-environment
  deployments:
    duplicate-environment:
      plugin: duplicate-environment
```
> **Note:** This is the same file as above (`/path/to/ops-repo/plugin-no-install/duplicate-environment/bitops-level/bitops.config.yaml`), but we've filled in the `plugins.duplicate-environment` object to include a `file://` source.  We will not use the previous file and will instead focus on this file.

> **Note:** The path of the source is reserved by BitOps for locally developed plugins.  When you build a custom BitOps image, if there is a `plugins` directory as a sibling to the `Dockerfile`, BitOps will copy that file into the container at `/opt/bitops-local-plugins`.

#### 4.2.2. Add your Dockerfile

`Dockerfile`
```Dockerfile
FROM bitovi/bitops:base
```

#### 4.2.3. Copy plugin code to the BitOps directory
In order for the build to have access to your local plugin files, they'll need to be in the same directory as the `Dockerfile`.  One quick way to do this is to set up a simple script to run prior to your docker build to clean and re-copy the plugin files:

`copy-plugins.sh`
```sh
#!/bin/bash

mkdir -p /path/to/bitops-custom/plugins

# duplicate-environment
rm -rf /path/to/bitops-custom/plugins/duplicate-environment
cp -r /path/to/bitops-plugins/duplicate-environment /path/to/bitops-custom/plugins/duplicate-environment
```

> **Note:** The `/path/to/bitops-custom/plugins` directory is reserved by BitOps for the purpose of developing plugins locally.


#### 4.2.4. Build the image
```sh
./copy-plugins.sh
docker build bitops --tag bitovi/bitops:local-custom --progress=plain --no-cache .
```

#### 4.2.5. Test your plugin
```sh
docker run --rm --name bitops \
-e BITOPS_ENVIRONMENT="duplicate-environment" \
-v /path/to/bitops:/opt/bitops \
-v /path/to/ops-repo/plugin-install:/opt/bitops_deployment \
-v /path/to/bitops-level/bitops.config.yaml:/opt/bitops/bitops.config.yaml \
-v /opt/bitops/scripts/plugins/terraform \
-v /path/to/bitops-plugins/duplicate-environment:/opt/bitops/scripts/installed_plugins/duplicate-environment \
bitops:local-custom
```


## 5. Handling the Plugin Install Script (remote)
As an alternative way to develop plugins locally is simply to host the plugin code/config remotely and specify the plugin via url instead of `file://` like:
```yaml
bitops:
  fail_fast: true
  run_mode: default   # (Unused for now)
  logging:      
    level: DEBUG              # Sets the logging level
    color:
      enabled: true           # Enables colored logs
    filename: bitops-run      # log filename
    err: bitops.logs          # error logs filename
    path: /var/logs/bitops    # path to log folder
  default_folder: _default
  plugins:    
    duplicate-environment:
      source: https://github.com/your-org/your-plugin
  deployments:
    duplicate-environment:
      plugin: duplicate-environment
```

Then, you can follow the steps in #5 above (sans the `copy-plugins.sh` script).
