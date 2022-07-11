# Loads JSON
# Provides a function to access the documentation
import json
import os 
from .logging import logger

fh = open("scripts/plugins/documentation.json")
jh = json.load(fh)

def Get_Doc(doc_key):
    msg = "\n\t{}\n\tFor more information checkout the Bitops Documentation: [{}]".format(jh[doc_key]["msg"], jh[doc_key]["link"])
    return msg