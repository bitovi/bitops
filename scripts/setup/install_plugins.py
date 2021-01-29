#!/usr/bin/env python
import yaml
import subprocess
import glob

def git(*args):
    return subprocess.check_call(['git'] + list(args))

# Load plugin config yml
with open("plugin.config.yml", 'r') as stream:
    try:
        plugins_yml = yaml.load(stream, Loader=yaml.FullLoader)
    except yaml.YAMLError as exc:
        print(exc)

# Loop through plugins and git clone each
plugin_dir = "/opt/bitops/scripts/plugins/"
for plugin in plugins_yml.get("plugins"):
    git("clone", plugin['repo'], plugin_dir + plugin['name'])

print(glob.glob(plugin_dir+'*'))