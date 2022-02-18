#!/usr/bin/env python
import yaml
import subprocess
import glob
import os.path
from munch import DefaultMunch

MODE = os.environ.get("BITOPS_MODE", "debug")
config_file = "build.config.yaml"

def git(*args):
    return subprocess.check_call(['git'] + list(args))

print("Loading {}".format(config_file))
# Load plugin config yml
with open(config_file, 'r') as stream:
    try:
        plugins_yml = yaml.load(stream, Loader=yaml.FullLoader)
    except yaml.YAMLError as exc:
        print(exc)
    except Exception as exc:
        print(exc) 
    
configuration_struct = DefaultMunch.fromDict(plugins_yml, "bitops")
plugin_dir = "/opt/bitops/scripts/plugins/"
plugins = configuration_struct.bitops.plugins

if plugins is None:
    print("No plugins found. Exiting {}".format(__file__))
    quit()

# Loop through plugins and git clone each
for plugin in plugins:
    print("Preparing plugin: [{}]".format(plugin))
    source = plugins[plugin].source 
    if source is not None:
        print("Downloading plugin: [{}], from: [{}]".format(plugin, source))
        git("clone", source, plugin_dir + plugin)
        print("Downloading complete")


    # install plugin dependencies (install.sh)
    install_script = plugin_dir + plugin + "/install.sh"
    if os.path.isfile(install_script):
        print("Installing plugin: [{}]".format(plugin))
        result = subprocess.run(['bash', install_script], 
            universal_newlines = True,
            capture_output=True)
        print(result.stdout)