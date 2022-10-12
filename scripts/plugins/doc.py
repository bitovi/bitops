# Loads JSON
# Provides a function to access the documentation
import json

fh = open("scripts/plugins/documentation.json")
jh = json.load(fh)


def Get_Doc(lookup_key):
    try:
        msg = "\n\t{}".format(jh[lookup_key]["msg"])
        link = jh[lookup_key]["link"]
        if link:
            msg += "\n\tFor more information checkout the Bitops Documentation: [{}]".format(
                link
            )
        return_number = jh[lookup_key]["number"]

    except KeyError:
        return "DEVELOPER NOTE: Check lookup code and confirm that it is in the documentation config. Something has gone wrong."
    return msg, return_number
