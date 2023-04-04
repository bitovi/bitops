import os

# Disable logging to file when running tests
os.environ["BITOPS_LOGGING_FILENAME"] = "false"
