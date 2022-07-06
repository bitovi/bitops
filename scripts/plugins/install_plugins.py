#!/usr/bin/env python
import shutil
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
    bitops_plugins_configuration = DefaultMunch.fromDict(bitops_build_configuration.bitops.plugins, None)

    plugin_dir = BITOPS_plugin_dir

    # Loop through plugins and clone
    for plugin_config in bitops_plugins_configuration:
        logger.info("\n\n\n~#~#~#~PROCESSING STAGE [{}]~#~#~#~\n".format(plugin_config.upper()))
        # for plugin in bitops_plugins_configuration[plugin_config]:
        
        plugin_source = bitops_plugins_configuration[plugin_config].source
        
        logger.info("\n\n\n~#~#~#~PLUGIN SOURCE [{}]~#~#~#~\n".format(plugin_source))

        if plugin_source is not None:
            #~#~#~#~#~#~#~#~#~#~#~#~#~#
            # CLONE PLUGIN FROM SOURCE
            #~#~#~#~#~#~#~#~#~#~#~#~#~#

            plugin_tag = bitops_plugins_configuration[plugin_config].source_tag if bitops_plugins_configuration[plugin_config].source_tag is not None else "latest"
            plugin_branch = bitops_plugins_configuration[plugin_config].source_branch if bitops_plugins_configuration[plugin_config].source_branch is not None else "main"
            

            logger.info("\n\n\n~#~#~#~CLONING PLUGIN [{plugin_config}]~#~#~#~  \
            \n\t PLUGIN_SOURCE:         [{plugin_source}]               \
            \n\t PLUGIN_TAG:            [{plugin_tag}]                  \
            \n\t PLUGIN_BRANCH:         [{plugin_branch}]                \
            \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~# \n                \
            ".format(                                                 
                plugin_config=plugin_config.upper(),
                plugin_source=plugin_source,
                plugin_tag=plugin_tag,
                plugin_branch=plugin_branch
            ))

            try:
                # Non-Entry default
                if plugin_branch == "latest" and plugin_tag == "main":
                    git.Repo.clone_from(plugin_source, plugin_dir+plugin_config)

                # If the plugin branch and tag are specified, default to branch
                elif plugin_branch is not None and plugin_tag is not None:
                    git.Repo.clone_from(plugin_source, plugin_dir+plugin_config, branch=plugin_branch)

                else:
                    plugin_pull_branch = plugin_tag if plugin_branch is None else plugin_branch
                    git.Repo.clone_from(plugin_source, plugin_dir+plugin_config, branch=plugin_pull_branch)
                
                logger.info("\n~#~#~#~CLONING PLUGIN [{plugin_config}] SUCCESSFULLY COMPLETED~#~#~#~".format(plugin_config=plugin_config))

            except git.exc.GitCommandError as exc:
                logger.info("\n~#~#~#~CLONING PLUGIN [{plugin_config}] FAILED~#~#~#~\n\t{stderr}"
                    .format(
                        plugin_config=plugin_config,
                        stderr=exc
                    ))
                if BITOPS_fast_fail_mode: quit()
            
            except Exception as exc:
                logger.info("\n~#~#~#~CLONING PLUGIN [{plugin_config}] CRITICAL ERROR~#~#~#~\n\t{stderr}"
                    .format(
                        plugin_config=plugin_config,
                        stderr=exc
                    ))
                if BITOPS_fast_fail_mode: quit()

            #~#~#~#~#~#~#~#~#~#~#~#~#~#
            # RUN PLUGIN INSTALL SCRIPT
            #~#~#~#~#~#~#~#~#~#~#~#~#~#

            # Once the plugin is cloned, begin using its config + schema
            plugin_configuration_path = plugin_dir+plugin_config+"/plugin.config.yaml" 
            logger.info("plugin_configuration_path ==>[{}]".format(plugin_configuration_path) )
            try:
                with open(plugin_configuration_path, 'r') as stream:
                    plugin_configuration_yaml = yaml.load(stream, Loader=yaml.FullLoader)
            
            except FileNotFoundError as e:
                logger.warning("No plugin file was found at path: [{}]".format(plugin_configuration_path))
                plugin_configuration_yaml = {"plugin" : {"install": {}}}

            plugin_configuration = \
                None if plugin_configuration_yaml is None \
                else DefaultMunch.fromDict(plugin_configuration_yaml, None)                
                            
            # breakdown of values
            #   plugin.config.yaml should be used first
            #   bitops.config.yaml should be used second
            #   A default value should be used as a last resort

            logger.error(plugin_configuration)

            plugin_install_script = plugin_configuration.plugin.install.install_script  \
                if plugin_configuration.plugin.install.install_script is not None       \
                else "install.sh"

            plugin_install_language = plugin_configuration.plugin.install.language  \
                if plugin_configuration.plugin.install.language is not None       \
                else "bash"
                            
            # install plugin dependencies (install.sh)
            plugin_install_script_path = plugin_dir + plugin_config + "/{}".format(plugin_install_script)

            logger.info("\n\n\n~#~#~#~INSTALLING PLUGIN [{plugin_config}]~#~#~#~   \
            \n\t PLUGIN_INSTALL_SCRIPT:             [{plugin_install_script}]          \
            \n\t PLUGIN_INSTALL_LANGUAGE:           [{plugin_install_language}]        \
            \n\t PLUGIN_CONFIG_PATH:                [{plugin_configuration_path}]        \
            \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~# \n                    \
            ".format(  
                plugin_config=plugin_config,                                               
                plugin_install_script=plugin_install_script,
                plugin_install_language=plugin_install_language,
                plugin_configuration_path=plugin_configuration_path
            ))

            os.chmod(plugin_install_script_path, 775)
            if os.path.isfile(plugin_install_script_path):
                result = subprocess.run([plugin_install_language, plugin_install_script_path], 
                    universal_newlines = True,
                    capture_output=True, 
                    #shell=True
                    )
                if result.returncode == 0:
                    logger.info("\n~#~#~#~INSTALLING PLUGIN [{plugin_config}] SUCCESSFULLY COMPLETED~#~#~#~".format(plugin_config=plugin_config))
                    logger.debug("\n\tSTDOUT:[{stdout}]\n\tSTDERR: [{stderr}]\n\tRESULTS: [{result}]".format(stdout=result.stdout, stderr=result.stderr, result=result))
                else:
                    logger.warning("\n~#~#~#~INSTALLING PLUGIN [{plugin_config}] FAILED~#~#~#~".format(plugin_config=plugin_config))
                    logger.debug("\n\tSTDOUT:[{stdout}]\n\tSTDERR: [{stderr}]\n\tRESULTS: [{result}]".format(stdout=result.stdout, stderr=result.stderr, result=result))
                
            else:
                logger.error("File does not exist: [{}]".format(plugin_install_script_path)) 
        else:
            logger.error("Plugin source cannot be empty. Plugin: [{}] Download did not run".format(plugin_config))
        