import sys
import os

import plugins.settings

from plugins.logging import logger
from plugins.deploy_plugins import Deploy_Plugins
from plugins.install_plugins import Install_Plugins

if __name__ == "__main__":
    try:
        mode = sys.argv[1]
    except IndexError:
        mode = None
    
    logger.info("\n\n\n~#~#~#~ BITOPS CONFIGURATION ~#~#~#~\
    \n\tFAIL FAST: [{fail_fast}]\
    \n\tRUN MODE: [{run_mode}]\
    \n\tLOGGING LEVEL: [{log_level}]\
    \n\tBITOPS SOURCE: [{github_source}]\
    \n\n\n\
    ".format(\
        fail_fast=plugins.settings.BITOPS_fast_fail_mode, \
        run_mode=plugins.settings.BITOPS_run_mode, \
        log_level=plugins.settings.BITOPS_logging_level,\
        github_source=plugins.settings.BITOPS_opsrepo_source\
    ))

    if mode == "deploy":
        Deploy_Plugins()
    elif mode == "install":
        Install_Plugins()
    else:
        print("Mode is not specified. Please use [plugins.py install|deploy]")

