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
        
            plugin_source = bitops_plugins_configuration[plugin_config][plugin].source.sourced_from
            
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

                # Once the plugin is cloned, begin using its config + schema
                plugin_configuration_path = "config/{}.plugin.config.yaml".format(plugin) 

                try:
                    with open(plugin_configuration_path, 'r') as stream:
                        plugin_configuration_yaml = yaml.load(stream, Loader=yaml.FullLoader)
                except FileNotFoundError as e:
                    logger.warning("No plugin file was found at path: [{}]".format(plugin_configuration_path))
                    # plugin_configuration_yaml = None
                    plugin_configuration_yaml = {"{}".format(plugin) : {"plugin" : {"install": {}}}}

                plugin_configuration = \
                    None if plugin_configuration_yaml is None \
                    else DefaultMunch.fromDict(plugin_configuration_yaml, None)                
                                
                # breakdown of values
                #   plugin.config.yaml should be used first
                #   bitops.config.yaml should be used second
                #   A default value should be used as a last resort

                plugin_install_script = plugin_configuration[plugin].plugin.install.install_script  \
                    if plugin_configuration[plugin].plugin.install.install_script is not None       \
                    else bitops_plugins_configuration[plugin_config][plugin].install_script         \
                        if bitops_plugins_configuration[plugin_config][plugin].install_script is not None   \
                        else "install.sh"
                
                # The below code is technically a safer, albeit more cumbersome way to accomplish the above.
                # The issue with the above is that if the ".install" value is a NoneType, then it is non subscriptable ".install_sctipt"
                # which will throw an attribute error ...

                # try:
                #     plugin_config_install_script = plugin_configuration[plugin].plugin.install.install_script
                # except TypeError: plugin_config_install_script = None
                # try:
                #     bitops_plugins_configuration_install_script = bitops_plugins_configuration[plugin_config][plugin].install_script
                # except TypeError: bitops_plugins_configuration_install_script = None

                # plugin_install_script = plugin_config_install_script    \
                #     if plugin_config_install_script is not None         \
                #     else bitops_plugins_configuration_install_script    \
                #         if bitops_plugins_configuration_install_script is not None  \
                #         else "install.sh"

                plugin_install_language = plugin_configuration[plugin].plugin.install.language  \
                    if plugin_configuration[plugin].plugin.install.language is not None       \
                    else bitops_plugins_configuration[plugin_config][plugin].language         \
                        if bitops_plugins_configuration[plugin_config][plugin].language is not None   \
                        else "bash"
                                
                # install plugin dependencies (install.sh)
                plugin_install_script_path = plugin_dir + plugin + "/{}".format(plugin_install_script)

                logger.info("\n\n\n~#~#~#~INSTALLING PLUGIN [{plugin}]~#~#~#~   \
                \n\t PLUGIN_INSTALL_SCRIPT:             [{plugin_install_script}]          \
                \n\t PLUGIN_INSTALL_LANGUAGE:           [{plugin_install_language}]        \
                \n\t PLUGIN_CONFIG_PATH:                [{plugin_configuration_path}]        \
                \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~# \n                    \
                ".format(  
                    plugin=plugin,                                               
                    plugin_install_script=plugin_install_script,
                    plugin_install_language=plugin_install_language,
                    plugin_configuration_path=plugin_configuration_path
                ))

                os.chmod(plugin_install_script_path, 775)
                if os.path.isfile(plugin_install_script_path):
                    result = subprocess.run([plugin_install_language, plugin_install_script_path], 
                        universal_newlines = True,
                        capture_output=True, 
                        shell=True)
                    
                    if result.returncode == 0:
                        logger.info("\n~#~#~#~INSTALLING PLUGIN [{plugin}] SUCCESSFULLY COMPLETED~#~#~#~\n\t{stdout}\n\t{stderr}".format(plugin=plugin, stdout=result.stdout, stderr=result.stderr))
                    else:
                        logger.warning("\n~#~#~#~INSTALLING PLUGIN [{plugin}] FAILED~#~#~#~".format(plugin=plugin))
                        logger.warning("\n#~#~#~#~#~#~#~#~#~#~#\n{}\n#~#~#~#~#~#~#~#~#~#~#".format(result.stderr))
                else:
                    logger.error("File does not exist: [{}]".format(plugin_install_script_path)) 
            else:
                logger.error("Plugin source cannot be empty. Plugin: [{}] Download did not run".format(plugin))
        