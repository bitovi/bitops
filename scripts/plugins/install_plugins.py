#!/usr/bin/env python

import sys
import os.path
import os
import git
import yaml
import non_existent_module

from munch import DefaultMunch

from .utilities import run_cmd
from .doc import get_doc
from .logging import logger
from .settings import BITOPS_config_yaml, BITOPS_INSTALLED_PLUGINS_DIR

# TODO: Refactor this function. Fix pylint R0914: Too many local variables (22/15) (too-many-locals)
# TODO: Refactor this function. Fix pylint R0915: Too many statements (59/50) (too-many-statements)
# See: https://github.com/bitovi/bitops/issues/329
def install_plugins():  # pylint: disable=too-many-locals,too-many-statements
    """
    Install plugins function:

    1) Processes the BitOps config, pulling out any plugins for install
    2) Loops through the plugins
        - clones source repo
        - installs plugin dependencies (if any)
        - runs install (bash/python) script
    """
    bitops_build_configuration = DefaultMunch.fromDict(BITOPS_config_yaml, None)
    bitops_plugins_configuration = DefaultMunch.fromDict(
        bitops_build_configuration.bitops.plugins, None
    )

    plugin_list = list(bitops_plugins_configuration)
    # Loop through plugins and clone
    for plugin_config in bitops_plugins_configuration:
        logger.info(f"\n\n\n~#~#~#~PROCESSING STAGE [{plugin_config.upper()}]~#~#~#~\n")
        # for plugin in bitops_plugins_configuration[plugin_config]:

        plugin_source = bitops_plugins_configuration[plugin_config].source

        logger.info(f"\n\n\n~#~#~#~PLUGIN SOURCE [{plugin_source}]~#~#~#~\n")

        if not plugin_source:
            logger.error(
                f"Plugin source cannot be empty. Plugin: [{plugin_config}] Download did not run"
            )
            sys.exit(1)

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
            f"\n\n\n~#~#~#~CLONING PLUGIN [{plugin_config.upper()}]~#~#~#~  \
        \n\t PLUGIN_SOURCE:         [{plugin_source}]               \
        \n\t PLUGIN_TAG:            [{plugin_tag}]                  \
        \n\t PLUGIN_BRANCH:         [{plugin_branch}]                \
        \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~# \n"
        )

        try:
            # Non-Entry default
            if plugin_branch == "latest" and plugin_tag == "main":
                git.Repo.clone_from(plugin_source, BITOPS_INSTALLED_PLUGINS_DIR + plugin_config)

            # If the plugin branch and tag are specified, default to branch
            elif plugin_branch is not None and plugin_tag is not None:
                git.Repo.clone_from(
                    plugin_source,
                    BITOPS_INSTALLED_PLUGINS_DIR + plugin_config,
                    branch=plugin_branch,
                )

            else:
                plugin_pull_branch = plugin_tag if plugin_branch is None else plugin_branch
                git.Repo.clone_from(
                    plugin_source,
                    BITOPS_INSTALLED_PLUGINS_DIR + plugin_config,
                    branch=plugin_pull_branch,
                )

            logger.info(f"\n~#~#~#~CLONING PLUGIN [{plugin_config}] SUCCESSFULLY COMPLETED~#~#~#~")

        except Exception as err:
            logger.error(
                f"\n~#~#~#~CLONING PLUGIN [{plugin_config}] CRITICAL ERROR~#~#~#~\n\t{err}"
            )
            sys.exit(1)

        # ~#~#~#~#~#~#~#~#~#~#~#~#~#
        # RUN PLUGIN INSTALL SCRIPT
        # ~#~#~#~#~#~#~#~#~#~#~#~#~#

        # Once the plugin is cloned, begin using its config + schema
        plugin_configuration_path = (
            BITOPS_INSTALLED_PLUGINS_DIR + plugin_config + "/plugin.config.yaml"
        )
        logger.info(f"plugin_configuration_path ==>[{plugin_configuration_path}]")
        try:
            with open(plugin_configuration_path, "r", encoding="utf8") as stream:
                plugin_configuration_yaml = yaml.load(stream, Loader=yaml.FullLoader)

        except FileNotFoundError as e:
            msg, _ = get_doc("missing_optional_file")
            logger.warning(f"{msg}: [{plugin_configuration_path}]")
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

        # Checking that any dependency for a plugin is found within
        # the bitops.config.yaml plugins section
        if plugin_install_dependencies:
            missing_dependencies = list(set(plugin_install_dependencies).difference(plugin_list))

            if missing_dependencies:
                logger.critical(
                    f"MISSING DEPENDENCY \
                \n\t NEEDED DEPENDENCY: [{missing_dependencies}] \
                \n\t PLUGIN LIST:       [{plugin_list}] \
                \n\t\t {get_doc('missing_plugin_dependency')[0]}"
                )
                sys.exit(10)

        # install plugin dependencies (install.sh)
        plugin_install_script_path = (
            BITOPS_INSTALLED_PLUGINS_DIR + plugin_config + f"/{plugin_install_script}"
        )

        logger.info(
            f"\n\n\n~#~#~#~INSTALLING PLUGIN [{plugin_config}]~#~#~#~   \
        \n\t PLUGIN_INSTALL_SCRIPT:             [{plugin_install_script}]          \
        \n\t PLUGIN_INSTALL_LANGUAGE:           [{plugin_install_language}]        \
        \n\t PLUGIN_DEPENDENCIES:               [{plugin_install_dependencies}]        \
        \n\t PLUGIN_CONFIG_PATH:                [{plugin_configuration_path}]        \
        \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~# \n                    \
        "
        )

        os.chmod(plugin_install_script_path, 775)
        if not os.path.isfile(plugin_install_script_path):
            logger.error(f"File does not exist: [{plugin_install_script_path}]")
            sys.exit(1)

        result = run_cmd([plugin_install_language, plugin_install_script_path])
        if result.returncode == 0:
            logger.info(f"~#~#~#~INSTALLING PLUGIN [{plugin_config}] SUCCESSFULLY COMPLETED~#~#~#~")
            logger.debug(
                f"\n\tSTDOUT:[{result.stdout}]\n"
                f"\tSTDERR: [{result.stderr}]\n\tRESULTS: [{result}]"
            )
        else:
            logger.error(f"\n~#~#~#~INSTALLING PLUGIN [{plugin_config}] FAILED~#~#~#~")
            logger.debug(
                f"\n\tSTDOUT:[{result.stdout}]\n"
                f"\tSTDERR: [{result.stderr}]\n\tRESULTS: [{result}]"
            )
            sys.exit(result.returncode)
