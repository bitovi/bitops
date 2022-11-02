import json
from typing import Tuple


def get_doc(lookup_key: str) -> Tuple[str, int]:
    """Function to access the documented error message by its code"""
    msg = None
    # lazy-load documentation.json only once
    if not hasattr(get_doc, "dict"):
        with open("scripts/plugins/documentation.json", encoding="utf8") as fp:
            get_doc.dict = json.load(fp)

    try:
        msg = f"\n\t{get_doc.dict[lookup_key]['msg']}\n"
        link = get_doc.dict[lookup_key]["link"]
        if link:
            msg += "\n\tFor more information checkout the Bitops Documentation: [{link}]"
    except KeyError:
        # Returns 1 by default, exit and report issue at developer level
        return (
            """DEVELOPER NOTE: Check lookup code and confirm that it " \
            "is in the documentation config. Something has gone wrong.""",
            1,
        )

    try:
        exit_code = get_doc.dict[lookup_key]["exit_code"]
    except KeyError:
        exit_code = 0

    return msg, exit_code
