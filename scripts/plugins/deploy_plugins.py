import os
import subprocess
import yaml
import envbash
import tempfile


from pickle import GLOBAL
from shutil import rmtree
from distutils.dir_util import copy_tree
from .utilties import Load_Build_Config
from munch import DefaultMunch


def deploy_plugins():
    # Temp directory setup
    print("Creating temporary directory")
    temp_dir = tempfile.mkdtemp()
    print("temporary directory created: [{}]".format(temp_dir))

    # Locals singles in this area
    bitops_mode = os.environ.get("BITOPS_MODE", None)
    bitops_default_folder_name = os.environ.get("DEFAULT_FOLDER_NAME", "default")
    bitops_environment = os.environ.get("ENVIRONMENT", None)
    timeout = os.environ.get("TIMEOUT", 600)

    plugins_yml = Load_Build_Config()
    bitops_build_configuration = DefaultMunch.fromDict(plugins_yml, "bitops")
    bitops_plugins_configuration = DefaultMunch.fromDict(bitops_build_configuration.bitops.plugins.tools, None)
    
    bitops_dir = "/opt/bitops"
    bitops_deployment_dir = "/opt/bitops_deployment/"
    bitops_plugins_dir = bitops_dir + '/scripts/plugins/'

    bitops_root_dir = temp_dir

    bitops_envroot_dir = "{}/{}".format(bitops_root_dir, bitops_environment) # What is the difference between this and bitops_operations_dir ...
    bitops_default_envroot = "{}/{}".format(bitops_root_dir, bitops_default_folder_name)
    bitops_operations_dir = "{}/{}".format(temp_dir, bitops_environment)
    bitops_scripts_dir = "{}/scripts".format(bitops_dir)



    # Cleanup - Call all teardown scripts - TODO


    # Set global variables
    os.environ["TEMPDIR"] = temp_dir
    os.environ["ENVROOT"] = bitops_operations_dir
    os.environ["BITOPS_DIR"] = bitops_dir
    os.environ["SCRIPTS_DIR"] = bitops_scripts_dir
    os.environ["PLUGINS_DIR"] = bitops_plugins_dir

    os.environ["KUBE_CONFIG_FILE"] = "{}/.kube/config".format(temp_dir)
    os.environ["PATH"] = "/root/.local/bin:$PATH"

    # Global environment evaluation
    if bitops_environment is None:
        print("ENVIRONMENT variables must be set... Exiting")
        quit()

    # Move to temp directory
    copy_tree(bitops_deployment_dir, temp_dir)

    # print("TIMEOUT: ", timeout) # TODO: What is this?
    if bitops_plugins_configuration is None:
        print("No plugins found. Exiting {}".format(__file__))
        quit()

    # Loop through plugins and invoke each
    for plugin in bitops_plugins_configuration:
        plugin_name = plugin

        # Set ENV vars
        plugin_dir = bitops_plugins_dir + plugin_name
        # temp/env/plugin_name
        plugin_environment_dir = bitops_operations_dir + '/' + plugin_name
        
        os.environ['PLUGIN_DIR'] = plugin_dir
        os.environ['ENVIRONMENT_DIR'] = plugin_environment_dir

        # Before Hooks - START HERE TOMORROW (WTF is this?)
        # result = subprocess.run(['bash', bitops_dir + '/deploy/before-deploy.sh', environment_dir], 
        #     universal_newlines = True,
        #     capture_output=True)
        # print(result.stdout)




        # Reconcile BitOps config using existing shell scripts
        print('Loading BitOps Config for plugin: [{}]'.format(plugin_name))
        os.environ['ENV_FILE'] = plugin_dir + '/' + 'ENV_FILE'
        bitops_schema = plugin_dir + '/' + 'bitops.schema.yaml'
        bitops_config = plugin_environment_dir + '/' + 'bitops.config.yaml'
        old_debug = os.environ['DEBUG'] 
        os.environ['DEBUG'] = ''
        cli_options = subprocess.run(['bash',os.environ['SCRIPTS_DIR']+'/bitops-config/convert-schema.sh', bitops_schema, bitops_config], 
            universal_newlines = True,
            capture_output=True)
        os.environ['DEBUG'] = old_debug

        # Set CLI_OTIONS
        os.environ['CLI_OPTIONS'] = cli_options.stdout

        # Source envfile
        #envbash.load_envbash(os.environ['ENV_FILE'])

        # Check if install script is present
        plugin_install_script = bitops_plugins_configuration[plugin].install_script  if bitops_plugins_configuration[plugin].install_script else "install.sh"
        plugin_install_language = "bash" if plugin_install_script[-2:] == "sh" else "python3"

        # Invoke Plugin
        print('Calling ' + plugin_dir + '/deploy.sh')
        # Wait for processes to complete.
        # if plugin_name == 'terraform' or plugin_name == 'helm' or plugin_name == 'ansible' or plugin_name == 'cloudformation':
        #     result = subprocess.Popen(plugin_dir + '/deploy.sh', universal_newlines = True)
        #     result.wait(timeout = 600)
        #     print("Result from command....")
        #     print(result.stdout)
        # else:
        result = subprocess.run([plugin_install_language, plugin_dir + '/deploy.sh'], 
            universal_newlines = True,
            capture_output=True)

        # After hooks
        result = subprocess.run(['bash', bitops_dir + '/deploy/after-deploy.sh', plugin_environment_dir], 
            universal_newlines = True,
            capture_output=True)
        print(result.stdout)