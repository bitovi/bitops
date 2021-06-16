#!/usr/bin/env python
import yaml
import subprocess
import glob
import os.path

def git(*args):
    return subprocess.check_call(['git'] + list(args))

# Load plugin config yml
with open("plugin.config.yaml", 'r') as stream:
    try:
        plugins_yml = yaml.load(stream, Loader=yaml.FullLoader)
    except yaml.YAMLError as exc:
        print(exc)

plugin_dir = "/opt/bitops/scripts/plugins/"
plugins = plugins_yml.get("plugins")
if plugins is None:
    quit()

# Loop through plugins and git clone each
for plugin in plugins:
    if plugin['repo'] is not None:
        git("clone", plugin['repo'], plugin_dir + plugin['name'])
    # install plugin dependencies (install.sh)
    install_script = plugin_dir + plugin['name'] + "/install.sh"
    if os.path.isfile(install_script):
        result = subprocess.run(['bash', install_script], 
            universal_newlines = True,
            capture_output=True)
        print(result.stdout)