# Loads JSON
# Provides a function to access the documentation
from .logging import logger
import json

fh = open("scripts/plugins/documentation.json")
jh = json.load(fh)


def Get_Doc(lookup_key):
    try:
        msg = "\n\t{}".format(jh[lookup_key]["msg"])
        link = jh[lookup_key]["link"]
        exit_code = 0
        if link:
            msg += "\n\tFor more information checkout the Bitops Documentation: [{}]".format(
                link
            )
    except KeyError:
        # Returns 1 by default, exit and report issue at developer level
        return "DEVELOPER NOTE: Check lookup code and confirm that it is in the documentation config. Something has gone wrong.", 1
    
    try:
        exit_code = jh[lookup_key]["exit_code"]
        logger.debug(f"INC STRING: [{exit_code}]")
    except KeyError:
        exit_code=0

    return msg, exit_code
