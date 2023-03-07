import sys
import pyfiglet

import plugins.settings

from plugins.logging import logger
from plugins.deploy_plugins import deploy_plugins
from plugins.install_plugins import install_plugins
from plugins.utilities import get_config_list


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
    \n\tBITOPS RUN MODE:        [{plugins.settings.BITOPS_run_mode}]                    \
    \n\tPYTHON RUN MODE:        [{RUN_MODE}]                        \
    \n\tLOGGING LEVEL:          [{plugins.settings.BITOPS_logging_level}]                   \
    \n\tLOGGING COLOR:          [{plugins.settings.BITOPS_LOGGING_COLOR}]                   \
    \
    \n\tBITOPS CONFIG FILE:     [{plugins.settings.BITOPS_config_file}]                 \
    \n#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#\n"
    )

    if plugins.settings.BITOPS_run_mode == "settings_test":
        # Prints all variables from the settings.py file after it's loaded.
        print("Plugins Load complete. Exiting...")
        print(
            {
                item: getattr(plugins.settings, item)
                for item in dir(plugins.settings)
                if not item.startswith("__") and not item.endswith("__")
            }
        )
        sys.exit(0)

    if RUN_MODE == "deploy":
        deploy_plugins()
    elif RUN_MODE == "install":
        install_plugins()
    else:
        print("Mode is not specified. Please use [main.py install|deploy]")

    print("BitOps has finished!")
