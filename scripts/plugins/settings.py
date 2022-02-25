# BITOPS
import os

BITOPS_fast_fail_mode = os.environ.get("BITOPS_FAST_FAIL", False)
BITOPS_run_mode = os.environ.get("BITOPS_MODE", "default") # ["default", "testing"]
BITOPS_logging_level = os.environ.get("BITOPS_LOGGING_LEVEL", "DEBUG").upper
BITOPS_config_file = os.environ.get("BITOPS_BUILD_CONFIG_YAML", "build.config.yaml")