import os
import yaml

from munch import DefaultMunch

# Configuration files
BITOPS_config_file = os.environ.get("BITOPS_BUILD_CONFIG_YAML", "bitops.config.yaml")
with open(BITOPS_config_file, 'r') as stream:    
    BITOPS_config_yaml = yaml.load(stream, Loader=yaml.FullLoader)

# Updating from Bitops build config
bitops_build_configuration = DefaultMunch.fromDict(BITOPS_config_yaml, None)
bitops_build_configuration.bitops.fast_fail



# ENVIRONMENT
BITOPS_ENV_fast_fail_mode = os.environ.get("BITOPS_FAST_FAIL")
BITOPS_ENV_run_mode = os.environ.get("BITOPS_MODE")
BITOPS_ENV_logging_level = os.environ.get("BITOPS_LOGGING_LEVEL")

# WASHED VALUES
# This is just stacked ternary operators. Don't be scared. All this does is X if X is set, Y if Y is set, else default value
BITOPS_fast_fail_mode = BITOPS_ENV_fast_fail_mode                   \
    if BITOPS_ENV_fast_fail_mode is not None                        \
    else bitops_build_configuration.bitops.fail_fast                \
        if bitops_build_configuration.bitops.fail_fast is not None  \
        else True

BITOPS_run_mode = BITOPS_ENV_run_mode                               \
    if BITOPS_ENV_run_mode is not None                              \
    else bitops_build_configuration.bitops.run_mode                 \
        if bitops_build_configuration.bitops.run_mode is not None   \
        else "default"

BITOPS_logging_level = BITOPS_ENV_logging_level                         \
    if BITOPS_ENV_logging_level is not None                             \
    else bitops_build_configuration.bitops.logging.level                \
        if bitops_build_configuration.bitops.logging.level is not None  \
        else "DEBUG"

BITOPS_opsrepo_source = bitops_build_configuration.bitops.ops_repo.source_from   \
    if bitops_build_configuration.bitops.ops_repo.source_from is not None        \
    else "local"

