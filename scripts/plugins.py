import sys
import os

import plugins.settings
import pyfiglet

from plugins.logging import logger
from plugins.deploy_plugins import Deploy_Plugins
from plugins.install_plugins import Install_Plugins
from plugins.utilities import Get_Config_List

if __name__ == "__main__":
    try:
        mode = sys.argv[1]
    except IndexError:
        mode = None

    bitops_figlet = pyfiglet.figlet_format("BitOps")
    bitops_description = \
    """
    BitOps is a way to describe the infrastructure and things deployed onto that infrastructure for multiple environments in a single place called an Operations Repo.
    """
    logger.info("\n\n{figlet}{description}"
        .format(
            figlet=bitops_figlet,
            description=bitops_description))
    
    logger.info("\n\n\n#~#~#~#~ BITOPS CONFIGURATION ~#~#~#~    \
    \n\tFAIL FAST:              [{fail_fast}]                   \
    \n\tRUN MODE:               [{run_mode}]                    \
    \n\tDEFAULT RUN MODE:       [{mode}]                        \
    \n\tLOGGING LEVEL:          [{log_level}]                   \
    \n\tLOGGING COLOR:          [{log_color}]                   \
    \
    \n\tBITOPS CONFIG FILE:     [{config_file}]                 \
    \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#\n                   \
    ".format(
        fail_fast=plugins.settings.BITOPS_fast_fail_mode, 
        run_mode=plugins.settings.BITOPS_run_mode, 
        mode=mode,
        log_level=plugins.settings.BITOPS_logging_level,
        log_color=plugins.settings.BITOPS_logging_color,
        config_file=plugins.settings.BITOPS_config_file
    ))
    
    if mode == "deploy":
        Deploy_Plugins()
    elif mode == "install":
        Install_Plugins()
    elif mode == "schema_parsing":
        config_file = sys.argv[2]
        schema_file = sys.argv[3]
        Get_Config_List(config_file, schema_file)
    elif mode == "setting-test":
        print("Plugins Load complete. Exiting...")
        exit(0)
    else:
        print("Mode is not specified. Please use [plugins.py install|deploy]")

