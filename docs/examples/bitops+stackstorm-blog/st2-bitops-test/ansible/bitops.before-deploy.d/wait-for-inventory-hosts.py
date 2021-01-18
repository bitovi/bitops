import yaml
import subprocess

port = "22"
timeout = "60"

try:
    with open("../terraform/inventory.yaml",'r') as file:
        try:
            print("Running wait for host script:")
            inventory = yaml.safe_load(file)
            bitops_hosts = inventory["bitops_servers"]["hosts"]
            if isinstance(bitops_hosts, str):
                print("Waiting for host:", bitops_hosts)
            else:
                bitops_hosts = bitops_hosts[0]
                print("Waiting for host:", bitops_hosts)      
            wait_for_command = "./bitops.before-deploy.d/scripts/wait-for-it.sh -h {} -p {} -t {}".format(bitops_hosts,port,timeout)
            result = subprocess.call(wait_for_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        except yaml.YAMLError as exception:
            print(exception)
except IOError:
    print("Terraform inventory file not found. Skipping wait for hosts.")    