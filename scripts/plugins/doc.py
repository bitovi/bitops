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
        return_number = 0
        if link:
            msg += "\n\tFor more information checkout the Bitops Documentation: [{}]".format(
                link
            )
    except KeyError:
        # Returns 1 by default, exit and report issue at developer level
        return "DEVELOPER NOTE: Check lookup code and confirm that it is in the documentation config. Something has gone wrong.", 1
    
    try:
        return_number = jh[lookup_key]["number"]
        logger.debug(f"INC STRING: [{return_number}]")
        if return_number: return_number = return_number
    except KeyError:
        return_number=0

    return msg, return_number
