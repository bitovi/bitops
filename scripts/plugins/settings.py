import os
import yaml

from munch import DefaultMunch

# Configuration files
BITOPS_config_file = os.environ.get("BITOPS_BUILD_CONFIG_YAML", "build.config.yaml")
with open(BITOPS_config_file, 'r') as stream:    
    BITOPS_config_yaml = yaml.load(stream, Loader=yaml.FullLoader)

# BitOps run options
BITOPS_fast_fail_mode = os.environ.get("BITOPS_FAST_FAIL", False)
BITOPS_run_mode = os.environ.get("BITOPS_MODE", "default") # ["default", "testing"]
BITOPS_logging_level = os.environ.get("BITOPS_LOGGING_LEVEL", "INFO").upper




# Updating from Bitops build config
bitops_build_configuration = DefaultMunch.fromDict(BITOPS_config_yaml, None)
bitops_build_configuration.bitops.fast_fail