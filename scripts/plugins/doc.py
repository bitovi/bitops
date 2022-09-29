import json


def get_doc(lookup_key):
    """Function to access the documented error message by its code"""
    msg = None
    with open("scripts/plugins/documentation.json", encoding="utf8") as fp:
        doc = json.load(fp)

    try:
        msg = (
            f"\n\t{doc[lookup_key]['msg']}\n"
            f"\tFor more information checkout the Bitops Documentation: [{doc[lookup_key]['link']}]"
        )
    except KeyError:
        return """DEVELOPER NOTE: Check lookup code and confirm that it " \
        "is in the documentation config. Something has gone wrong."""

    return msg
