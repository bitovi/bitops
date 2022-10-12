#!/usr/bin/env python

import shutil
import yaml
import subprocess
import glob
import os.path
import os
import git
import sys

from .settings import BITOPS_config_yaml, BITOPS_plugin_dir
from .logging import logger
from .doc import Get_Doc
from ast import Load
from munch import DefaultMunch, Munch


def Install_Plugins():
    bitops_build_configuration = DefaultMunch.fromDict(BITOPS_config_yaml, None)
    bitops_plugins_configuration = DefaultMunch.fromDict(
        bitops_build_configuration.bitops.plugins, None
    )

    plugin_dir = BITOPS_plugin_dir
    plugin_list = [item for item in bitops_plugins_configuration]
    # Loop through plugins and clone
    for plugin_config in bitops_plugins_configuration:
        logger.info(
            "\n\n\n~#~#~#~PROCESSING STAGE [{}]~#~#~#~\n".format(plugin_config.upper())
        )
        # for plugin in bitops_plugins_configuration[plugin_config]:

        plugin_source = bitops_plugins_configuration[plugin_config].source

        logger.info("\n\n\n~#~#~#~PLUGIN SOURCE [{}]~#~#~#~\n".format(plugin_source))

        if plugin_source is not None:
            # ~#~#~#~#~#~#~#~#~#~#~#~#~#
            # CLONE PLUGIN FROM SOURCE
            # ~#~#~#~#~#~#~#~#~#~#~#~#~#

            plugin_tag = (
                bitops_plugins_configuration[plugin_config].source_tag
                if bitops_plugins_configuration[plugin_config].source_tag is not None
                else "latest"
            )
            plugin_branch = (
                bitops_plugins_configuration[plugin_config].source_branch
                if bitops_plugins_configuration[plugin_config].source_branch is not None
                else "main"
            )

            logger.info(
                "\n\n\n~#~#~#~CLONING PLUGIN [{plugin_config}]~#~#~#~  \
            \n\t PLUGIN_SOURCE:         [{plugin_source}]               \
            \n\t PLUGIN_TAG:            [{plugin_tag}]                  \
            \n\t PLUGIN_BRANCH:         [{plugin_branch}]                \
            \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~# \n                \
            ".format(
                    plugin_config=plugin_config.upper(),
                    plugin_source=plugin_source,
                    plugin_tag=plugin_tag,
                    plugin_branch=plugin_branch,
                )
            )

            try:
                # Non-Entry default
                if plugin_branch == "latest" and plugin_tag == "main":
                    git.Repo.clone_from(plugin_source, plugin_dir + plugin_config)

                # If the plugin branch and tag are specified, default to branch
                elif plugin_branch is not None and plugin_tag is not None:
                    git.Repo.clone_from(
                        plugin_source, plugin_dir + plugin_config, branch=plugin_branch
                    )

                else:
                    plugin_pull_branch = (
                        plugin_tag if plugin_branch is None else plugin_branch
                    )
                    git.Repo.clone_from(
                        plugin_source,
                        plugin_dir + plugin_config,
                        branch=plugin_pull_branch,
                    )

                logger.info(
                    "\n~#~#~#~CLONING PLUGIN [{plugin_config}] SUCCESSFULLY COMPLETED~#~#~#~".format(
                        plugin_config=plugin_config
                    )
                )

            except git.exc.GitCommandError as exc:
                logger.error(
                    "\n~#~#~#~CLONING PLUGIN [{plugin_config}] FAILED~#~#~#~\n\t{stderr}".format(
                        plugin_config=plugin_config, stderr=exc
                    )
                )
                sys.sys.exit(1)

            except Exception as exc:
                logger.error(
                    "\n~#~#~#~CLONING PLUGIN [{plugin_config}] CRITICAL ERROR~#~#~#~\n\t{stderr}".format(
                        plugin_config=plugin_config, stderr=exc
                    )
                )
                sys.sys.exit(1)

            # ~#~#~#~#~#~#~#~#~#~#~#~#~#
            # RUN PLUGIN INSTALL SCRIPT
            # ~#~#~#~#~#~#~#~#~#~#~#~#~#

            # Once the plugin is cloned, begin using its config + schema
            plugin_configuration_path = (
                plugin_dir + plugin_config + "/plugin.config.yaml"
            )
            logger.info(
                "plugin_configuration_path ==>[{}]".format(plugin_configuration_path)
            )
            try:
                with open(plugin_configuration_path, "r") as stream:
                    plugin_configuration_yaml = yaml.load(
                        stream, Loader=yaml.FullLoader
                    )

            except FileNotFoundError as e:
                msg, exit_code = Get_Doc("missing_file")
                logger.warning("{} [{}]".format(msg, plugin_configuration_path))
                logger.debug(e)
                plugin_configuration_yaml = {"plugin": {"install": {}}}
            plugin_configuration = (
                None
                if plugin_configuration_yaml is None
                else DefaultMunch.fromDict(plugin_configuration_yaml, None)
            )

            # breakdown of values
            #   plugin.config.yaml should be used first
            #   bitops.config.yaml should be used second
            #   A default value should be used as a last resort

            # plugin.install.install_script
            plugin_install_script = (
                plugin_configuration.plugin.install.install_script
                if plugin_configuration.plugin.install.install_script is not None
                else "install.sh"
            )

            # plugin.install.language
            plugin_install_language = (
                plugin_configuration.plugin.install.language
                if plugin_configuration.plugin.install.language is not None
                else "bash"
            )

            # plugin.install.dependencies
            plugin_install_dependencies = (
                plugin_configuration.plugin.install.dependencies
                if plugin_configuration.plugin.install.dependencies is not None
                else None
            )

            # Checking that any dependency for a plugin is found within the bitops.config.yaml plugins section
            if plugin_install_dependencies:
                missing_dependencies = list(
                    set(plugin_install_dependencies).difference(plugin_list)
                )

                if missing_dependencies:
                    logger.critical(
                        "MISSING DEPENDENCY \
                    \n\t NEEDED DEPENDENCY: [{}] \
                    \n\t PLUGIN LIST:       [{}] \
                    \n\t\t {doc_link} \
                    ".format(
                            missing_dependencies,
                            plugin_list,
                            doc_link=Get_Doc("missing_plugin_dependency"),
                        )
                    )
                    sys.exit(10)

            # install plugin dependencies (install.sh)
            plugin_install_script_path = (
                plugin_dir + plugin_config + "/{}".format(plugin_install_script)
            )

            logger.info(
                "\n\n\n~#~#~#~INSTALLING PLUGIN [{plugin_config}]~#~#~#~   \
            \n\t PLUGIN_INSTALL_SCRIPT:             [{plugin_install_script}]          \
            \n\t PLUGIN_INSTALL_LANGUAGE:           [{plugin_install_language}]        \
            \n\t PLUGIN_DEPENDENCIES:               [{plugin_install_dependencies}]        \
            \n\t PLUGIN_CONFIG_PATH:                [{plugin_configuration_path}]        \
            \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~# \n                    \
            ".format(
                    plugin_config=plugin_config,
                    plugin_install_script=plugin_install_script,
                    plugin_install_language=plugin_install_language,
                    plugin_install_dependencies=plugin_install_dependencies,
                    plugin_configuration_path=plugin_configuration_path,
                )
            )

            os.chmod(plugin_install_script_path, 775)
            if os.path.isfile(plugin_install_script_path):
                result = subprocess.run(
                    [plugin_install_language, plugin_install_script_path],
                    universal_newlines=True,
                    capture_output=True,
                    # shell=True
                )
                if result.returncode == 0:
                    logger.info(
                        "\n~#~#~#~INSTALLING PLUGIN [{plugin_config}] SUCCESSFULLY COMPLETED~#~#~#~".format(
                            plugin_config=plugin_config
                        )
                    )
                    logger.debug(
                        "\n\tSTDOUT:[{stdout}]\n\tSTDERR: [{stderr}]\n\tRESULTS: [{result}]".format(
                            stdout=result.stdout, stderr=result.stderr, result=result
                        )
                    )
                else:
                    logger.error(
                        "\n~#~#~#~INSTALLING PLUGIN [{plugin_config}] FAILED~#~#~#~".format(
                            plugin_config=plugin_config
                        )
                    )
                    logger.debug(
                        "\n\tSTDOUT:[{stdout}]\n\tSTDERR: [{stderr}]\n\tRESULTS: [{result}]".format(
                            stdout=result.stdout, stderr=result.stderr, result=result
                        )
                    )
                    sys.sys.exit(result.returncode)

            else:
                logger.error(
                    "File does not exist: [{}]".format(plugin_install_script_path)
                )
                sys.sys.exit(1)
        else:
            logger.error(
                "Plugin source cannot be empty. Plugin: [{}] Download did not run".format(
                    plugin_config
                )
            )
            sys.sys.exit(1)
