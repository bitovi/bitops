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
from .settings import BITOPS_config_yaml, BITOPS_fast_fail_mode, BITOPS_config_yaml, bitops_build_configuration, BITOPS_ENV_environment, BITOPS_default_folder, BITOPS_timeout
from .logging import logger
from munch import DefaultMunch


def Deploy_Plugins():
    # Temp directory setup
    temp_dir = tempfile.mkdtemp()

    bitops_plugins_configuration = DefaultMunch.fromDict(bitops_build_configuration.bitops.plugins, None)
    bitops_deployment_configuration = DefaultMunch.fromDict(bitops_build_configuration.bitops.deployments, None)

    bitops_dir = "/opt/bitops"
    bitops_deployment_dir = "/opt/bitops_deployment/"
    bitops_plugins_dir = bitops_dir + '/scripts/plugins/'

    bitops_root_dir = temp_dir

    bitops_envroot_dir = "{}/{}".format(bitops_root_dir, BITOPS_ENV_environment) # What is the difference between this and bitops_operations_dir ...
    bitops_default_envroot = "{}/{}".format(bitops_root_dir, BITOPS_default_folder)
    bitops_operations_dir = "{}/{}".format(temp_dir, BITOPS_ENV_environment)
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
    if BITOPS_ENV_environment is None:
        logger.error("ENVIRONMENT variables must be set... Exiting")
        quit()
    
    # Move to temp directory
    copy_tree(bitops_deployment_dir, temp_dir)


    if bitops_deployment_configuration is None:
        logger.error("No deployment sequence found. Follwoing default deployment sequence {}".format(__file__))
        if bitops_plugins_configuration is None:
            logger.error("No plugins found. Exiting {}".format(__file__))
            quit()
        
        logger.info("\n\n\n~#~#~#~BITOPS DEPLOYMENT CONFIGURATION~#~#~#~    \
                \n\t TEMP_DIR:              [{temp_dir}]                    \
                \n\t DEFAULT_FOLDER_NAME:   [{default_folder_name}]         \
                \n\t ENVIRONMENT:           [{env}]                         \
                \n\t TIMEOUT:               [{timeout}]                     \
                \n                                                          \
                \n\t BITOPS_DIR:            [{bitops_dir}]                  \
                \n\t BITOPS_DEPLOYMENT_DIR: [{bitops_deployment_dir}]       \
                \n\t BITOPS_PLUGIN_DIR:     [{bitops_plugin_dir}]           \
                \n\t BITOPS_ENVROOT_DIR:    [{bitops_envroot_dir}]          \
                \n\t BITOPS_OPERATIONS_DIR: [{bitops_operations_dir}]       \
                \n\t BITOPS_SCRIPTS_DIR:    [{bitops_scripts_dir}]          \
                \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~# \n                \
                ".format(                                                       
                    temp_dir=temp_dir,
                    default_folder_name=BITOPS_default_folder,
                    env=BITOPS_ENV_environment,
                    timeout=BITOPS_timeout,
                    
                    bitops_dir=bitops_dir,
                    bitops_deployment_dir=bitops_deployment_dir,
                    bitops_plugin_dir=bitops_plugins_dir,
                    bitops_envroot_dir=bitops_envroot_dir,
                    bitops_operations_dir=bitops_operations_dir,
                    bitops_scripts_dir=bitops_scripts_dir,
                ))
        # Loop through plugins and invoke each
        for plugin in bitops_plugins_configuration:
            logger.info("\n\n\n~#~#~#~PROCESSING STAGE [{}]~#~#~#~\n".format(plugin.upper()))
            plugin_name = plugin
            # Set plugin vars
            plugin_dir = bitops_plugins_dir + plugin_name                           # Sourced from BitOps Core + plugin install
            plugin_environment_dir = bitops_operations_dir + '/' + plugin_name      # Sourced from Operations repo
            os.environ['PLUGIN_DIR'] = plugin_dir
            os.environ['PLUGIN_ENVIRONMENT_DIR'] = plugin_environment_dir
            
            if os.path.isdir(plugin_environment_dir):
                # Reconcile BitOps config using existing shell scripts
                plugin_env_file = plugin_dir + '/' + 'ENV_FILE'
                os.environ['PLUGIN_ENV_FILE'] = plugin_env_file

                plugin_config_file = plugin_environment_dir + '/' + 'bitops.config.yaml'
                plugin_schema_file = plugin_dir+"/bitops.schema.yaml" 
                
                logger.info("\n\n\n~#~#~#~{plugin} PLUGIN CONFIGURATION~#~#~#~  \
                \n\t PLUGIN_DIR:            [{plugin_dir}]                      \
                \n\t ENVIRONMENT_DIR:       [{plugin_env_dir}]                  \
                \n\t ENVIRONMENT_FILE_PATH: [{plugin_env_file}]                 \
                \n\t CONFIG_FILE_PATH:      [{plugin_config_file_path}]         \
                \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~# \n                    \
                ".format(                                                       
                    plugin=plugin.upper(),                                      
                    plugin_dir=plugin_dir,
                    plugin_env_dir=plugin_environment_dir,
                    plugin_env_file=plugin_env_file,
                    plugin_config_file_path=plugin_config_file,
                ))
                logger.info("loading config file: [{}]".format(plugin_config_file))
                logger.debug("loading ENV_FILE   : [{}]".format(plugin_env_file))
                            
                
                cli_config_list, options_config_list = Get_Config_List(plugin_config_file, plugin_schema_file)
                # THIS NEEDS TO SEND IN THE plugin.schema.yaml from the plugin folder
                # WHICH WILL BE COMPARED TO THE PROVIDED plugin.config.yaml that will be pulled from the ops-repo

                # Set CLI_OTIONS
                # os.environ['CLI_OPTIONS'] = cli_options.stdout

                # Source envfile
                #envbash.load_envbash(os.environ['ENV_FILE'])

                # Check if install script is present
                plugin_deploy_script = bitops_plugins_configuration[plugin].install_script  if bitops_plugins_configuration[plugin].install_script else "install.sh"
                plugin_deploy_language = "bash" if plugin_deploy_script[-2:] == "sh" else "python3"
                plugin_deploy_script_path = plugin_dir + '/deploy.sh'

                # Invoke Plugin
                
                # Wait for processes to complete.
                # if plugin_name == 'terraform' or plugin_name == 'helm' or plugin_name == 'ansible' or plugin_name == 'cloudformation':
                #     result = subprocess.Popen(plugin_dir + '/deploy.sh', universal_newlines = True)
                #     result.wait(timeout = 600)
                #     logger.info("Result from command....")
                #     logger.info(result.stdout)
                # else:

                logger.warning("LOOK HERE")
                logger.warning(cli_config_list)
                stack_action=""
                for item in cli_config_list:
                    if item.name == "stack-action": 
                        stack_action = item.value
                        break
                logger.warning(stack_action)
                

                # Add executable flag to deploy.sh
                os.chmod(plugin_deploy_script_path, 775)
                logger.info("\n\t\tRUNNING DEPLOYMENT SCRIPT    \
                                \n\t\t\tLANGUAGE:       [{}]    \
                                \n\t\t\tSCRIPT PATH:    [{}]    \
                                \n\t\t\tSTACK ACTION:   [{}]".format(plugin_deploy_language, plugin_deploy_script_path, stack_action))
                
                try:
                    result = subprocess.run([plugin_deploy_language, plugin_deploy_script_path, stack_action], 
                        universal_newlines = True,
                        capture_output=True)
                
                except Exception as exc:
                    logger.error(exc)
                    if BITOPS_fast_fail_mode: quit(101)
                    
                if result.returncode == 0:
                    logger.info("\n~#~#~#~DEPLOYING PLUGIN [{plugin}] SUCCESSFULLY COMPLETED~#~#~#~".format(plugin=plugin))
                    logger.debug("\n\tSTDOUT:[{stdout}]\n\tSTDERR: [{stderr}]\n\tRESULTS: [{result}]".format(stdout=result.stdout, stderr=result.stderr, result=result))
                else:
                    logger.warning("\n~#~#~#~DEPLOYING PLUGIN [{plugin}] FAILED~#~#~#~".format(plugin=plugin))
                    logger.debug("\n\tSTDOUT:[{stdout}]\n\tSTDERR: [{stderr}]\n\tRESULTS: [{result}]".format(stdout=result.stdout, stderr=result.stderr, result=result))

                # After hooks
                # result = subprocess.run(['bash', bitops_dir + '/deploy/after-deploy.sh', plugin_environment_dir], 
                # universal_newlines = True,
                # capture_output=True)
            else:
                logger.info("Plugin environment directory does not exist: [{}]".format(plugin_environment_dir))    
    else:
        logger.info("Add deployment sequence logic here")