import logging
import sys
from .settings import BITOPS_logging_level

# Logging levels
# 1. DEBUG
# 2. INFO
# 3. WARN
# 4. ERROR

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s %(name)-12s %(levelname)-8s %(message)s')

handler.setFormatter(formatter)
logger.addHandler(handler)
