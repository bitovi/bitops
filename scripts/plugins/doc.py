# Loads JSON
# Provides a function to access the documentation
import json

fh = open("scripts/plugins/documentation.json")
jh = json.load(fh)


def Get_Doc(lookup_key):
    try:
        msg = (
            f"\n\t{jh[lookup_key]['msg']}\n"
            f"\tFor more information checkout the Bitops Documentation: [{jh[lookup_key]['link']}]"
        )
    except KeyError:
        return """DEVELOPER NOTE: Check lookup code and confirm that it " \
        "is in the documentation config. Something has gone wrong."""
    return msg
