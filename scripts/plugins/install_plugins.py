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
    def git(*args):
        return subprocess.check_call(['git'] + list(args))
        
    plugins_yml = Load_Build_Config()
    bitops_build_configuration = DefaultMunch.fromDict(plugins_yml, None)
    plugin_dir = "/opt/bitops/scripts/plugins/"
    # bitops_environment = bitops_build_configuration.bitops.environment
    bitops_plugins_configuration = DefaultMunch.fromDict(bitops_build_configuration.bitops.plugins.tools, None)

    #print(bitops_build_configuration.bitops.plugins)
    #print(bitops_build_configuration.bitops.plugins.tools)
    #print(bitops_build_configuration.bitops.plugins.plugins_seq)

    if bitops_plugins_configuration is None:
        print("No plugins found. Exiting {}".format(__file__))
        quit()

    # Loop through plugins and git clone each
    for plugin in bitops_plugins_configuration:
        print("Preparing plugin: [{}]".format(plugin))
        source = bitops_plugins_configuration[plugin].source
        download_logging_message = "Something went wrong during the plugin [{}] download".format(plugin)
        
        if source is not None:
            plugin_logging = "using branch: [master] "
            install_tag = bitops_plugins_configuration[plugin].source_tag
            install_branch = bitops_plugins_configuration[plugin].source_branch
            
            if install_branch is None and install_tag is None:
                install_tag = "latest"
                install_branch = "master"

            elif install_branch is not None and install_tag is not None:
                install_tag=""
                plugin_logging = ", using branch: [{}]".format(install_branch)

            else:
                plugin_logging = ", using tag: [{}]".format(install_tag) if install_branch is None else ", using branch: [{}]".format(install_branch)


            print("Downloading plugin: [{}], from: [{}], {}".format(plugin, source, plugin_logging))
            git("clone", source, plugin_dir + plugin)
            download_logging_message = "Download completed"
        else:
            print("Plugin source cannot be empty. Plugin: [{}]".format(plugin))
            download_logging_message = "Download did not run"
        
        print(download_logging_message)


        # install plugin dependencies (install.sh)
        install_script = plugin_dir + plugin + "/install.sh"
        if os.path.isfile(install_script):
            print("Installing plugin: [{}]".format(plugin))
            result = subprocess.run(['bash', install_script], 
                universal_newlines = True,
                capture_output=True)
            print(result.stdout)