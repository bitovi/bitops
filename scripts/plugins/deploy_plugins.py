import os
import subprocess
import yaml
import envbash
import tempfile
import git

from pickle import GLOBAL
from shutil import rmtree
from distutils.dir_util import copy_tree
from .utilities import Get_Config_List
from .settings import BITOPS_config_yaml, BITOPS_fast_fail_mode, BITOPS_config_yaml, BITOPS_opsrepo_source
from .logging import logger
from munch import DefaultMunch


def Deploy_Plugins():
    # Temp directory setup
    logger.info("Creating temporary directory")
    temp_dir = tempfile.mkdtemp()
    logger.info("temporary directory created: [{}]".format(temp_dir))

    # Locals singles in this area
    bitops_mode = os.environ.get("BITOPS_MODE", None)
    bitops_default_folder_name = os.environ.get("DEFAULT_FOLDER_NAME", "default")
    bitops_environment = os.environ.get("ENVIRONMENT", None)
    timeout = os.environ.get("TIMEOUT", 600)
    bitops_debug = os.environ.get("DEBUG", None)

    bitops_build_configuration = DefaultMunch.fromDict(BITOPS_config_yaml, "bitops")
    bitops_plugins_configuration = DefaultMunch.fromDict(bitops_build_configuration.bitops.plugins.tools, None)

    BITOPS_fast_fail_mode = DefaultMunch.fromDict(bitops_build_configuration.bitops.fail_fast, False)

    bitops_dir = "/opt/bitops"
    bitops_deployment_dir = "/opt/bitops_deployment/"
    bitops_plugins_dir = bitops_dir + '/scripts/plugins/'

    bitops_root_dir = temp_dir

    bitops_envroot_dir = "{}/{}".format(bitops_root_dir, bitops_environment) # What is the difference between this and bitops_operations_dir ...
    bitops_default_envroot = "{}/{}".format(bitops_root_dir, bitops_default_folder_name)
    bitops_operations_dir = "{}/{}".format(temp_dir, bitops_environment)
    bitops_scripts_dir = "{}/scripts".format(bitops_dir)

    PATH = os.environ.get("PATH")
    PATH += ":/root/.local/bin"


    # Cleanup - Call all teardown scripts - TODO


    # Set global variables
    os.environ["TEMPDIR"] = temp_dir
    os.environ["ENVROOT"] = bitops_operations_dir
    os.environ["BITOPS_DIR"] = bitops_dir
    os.environ["SCRIPTS_DIR"] = bitops_scripts_dir
    os.environ["PLUGINS_DIR"] = bitops_plugins_dir
    os.environ["BITOPS_FAIL_FAST"] = str(BITOPS_fast_fail_mode)
    os.environ["KUBE_CONFIG_FILE"] = "{}/.kube/config".format(temp_dir)
    os.environ["PATH"] = PATH

    # Global environment evaluation
    if bitops_environment is None:
        logger.error("ENVIRONMENT variables must be set... Exiting")
        quit()

    # If a OpsRepo is specified, clone it to the bitops_deployment_dir
    if BITOPS_opsrepo_source != "local":
        logger.info("Downloading OpsRepo from: [{}]".format(BITOPS_opsrepo_source))
        git.Repo.clone_from(BITOPS_opsrepo_source, bitops_deployment_dir)
    logger.info("OpsRepo sourced from: [{}]".format(BITOPS_opsrepo_source))
    
    # Move to temp directory
    copy_tree(bitops_deployment_dir, temp_dir)

    # logger.info("TIMEOUT: ", timeout) # TODO: What is this?
    if bitops_plugins_configuration is None:
        logger.error("No plugins found. Exiting {}".format(__file__))
        quit()

    logger.info("\n\n\n~#~#~#~ DEPLOYING PLUGINS ~#~#~#~")

    # Loop through plugins and invoke each
    for plugin_config in bitops_plugins_configuration:
        logger.info("\n\t\tPreparing plugin_config: [{}]".format(plugin_config))
        for plugin in bitops_plugins_configuration[plugin_config]:
            plugin_name = plugin
            logger.info("\n\t\t\tPreparing plugin: [{}]".format(plugin_name))

            # Set plugin vars
            plugin_dir = bitops_plugins_dir + plugin_name
            plugin_environment_dir = bitops_operations_dir + '/' + plugin_name
            
            os.environ['PLUGIN_DIR'] = plugin_dir
            os.environ['ENVIRONMENT_DIR'] = plugin_environment_dir

            # Before Hooks
            # result = subprocess.run(['bash', bitops_dir + '/deploy/before-deploy.sh', environment_dir], 
            #     universal_newlines = True,
            #     capture_output=True)
            # logger.info(result.stdout)


            # Reconcile BitOps config using existing shell scripts
            logger.info('Loading BitOps Config for plugin: [{}]'.format(plugin_name))
            plugin_env_file = plugin_dir + '/' + 'ENV_FILE'
            os.environ['ENV_FILE'] = plugin_env_file

            plugin_schema_file = plugin_dir + '/' + 'bitops.schema.yaml'
            plugin_config_file = plugin_environment_dir + '/' + 'bitops.config.yaml'
            
            # os.environ['DEBUG'] = ''
            logger.info("Loading schema file: [{}]".format(plugin_schema_file))
            logger.info("loading config file: [{}]".format(plugin_config_file))
            logger.debug("loading ENV_FILE   : [{}]".format(plugin_env_file)) # Something seems wrong with this. 
                        
            cli_config_list, options_config_list = Get_Config_List(plugin_schema_file, plugin_config_file)
            logger.info("DONE")

            # Set CLI_OTIONS
            # os.environ['CLI_OPTIONS'] = cli_options.stdout


            # Source envfile
            #envbash.load_envbash(os.environ['ENV_FILE'])

            # Check if install script is present
            plugin_install_script = bitops_plugins_configuration[plugin_config][plugin].install_script  if bitops_plugins_configuration[plugin_config][plugin].install_script else "install.sh"
            plugin_install_language = "bash" if plugin_install_script[-2:] == "sh" else "python3"
            plugin_install_script_path = plugin_dir + '/deploy.sh'

            # Invoke Plugin
            logger.info('Calling {}'.format(plugin_install_script_path))
            # Wait for processes to complete.
            # if plugin_name == 'terraform' or plugin_name == 'helm' or plugin_name == 'ansible' or plugin_name == 'cloudformation':
            #     result = subprocess.Popen(plugin_dir + '/deploy.sh', universal_newlines = True)
            #     result.wait(timeout = 600)
            #     logger.info("Result from command....")
            #     logger.info(result.stdout)
            # else:

            # result = subprocess.run([plugin_install_language, plugin_dir + '/deploy.sh'], 
            
            # Add executable flag to deploy.sh
            os.chmod(plugin_install_script_path, 775)
            try:
                result = subprocess.run([plugin_install_script_path], 
                    universal_newlines = True,
                    capture_output=True)
            
            except Exception as exc:
                logger.error(exc)
                if BITOPS_fast_fail_mode: quit(101)
                
            # After hooks
            # result = subprocess.run(['bash', bitops_dir + '/deploy/after-deploy.sh', plugin_environment_dir], 
            # universal_newlines = True,
            # capture_output=True)
            logger.critical(result)