import logging
import re
import sys

from .settings import (
    BITOPS_logging_level,
    BITOPS_logging_color,
    BITOPS_logging_filename,
    BITOPS_logging_path,
    BITOPS_logging_masks,
)


# Logging levels
# 1. DEBUG
# 2. INFO
# 3. WARN
# 4. ERROR

BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE = range(8)
RESET_SEQ = "\033[0m"
COLOR_SEQ = "\033[1;%dm"
BOLD_SEQ = "\033[1m"

COLORS = {
    "DEBUG": BLUE,
    "INFO": GREEN,
    "WARNING": YELLOW,
    "ERROR": RED,
    "CRITICAL": MAGENTA,
}


# TODO: move to its own file so it can be used by plugins and before/after hooks
def mask_message(message):
    """
    Given a message, applies a mask according to the
    bitops level bitops.config.yaml's bitops.logging.mask property
    """
    if message is None:
        return message
    if BITOPS_logging_masks is None:
        return message

    res_str = message
    for config_item in BITOPS_logging_masks:
        # TODO: use a library here?
        res_str = re.sub(rf"{config_item.search}", config_item.replace, str(res_str))
    # String after replacement
    return res_str


def formatter_message(message, use_color=BITOPS_logging_color):
    """
    Formats messages replaces $RESET and $BOLD placeholders
    with the respective bash color sequences.
    """
    if use_color:
        message = message.replace("$RESET", RESET_SEQ).replace("$BOLD", BOLD_SEQ)
    else:
        message = message.replace("$RESET", "").replace("$BOLD", "")

    return message


class BitOpsFormatter(logging.Formatter):
    """
    Class that controls the formatting of logging text, adds colors if enabled.
    Settings are contained within "bitops.config.yaml:bitops.logging".
    """

    def __init__(self, msg, use_color=BITOPS_logging_color):
        logging.Formatter.__init__(self, msg)
        self.use_color = use_color

    def format(self, record):
        """
        Adds color to the logging text
        """
        levelname = record.levelname
        if self.use_color and levelname in COLORS:
            levelname_color = COLOR_SEQ % (30 + COLORS[levelname]) + levelname + RESET_SEQ
            record.levelname = levelname_color

        # mask the output
        record.msg = mask_message(record.msg)

        return logging.Formatter.format(self, record)


formatter = BitOpsFormatter(
    formatter_message("%(asctime)s %(name)-12s %(levelname)-8s %(message)s")
)


logger = logging.getLogger()
logger.setLevel(BITOPS_logging_level)

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(BITOPS_logging_level)


handler.setFormatter(formatter)
logger.addHandler(handler)


if BITOPS_logging_filename is not None:
    # This assumes that the user wants to save output to a filename

    # Create the directory if it doesn't exist
    from pathlib import Path

    Path(BITOPS_logging_path).mkdir(parents=True, exist_ok=True)

    BITOPS_logging_filename.replace(".logs", "").replace(".log", "")

    fileHandler = logging.FileHandler(f"{BITOPS_logging_path}/{BITOPS_logging_filename}.log")
    fileHandler.setFormatter(formatter)
    logger.addHandler(fileHandler)
