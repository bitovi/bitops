#!/usr/bin/env python
import yaml
import subprocess
import glob
import os.path
import os
import git

from .settings import BITOPS_config_yaml, BITOPS_fast_fail_mode, BITOPS_plugin_dir
from .logging import logger
from ast import Load
from munch import DefaultMunch, Munch


def Install_Plugins():
    bitops_build_configuration = DefaultMunch.fromDict(BITOPS_config_yaml, None)
    bitops_plugins_configuration = DefaultMunch.fromDict(bitops_build_configuration.bitops.plugins.tools, None)

    plugin_dir = BITOPS_plugin_dir

    # Loop through plugins and clone
    for plugin_config in bitops_plugins_configuration:
        logger.info("\n\n\n~#~#~#~PROCESSING STAGE [{}]~#~#~#~\n".format(plugin_config.upper()))
        for plugin in bitops_plugins_configuration[plugin_config]:
        
            plugin_source = bitops_plugins_configuration[plugin_config][plugin].source
            
            if plugin_source is not None:
                #~#~#~#~#~#~#~#~#~#~#~#~#~#
                # CLONE PLUGIN FROM SOURCE
                #~#~#~#~#~#~#~#~#~#~#~#~#~#
                
                plugin_tag = bitops_plugins_configuration[plugin_config][plugin].source_tag if bitops_plugins_configuration[plugin_config][plugin].source_tag is not None else "latest"
                plugin_branch = bitops_plugins_configuration[plugin_config][plugin].source_branch if bitops_plugins_configuration[plugin_config][plugin].source_branch is not None else "main"
                
                logger.info("\n\n\n~#~#~#~CLONING PLUGIN [{plugin}]~#~#~#~  \
                \n\t PLUGIN_SOURCE:         [{plugin_source}]               \
                \n\t PLUGIN_TAG:            [{plugin_tag}]                  \
                \n\t PLUGIN_BRANCH:         [{plugin_branch}]                \
                \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~# \n                \
                ".format(                                                 
                    plugin=plugin.upper(),
                    plugin_source=plugin_source,
                    plugin_tag=plugin_tag,
                    plugin_branch=plugin_branch
                ))

                try:
                    # Non-Entry default
                    if plugin_branch == "latest" and plugin_tag == "main":
                        git.Repo.clone_from(plugin_source, plugin_dir+plugin)

                    # If the plugin branch and tag are specified, default to branch
                    elif plugin_branch is not None and plugin_tag is not None:
                        git.Repo.clone_from(plugin_source, plugin_dir+plugin, branch=plugin_branch)

                    else:
                        plugin_pull_branch = plugin_tag if plugin_branch is None else plugin_branch
                        git.Repo.clone_from(plugin_source, plugin_dir+plugin, branch=plugin_pull_branch)
                    
                    logger.info("\n~#~#~#~CLONING PLUGIN [{plugin}] SUCCESSFULLY COMPLETED~#~#~#~".format(plugin=plugin))

                except git.exc.GitCommandError as exc:
                    logger.info("\n~#~#~#~CLONING PLUGIN [{plugin}] FAILED~#~#~#~\n\t{stderr}"
                        .format(
                            plugin=plugin,
                            stderr=exc
                        ))
                    if BITOPS_fast_fail_mode: quit()
                
                except Exception as exc:
                    logger.info("\n~#~#~#~CLONING PLUGIN [{plugin}] CRITICAL ERROR~#~#~#~\n\t{stderr}"
                        .format(
                            plugin=plugin,
                            stderr=exc
                        ))
                    if BITOPS_fast_fail_mode: quit()

                #~#~#~#~#~#~#~#~#~#~#~#~#~#
                # RUN PLUGIN INSTALL SCRIPT
                #~#~#~#~#~#~#~#~#~#~#~#~#~#
                # Check if Version
                plugin_version = bitops_plugins_configuration[plugin_config][plugin].version
                
                # Check if install script config is present
                plugin_install_script = bitops_plugins_configuration[plugin_config][plugin].install_script  if bitops_plugins_configuration[plugin_config][plugin].install_script else "install.sh"
                plugin_install_language = "bash" if plugin_install_script[-2:] == "sh" else "python3"

                # Check the file ext - if not bash or python fail
                
                # install plugin dependencies (install.sh)
                plugin_install_script_path = plugin_dir + plugin + "/{}".format(plugin_install_script)
                
                
                logger.info("\n\n\n~#~#~#~INSTALLING PLUGIN [{plugin}]~#~#~#~   \
                \n\t PLUGIN_VERSION:                    [{plugin_version}]       \
                \n\t PLUGIN_INSTALL_SCRIPT:             [{plugin_install_script}]          \
                \n\t PLUGIN_INSTALL_LANGUAGE:           [{plugin_install_language}]        \
                \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~# \n                    \
                ".format(  
                    plugin=plugin,                                               
                    plugin_version=plugin_version,
                    plugin_install_script=plugin_install_script,
                    plugin_install_language=plugin_install_language,
                ))

                if os.path.isfile(plugin_install_script_path):
                    result = subprocess.run([plugin_install_language, plugin_install_script_path, "{}".format(plugin_version)], 
                        universal_newlines = True,
                        capture_output=True, 
                        shell=True)
                    logger.info("results from [{}] ReturnCode: [{}]".format(plugin_install_script_path, result.returncode))
                
                else:
                    logger.warning("File does not exist: [{}]".format(plugin_install_script_path))
                
            else:
                logger.warning("Plugin source cannot be empty. Plugin: [{}] Download did not run".format(plugin))
        