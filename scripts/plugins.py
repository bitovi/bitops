import sys

from plugins.deploy_plugins import deploy_plugins
from plugins.install_plugins import install_plugins

if __name__ == "__main__":
    try:
        mode = sys.argv[1]
    except IndexError:
        mode = None

    if mode == "deploy":
        deploy_plugins()
    if mode == "install":
        install_plugins()
    else:
        print("Mode is not specified. Please use [plugins.py install|deploy]")