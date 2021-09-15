# Plugins

BitOps' default image is actually BitOps core with 4 plugins pre-installed:
* [bitops-terraform-plugin](https://github.com/bitovi/bitops-terraform-plugin.git)
* [bitops-ansible-plugin](https://github.com/bitovi/bitops-ansible-plugin.git)
* [bitops-cloudformation-plugin](https://github.com/bitovi/bitops-cloudformation-plugin.git)
* [bitops-helm-plugin](https://github.com/bitovi/bitops-helm-plugin.git)

You can create your own BitOps image to customize runtime behavior by installing your own plugins

## Creating your own BitOps
To create your own BitOps, you'll need 2 files
* `plugin.config.yaml` - specify what plugins you need
* `Dockerfile` - to override the default `plugin.config.yaml`

### plugin.config.yaml
Best explained with an example, The default `plugin.config.yaml` looks like this:
```
plugins:
- name: terraform
  repo: https://github.com/bitovi/bitops-terraform-plugin.git
- name: ansible
  repo: https://github.com/bitovi/bitops-ansible-plugin.git
- name: cloudformation
  repo: https://github.com/bitovi/bitops-cloudformation-plugin.git
- name: helm
  repo: https://github.com/bitovi/bitops-helm-plugin.git
```
The repo for each plugin must be a `git clone`-able url. The name can be anything.

The order that plugins appear in the list also dictate their execution order during both installation and runtime.

**Dockerfile**
Now using `bitops-core`, we will overwrite the default `plugin.config.yaml` with our own and force an installation of the plugins
```
FROM bitops-core
COPY plugin.config.yaml .
RUN python scripts/setup/install_plugins.py
```

## Creating your own Plugin
Creating a plugin is easy, you only need 3 files:
* `install.sh` - This script is called during plugin installation (docker build time). It should be used to install any dependencies needed for your plugin to function 
* `deploy.sh` - The main entrypoint for your plugin
* `bitops.schema.yaml` - Allows users to pass parameters in to your plugin using a `bitops.config.yaml` (https://bitovi.github.io/bitops/configuration-base/)
For more information, you can look at our sample plugin repo that prints your name and favorite color!
https://github.com/bitovi/bitops-sample-plugin.git

## Local plugins not from GitHub

If users want to use BitOps with arbitrary plugins, then they need to create their own repo that looks something like:
```
my-bitops
├── Dockerfile
└── plugin.config.yaml
```

The Dockerfile looks like:
```
FROM bitops-core
COPY plugin.config.yaml .
RUN python scripts/setup/install_plugins.py
```

To add your own local plugins the my-bitops repo should be extended to contain my "local" plugins
```
my-bitops
├── Dockerfile
├── plugin.config.yaml
└── plugins
    └── my-custom-plugin-1
```
These local plugins need to be passed in to the docker context by include them in the Dockerfile
```
FROM bitops-core
COPY plugin.config.yaml .
ADD ./plugins/ /scripts/plugins/
RUN python scripts/setup/install_plugins.py
```

Finally, if you wanted to run your custom plugin and then the ansible plugin, `plugin.config.yaml` would look like
```
plugins:
  - name: my-custom-plugin-1
  - name: ansible
    repo: https://github.com/bitovi/bitops-ansible-plugin.git
```