#!/usr/bin/env python
from ast import Load
import yaml
import subprocess
import glob
import os.path
import os

from .utilties import Load_Build_Config
from munch import DefaultMunch

def install_plugins():
    MODE = os.environ.get("BITOPS_MODE", "debug")

    def git(*args):
        return subprocess.check_call(['git'] + list(args))

    # print("Loading {}".format(config_file))
    # # Load plugin config yml
    # with open(config_file, 'r') as stream:
    #     try:
    #         plugins_yml = yaml.load(stream, Loader=yaml.FullLoader)
    #     except yaml.YAMLError as exc:
    #         print(exc)
    #     except Exception as exc:
    #         print(exc)
        
    plugins_yml = Load_Build_Config()
    bitops_build_configuration = DefaultMunch.fromDict(plugins_yml, "bitops")
    plugin_dir = "/opt/bitops/scripts/plugins/"
    bitops_environment = bitops_build_configuration.bitops.environment
    bitops_plugins = bitops_build_configuration.bitops.plugins

    if bitops_plugins is None:
        print("No plugins found. Exiting {}".format(__file__))
        quit()

    # Loop through plugins and git clone each
    for plugin in bitops_plugins:
        print("Preparing plugin: [{}]".format(plugin))
        source = bitops_plugins[plugin].source 
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