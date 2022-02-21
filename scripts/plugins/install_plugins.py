#!/usr/bin/env python
from ast import Load
import yaml
import subprocess
import glob
import os.path
import os
import git

from .utilties import Load_Build_Config
from munch import DefaultMunch

def install_plugins():
    plugins_yml = Load_Build_Config()

    plugin_dir = "/opt/bitops/scripts/plugins/"

    bitops_build_configuration = DefaultMunch.fromDict(plugins_yml, None)
    bitops_plugins_configuration = DefaultMunch.fromDict(bitops_build_configuration.bitops.plugins.tools, None)
    bitops_logging = bitops_build_configuration.bitops.logging.level

    #print(bitops_build_configuration.bitops.plugins.tools)
    #print(bitops_build_configuration.bitops.plugins.plugins_seq)

    if bitops_plugins_configuration is None:
        print("No plugins found. Exiting {}".format(__file__))
        quit()

    # Loop through plugins and clone
    for plugin in bitops_plugins_configuration:
        print("Preparing plugin: [{}]".format(plugin))
        plugin_source = bitops_plugins_configuration[plugin].source
        
        if plugin_source is not None:
            plugin_tag = bitops_plugins_configuration[plugin].source_tag
            plugin_branch = bitops_plugins_configuration[plugin].source_branch
            
            try:
                # Non-Entry default
                if plugin_branch is None and plugin_tag is None:
                    plugin_tag = "latest"
                    plugin_branch = "master"
                    print("Downloading plugin: [{}], from: [{}], using branch: [master]".format(plugin, plugin_source))
                    git.Repo.clone_from(plugin_source, plugin_dir+plugin)

                # If the plugin branch and tag are specified, default to branch
                elif plugin_branch is not None and plugin_tag is not None:
                    print("Downloading plugin: [{}], from: [{}], using branch: [{}]".format(plugin, plugin_source, plugin_branch))
                    git.Repo.clone_from(plugin_source, plugin_dir+plugin, branch=plugin_branch)

                else:
                    plugin_pull_branch = plugin_tag if plugin_branch is None else plugin_branch
                    print("Downloading plugin: [{}], from: [{}], using branch: [{}]".format(plugin, plugin_source, plugin_pull_branch))
                    git.Repo.clone_from(plugin_source, plugin_dir+plugin, branch=plugin_pull_branch)
                
                print("Plugin [{}] Download completed".format(plugin))

            except git.exc.GitCommandError as exc:
                print("Plugin [{}] Failed to download".format(plugin))
                if bitops_logging == "verbose": print(exc)
            
            except Exception as exc:
                print("Critical error: Plugin [{}] Failed to download".format(plugin))
                if bitops_logging == "verbose": print(exc)

            # Check if Version
            plugin_version = bitops_plugins_configuration[plugin].version
            
            # Check if install script is present
            plugin_install_script = bitops_plugins_configuration[plugin].install_script  if bitops_plugins_configuration[plugin].install_script else "install.sh"
            plugin_install_language = "bash" if plugin_install_script[-2:] == "sh" else "python3"
            
            # install plugin dependencies (install.sh)
            plugin_install_script_path = plugin_dir + plugin + "/{}".format(plugin_install_script)
            print("Install Command: [{} {} {}]".format(plugin_install_language, plugin_install_script_path, plugin_version))
            if os.path.isfile(plugin_install_script_path):
                result = subprocess.run([plugin_install_language, plugin_install_script_path, "{}".format(plugin_version)], 
                    universal_newlines = True,
                    capture_output=True)
                print(result.stdout)
            else:
                print("File does not exist: [{}]".format(plugin_install_script_path))
            
        else:
            print("Plugin source cannot be empty. Plugin: [{}] Download did not run".format(plugin))
    