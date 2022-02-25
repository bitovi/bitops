import sys
import os

from plugins.settings import BITOPS_logging_level
from plugins.logging import logger
from plugins.deploy_plugins import Deploy_Plugins
from plugins.install_plugins import Install_Plugins
from plugins.utilties import Get_Config_List

if __name__ == "__main__":
    try:
        mode = sys.argv[1]
    except IndexError:
        mode = None

    logger.debug(os.environ)

    if mode == "deploy":
        Deploy_Plugins()
    elif mode == "install":
        Install_Plugins()
    else:
        print("Mode is not specified. Please use [plugins.py install|deploy]")

