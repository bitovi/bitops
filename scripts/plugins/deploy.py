import yaml
import os
import subprocess
import envbash
from shutil import rmtree

# Load plugin.config.yaml
bitops_dir=os.environ['BITOPS_DIR']
with open(bitops_dir+'/plugin.config.yaml', 'r') as stream:
    try:
        plugins_yml = yaml.load(stream, Loader=yaml.FullLoader)
    except yaml.YAMLError as exc:
        print(exc)

plugins_dir = bitops_dir + '/scripts/plugins/'
operations_dir = os.environ['ENVROOT']
timeout = 600
if 'TIMEOUT' in os.environ.keys():
    timeout = os.environ['TIMEOUT']

print("TIMEOUT: ", timeout)
plugin_dir = "/opt/bitops/scripts/plugins/"
plugins = plugins_yml.get("plugins")
if plugins is None:
    quit()

# Loop through plugins and invoke each
for plugin in plugins:
    plugin_name = plugin['name']

    # Set ENV vars
    plugin_dir = plugins_dir + plugin_name
    os.environ['PLUGIN_DIR'] = plugin_dir
    environment_dir = operations_dir + '/' + plugin_name
    os.environ['ENVIRONMENT_DIR'] = environment_dir

    # Before Hooks
    result = subprocess.run(['bash', bitops_dir + '/deploy/before-deploy.sh', environment_dir], 
        universal_newlines = True,
        capture_output=True)
    print(result.stdout)

    # try:
    #     rmtree(plugin_dir + plugin['name'])
    # except:
    #     print("All clean. Cloning...")
    # # cloning repo
    # result = subprocess.run(['git', 'clone', plugin['source'], plugin_dir],
    #   universal_newlines = True,
    #   capture_output=True)
    # print("Result:", result)

    # Reconcile BitOps config using existing shell scripts
    print('Loading BitOps Config for ' + plugin_name)
    os.environ['ENV_FILE'] = plugin_dir + '/' + 'ENV_FILE'
    bitops_schema = plugin_dir + '/' + 'bitops.schema.yaml'
    bitops_config = environment_dir + '/' + 'bitops.config.yaml'
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

    # Invoke Plugin
    print('Calling ' + plugin_dir + '/deploy.sh')
    # Wait for processes to complete.
    if plugin_name == 'terraform' or plugin_name == 'helm':
        result = subprocess.Popen(plugin_dir + '/deploy.sh', universal_newlines = True)
        result.wait(timeout = 600)
        print("Result from command....")
        print(result.stdout)
    else:
        result = subprocess.run(['bash', plugin_dir + '/deploy.sh'], 
            universal_newlines = True,
            capture_output=True)

    # Invoke plugin install script
    result = subprocess.run(['bash', plugin_dir + '/install.sh'],
        universal_newlines = True,
        capture_output=True)
    print(result.stdout)

    # After hooks
    result = subprocess.run(['bash', bitops_dir + '/deploy/after-deploy.sh', environment_dir], 
        universal_newlines = True,
        capture_output=True)
    print(result.stdout)




