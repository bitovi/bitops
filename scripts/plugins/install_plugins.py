#!/usr/bin/env python
import yaml
import subprocess
import glob
import os.path
import os
import git

from .settings import BITOPS_config_yaml, BITOPS_fast_fail_mode
from .logging import logger
from ast import Load
from munch import DefaultMunch, Munch


def Install_Plugins():
    bitops_build_configuration = DefaultMunch.fromDict(BITOPS_config_yaml, None)
    bitops_plugins_configuration = DefaultMunch.fromDict(bitops_build_configuration.bitops.plugins.tools, None)

    plugin_dir = "/opt/bitops/scripts/plugins/"

    # Loop through plugins and clone
    for plugin_config in bitops_plugins_configuration:
        logger.info("\n\t\tPreparing plugin_config: [{}]".format(plugin_config))
        for plugin in bitops_plugins_configuration[plugin_config]:
        
            logger.info("\n\t\t\tPreparing plugin: [{}]".format(plugin))
            plugin_source = bitops_plugins_configuration[plugin_config][plugin].source
            
            if plugin_source is not None:
                plugin_tag = bitops_plugins_configuration[plugin_config][plugin].source_tag
                plugin_branch = bitops_plugins_configuration[plugin_config][plugin].source_branch
                
                try:
                    # Non-Entry default
                    if plugin_branch is None and plugin_tag is None:
                        plugin_tag = "latest"
                        plugin_branch = "main"
                        logger.info("Downloading plugin: [{}], from: [{}], using branch: [master]".format(plugin, plugin_source))
                        git.Repo.clone_from(plugin_source, plugin_dir+plugin)

                    # If the plugin branch and tag are specified, default to branch
                    elif plugin_branch is not None and plugin_tag is not None:
                        logger.info("Downloading plugin: [{}], from: [{}], using branch: [{}]".format(plugin, plugin_source, plugin_branch))
                        git.Repo.clone_from(plugin_source, plugin_dir+plugin, branch=plugin_branch)

                    else:
                        plugin_pull_branch = plugin_tag if plugin_branch is None else plugin_branch
                        logger.info("Downloading plugin: [{}], from: [{}], using branch: [{}]".format(plugin, plugin_source, plugin_pull_branch))
                        git.Repo.clone_from(plugin_source, plugin_dir+plugin, branch=plugin_pull_branch)
                    
                    logger.info("Plugin [{}] Download completed".format(plugin))

                except git.exc.GitCommandError as exc:
                    logger.warn("Plugin [{}] Failed to download".format(plugin))
                    logger.warn(exc)
                    if BITOPS_fast_fail_mode: quit()
                
                except Exception as exc:
                    logger.error("Critical error: Plugin [{}] Failed to download".format(plugin))
                    logger.error(exc)
                    if BITOPS_fast_fail_mode: quit()

                # Check if Version
                plugin_version = bitops_plugins_configuration[plugin_config][plugin].version
                
                # Check if install script config is present
                plugin_install_script = bitops_plugins_configuration[plugin_config][plugin].install_script  if bitops_plugins_configuration[plugin_config][plugin].install_script else "install.sh"
                plugin_install_language = "bash" if plugin_install_script[-2:] == "sh" else "python3"

                # Check the file ext - if not bash or python fail
                
                # install plugin dependencies (install.sh)
                plugin_install_script_path = plugin_dir + plugin + "/{}".format(plugin_install_script)
                logger.info("Install Command: [{} {} {}]".format(plugin_install_language, plugin_install_script_path, plugin_version))
                if os.path.isfile(plugin_install_script_path):
                    result = subprocess.run([plugin_install_language, plugin_install_script_path, "{}".format(plugin_version)], 
                        universal_newlines = True,
                        capture_output=True, 
                        shell=True)
                    logger.info("results from [{}] ReturnCode: [{}]".format(plugin_install_script_path, result.returncode))
                else:
                    logger.info("File does not exist: [{}]".format(plugin_install_script_path))
                
            else:
                logger.info("Plugin source cannot be empty. Plugin: [{}] Download did not run".format(plugin))
        