import sys
import pyfiglet

import plugins.settings

from plugins.logging import logger
from plugins.deploy_plugins import deploy_plugins
from plugins.install_plugins import install_plugins
from plugins.config.parser import parse_configuration


if __name__ == "__main__":
    try:
        RUN_MODE = sys.argv[1]
    except IndexError:
        RUN_MODE = None

    bitops_figlet = pyfiglet.figlet_format("BitOps")
    BITOPS_DESCRIPTION = """
    BitOps is a way to describe the infrastructure and things deployed onto that infrastructure for multiple environments in a single place called an Operations Repo.
    """
    logger.info(f"\n\n{bitops_figlet}{BITOPS_DESCRIPTION}")

    logger.info(
        f"\n\n\n#~#~#~#~ BITOPS CONFIGURATION ~#~#~#~    \
    \n\tFAIL FAST:              [{plugins.settings.BITOPS_fast_fail_mode}]                   \
    \n\tRUN MODE:               [{plugins.settings.BITOPS_run_mode}]                    \
    \n\tDEFAULT RUN MODE:       [{RUN_MODE}]                        \
    \n\tLOGGING LEVEL:          [{plugins.settings.BITOPS_logging_level}]                   \
    \n\tLOGGING COLOR:          [{plugins.settings.BITOPS_logging_color}]                   \
    \
    \n\tBITOPS CONFIG FILE:     [{plugins.settings.BITOPS_config_file}]                 \
    \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#\n"
    )

    if RUN_MODE == "deploy":
        deploy_plugins()
    elif RUN_MODE == "install":
        install_plugins()
    elif RUN_MODE == "schema_parsing":
        config_file = sys.argv[2]
        schema_file = sys.argv[3]
        parse_configuration(config_file, schema_file)
    elif RUN_MODE == "setting-test":
        print("Plugins Load complete. Exiting...")
        sys.exit(0)
    else:
        print("Mode is not specified. Please use [main.py install|deploy]")

    print("BitOps has finished!")
