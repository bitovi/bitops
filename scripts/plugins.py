import sys
import plugins.settings

from plugins.deploy_plugins import Deploy_Plugins
from plugins.install_plugins import Install_Plugins
from plugins.utilties import Get_Config_List
from plugins.logging import logging


if __name__ == "__main__":
    try:
        mode = sys.argv[1]
    except IndexError:
        mode = None

    if mode == "deploy":
        Deploy_Plugins()
    elif mode == "install":
        Install_Plugins()
    else:
        print("Mode is not specified. Please use [plugins.py install|deploy]")

