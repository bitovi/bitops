import os
import sys
import stat
import tempfile
from distutils.dir_util import copy_tree
from munch import DefaultMunch
import yaml


from .doc import get_doc
from .utilities import get_config_list, handle_hooks, run_cmd
from .settings import (
    BITOPS_fast_fail_mode,
    bitops_build_configuration,
    BITOPS_ENV_environment,
    BITOPS_default_folder,
    BITOPS_timeout,
    BITOPS_plugin_dir,
    BITOPS_installed_plugins_dir,
)
from .logging import logger


# TODO: Refactor this function. Fix R0914: Too many local variables (36/15) (too-many-locals)
# TODO: Refactor this function. Fix R0912: Too many branches (19/12) (too-many-branches)
# TODO: Refactor this function. Fix R0915: Too many statements (104/50) (too-many-statements)
# See: https://github.com/bitovi/bitops/issues/328
def deploy_plugins():  # pylint: disable=too-many-locals,too-many-branches,too-many-statements,R0801
    """
    The deploy plugins function:

    1) Generates a temporary directory
    2) Preps processing paths
    3) Loads environment variables
    4) Checks that processing paths exist within folder structure
    5) Parses operation repo level bitops config against plugin schema
    6) Loops deployment sequence
        - runs before hooks
        - runs deploy.sh
        - runs after hooks
    """
    # ~#~#~#~#~#~# STAGE 1 - ENVIRONMENT LOADING #~#~#~#~#~#~#
    # Temp directory setup
    temp_dir = tempfile.mkdtemp()
    bitops_deployment_configuration = DefaultMunch.fromDict(
        bitops_build_configuration.bitops.deployments, None
    )

    bitops_dir = "/opt/bitops"
    bitops_deployment_dir = "/opt/bitops_deployment/"
    bitops_plugins_dir = BITOPS_plugin_dir

    bitops_root_dir = temp_dir

    bitops_envroot_dir = f"{bitops_root_dir}/{BITOPS_ENV_environment}"
    bitops_operations_dir = f"{temp_dir}/{BITOPS_ENV_environment}"
    bitops_scripts_dir = f"{bitops_dir}/scripts"

    sys.path.append("/root/.local/bin")

    # Cleanup - Call all teardown scripts - TODO

    # Set global variables
    os.environ["BITOPS_TEMPDIR"] = temp_dir
    os.environ["BITOPS_ENVROOT"] = bitops_operations_dir
    os.environ["BITOPS_DIR"] = bitops_dir
    os.environ["BITOPS_SCRIPTS_DIR"] = bitops_scripts_dir
    os.environ["BITOPS_PLUGINS_DIR"] = BITOPS_installed_plugins_dir
    os.environ["BITOPS_FAIL_FAST"] = str(BITOPS_fast_fail_mode)
    os.environ["BITOPS_KUBE_CONFIG_FILE"] = f"{temp_dir}/.kube/config"
    os.environ["BITOPS_DEFAULT_ROOT_DIR"] = BITOPS_default_folder

    # Global environment evaluation
    # TODO: Drop support for 'ENVIRONMENT' env var
    if "ENVIRONMENT" in os.environ:
        logger.warning(
            "'ENVIRONMENT' var is deprecated in v2.0.0 and will be removed in the future versions! "
            "Use the 'BITOPS_ENVIRONMENT' env var instead!"
        )

    if BITOPS_ENV_environment is None:
        logger.error(
            "The 'BITOPS_ENVIRONMENT' variable must be set! Exiting...\n"
            "For more information on this issue please check out "
            "[https://bitovi.github.io/bitops/configuration-base/#environment]"
        )
        sys.exit(1)

    # Move to temp directory
    if not os.path.isdir(bitops_deployment_dir):
        logger.error(
            "An operations repo needs to be mounted to the Docker container with the path "
            "`/opt/bitops_deployment/`... Exiting.\n"
            "For more information on this issue please checkout our doc "
            "[https://bitovi.github.io/bitops/about/#how-bitops-works]"
        )
        sys.exit(1)
    copy_tree(bitops_deployment_dir, temp_dir)

    if bitops_deployment_configuration is None:
        logger.error(f"No deployments config found. Exiting... {__file__}")
        sys.exit(1)

    logger.info(
        f"\n\n\n~#~#~#~BITOPS DEPLOYMENT CONFIGURATION~#~#~#~            \
            \n\t TEMP_DIR:                [{temp_dir}]                          \
            \n\t DEFAULT_FOLDER_NAME:     [{BITOPS_default_folder}]               \
            \n\t BITOPS_ENVIRONMENT:      [{BITOPS_ENV_environment}]               \
            \n\t TIMEOUT:                 [{BITOPS_timeout}]                           \
            \n                                                                  \
            \n\t BITOPS_DIR:              [{bitops_dir}]                        \
            \n\t BITOPS_DEPLOYMENT_DIR:   [{bitops_deployment_dir}]             \
            \n\t BITOPS_PLUGIN_DIR:       [{bitops_plugins_dir}]                 \
            \n\t BITOPS_ENVROOT_DIR:      [{bitops_envroot_dir}]                \
            \n\t BITOPS_OPERATIONS_DIR:   [{bitops_operations_dir}]             \
            \n\t BITOPS_SCRIPTS_DIR:      [{bitops_scripts_dir}]                \
            \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~# \n                        \
            "
    )
    # Loop through deployments and invoke each
    # ~#~#~#~#~#~# STAGE 2 - PLUGIN LOADING #~#~#~#~#~#~#
    for deployment in bitops_deployment_configuration:
        logger.info(f"\n\n\n~#~#~#~PROCESSING STAGE [{deployment.upper()}]~#~#~#~\n")
        plugin_name = bitops_deployment_configuration[deployment].plugin

        # Set plugin vars
        plugin_dir = (
            BITOPS_installed_plugins_dir + plugin_name
        )  # Sourced from BitOps Core + plugin install
        opsrepo_environment_dir = (
            bitops_operations_dir + "/" + deployment
        )  # Sourced from Operations repo
        os.environ["BITOPS_PLUGIN_DIR"] = plugin_dir
        os.environ["BITOPS_OPSREPO_ENVIRONMENT_DIR"] = opsrepo_environment_dir

        if not os.path.isdir(opsrepo_environment_dir):
            msg, _ = get_doc("missing_ops_repo")
            logger.warning(f"{msg} [{opsrepo_environment_dir}]")
            continue

        # Reconcile BitOps config using existing shell scripts
        opsrepo_env_file = opsrepo_environment_dir + "/" + "ENV_FILE"
        os.environ["BITOPS_OPSREPO_ENV_FILE"] = opsrepo_env_file

        opsrepo_config_file = opsrepo_environment_dir + "/" + "bitops.config.yaml"
        plugin_schema_file = plugin_dir + "/bitops.schema.yaml"

        logger.info(
            f"\n\n\n~#~#~#~{deployment.upper()} DEPLOYMENT CONFIGURATION~#~#~#~  \
        \n\t PLUGIN_DIR:            [{plugin_dir}]                      \
        \n\t ENVIRONMENT_DIR:       [{opsrepo_environment_dir}]         \
        \n\t ENVIRONMENT_FILE_PATH: [{opsrepo_env_file}]                \
        \n\t CONFIG_FILE_PATH:      [{opsrepo_config_file}]        \
        \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~# \n"
        )
        logger.info(f"loading config file: [{opsrepo_config_file}]")
        logger.debug(f"loading ENV_FILE   : [{opsrepo_env_file}]")

        # logic related to plugin.config.yaml
        plugin_configuration_path = plugin_dir + "/plugin.config.yaml"
        try:
            with open(plugin_configuration_path, "r", encoding="utf8") as stream:
                plugin_configuration_yaml = yaml.load(stream, Loader=yaml.FullLoader)

        except FileNotFoundError as e:
            msg, _ = get_doc("missing_optional_file")
            logger.warning(f"{msg} [{plugin_configuration_path}]")
            logger.debug(e)
            plugin_configuration_yaml = {"plugin": {"deployment": {}}}

        # plugin.config.yaml
        plugin_configuration = (
            None
            if plugin_configuration_yaml is None
            else DefaultMunch.fromDict(plugin_configuration_yaml, None)
        )

        # plugin.deployment.deployment_script
        plugin_deploy_script = (
            plugin_configuration.plugin.deployment.deployment_script
            if plugin_configuration.plugin.deployment.deployment_script is not None
            else "deploy.sh"
        )

        # plugin.deployment.language
        plugin_deploy_language = (
            plugin_configuration.plugin.deployment.language
            if plugin_configuration.plugin.deployment.language is not None
            else "bash"
        )

        plugin_deploy_script_path = plugin_dir + f"/{plugin_deploy_script}"

        # plugin.deployment.schema_parsing
        plugin_deploy_schema_parsing_flag = (
            plugin_configuration.plugin.deployment.core_schema_parsing
            if plugin_configuration.plugin.deployment.core_schema_parsing is not None
            else "true"
        )

        # plugin.deployment.before_hook_scripts
        plugin_deploy_before_hook_scripts_flag = (
            plugin_configuration.plugin.deployment.before_hook_scripts
            if plugin_configuration.plugin.deployment.before_hook_scripts is not None
            else "true"
        )

        # plugin.deployment.after_hook_scripts
        plugin_deploy_after_hook_scripts_flag = (
            plugin_configuration.plugin.deployment.after_hook_scripts
            if plugin_configuration.plugin.deployment.after_hook_scripts is not None
            else "true"
        )

        # Check if deploy script is present
        if not os.path.isfile(plugin_deploy_script_path):
            logger.error(f"Plugin deploy script missing. Exiting[{plugin_deploy_script_path}]")
            sys.exit(1)

        if plugin_deploy_schema_parsing_flag:
            logger.debug("running bitops schema parsing...")
            cli_config_list, _ = get_config_list(opsrepo_config_file, plugin_schema_file)

            stack_action = ""
            for item in cli_config_list:
                if item.name == "stack-action":
                    stack_action = item.value
                    break
        else:
            logger.warning("setting null value for stack_action....")
            stack_action = ""

        # Ensure execute bit is present on deploy script
        st = os.stat(plugin_deploy_script_path)
        os.chmod(plugin_deploy_script_path, st.st_mode | stat.S_IEXEC)

        # Adding print env logging
        bitops_env_vars = [item for item in os.environ if "BITOPS_" in item]
        bitops_env_vars.sort()
        env_vars_msg = "\n\n~#~#~#~BITOPS ENVIRONMENT VARIABLES~#~#~#~"
        for item in bitops_env_vars:
            value = os.environ.get(item)
            env_vars_msg += f"\n\t{item}={value}"
        logger.debug(env_vars_msg)

        # ~#~#~#~#~#~# STAGE 3 - BEFORE HOOKS #~#~#~#~#~#~#
        # Summary
        #   The reason the before hooks have been placed here is because I'd like to ensure
        # that the plugin level environment loading has been completed. This will ensure
        # the before hook have access to all the same environment variables as the
        # deployment invoking stage does.

        # Check whether a plugin is using the before hook
        if plugin_deploy_before_hook_scripts_flag:
            hooks_folder = opsrepo_environment_dir + "/bitops.before-deploy.d"
            handle_hooks("before", hooks_folder, opsrepo_environment_dir)
        else:
            logger.warning("BitOps Core isn't invoking before hooks")

        # ~#~#~#~#~#~# STAGE 4 - PLUGIN DEPLOYMENT INVOKE #~#~#~#~#~#~#
        # Add executable flag to deploy.sh
        os.chmod(plugin_deploy_script_path, 775)
        logger.info(
            f"\n\t\tRUNNING DEPLOYMENT SCRIPT    \
                        \n\t\t\tLANGUAGE:       [{plugin_deploy_language}]    \
                        \n\t\t\tSCRIPT PATH:    [{plugin_deploy_script_path}]    \
                        \n\t\t\tSTACK ACTION:   [{stack_action}]"
        )

        result = run_cmd(
            [
                plugin_deploy_language,
                plugin_deploy_script_path,
                stack_action,
            ]
        )
        if result.returncode == 0:
            logger.info(f"\n~#~#~#~DEPLOYING OPS REPO [{deployment}] SUCCESSFULLY COMPLETED~#~#~#~")
        else:
            logger.warning(f"\n~#~#~#~DEPLOYING OPS REPO [{deployment}] FAILED~#~#~#~")

        # ~#~#~#~#~#~# STAGE 5 - AFTER HOOKS #~#~#~#~#~#~#
        if plugin_deploy_after_hook_scripts_flag:
            hooks_folder = opsrepo_environment_dir + "/bitops.after-deploy.d"
            handle_hooks("after", hooks_folder, opsrepo_environment_dir)
        else:
            logger.warning("BitOps Core isn't invoking after hooks")
