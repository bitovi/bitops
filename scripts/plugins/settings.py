import os
import sys
import argparse
import yaml

from munch import DefaultMunch


parser = argparse.ArgumentParser(description="Add BitOps Usage")
parser.add_argument("--bitops_config_file", "-c", help="BitOps source usage information here")

BITOPS_CL_args, unknowns = parser.parse_known_args()

# BitOps Configuration file
BITOPS_ENV_config_file = os.environ.get("BITOPS_BUILD_CONFIG_YAML")
BITOPS_config_file = (
    BITOPS_ENV_config_file
    if BITOPS_ENV_config_file is not None
    else BITOPS_CL_args.bitops_config_file
    if BITOPS_CL_args.bitops_config_file is not None
    else "bitops.config.yaml"
)
with open(BITOPS_config_file, "r", encoding="utf8") as stream:
    BITOPS_config_yaml = yaml.load(stream, Loader=yaml.FullLoader)

BITOPS_ENV_schema_file = os.environ.get("BITOPS_BUILD_SCHEMA_YAML")
BITOPS_schema_file = (
    BITOPS_ENV_schema_file if BITOPS_ENV_schema_file is not None else "bitops.schema.yaml"
)
with open(BITOPS_schema_file, "r", encoding="utf8") as stream:
    BITOPS_schema_yaml = yaml.load(stream, Loader=yaml.FullLoader)

# Updating from Bitops build config
bitops_build_configuration = DefaultMunch.fromDict(BITOPS_config_yaml, None)
bitops_schema_configuration = DefaultMunch.fromDict(BITOPS_schema_yaml, None)

# ENVIRONMENT
BITOPS_ENV_fast_fail_mode = os.environ.get("BITOPS_FAST_FAIL")
BITOPS_ENV_run_mode = os.environ.get("BITOPS_MODE")
BITOPS_ENV_logging_level = os.environ.get("BITOPS_LOGGING_LEVEL")
BITOPS_ENV_plugin_dir = os.environ.get("BITOPS_PLUGIN_DIR")
BITOPS_ENV_installed_plugin_dir = os.environ.get("BITOPS_INSTALLED_PLUGIN_DIR")

BITOPS_ENV_default_folder = os.environ.get("BITOPS_DEFAULT_FOLDER")
# v2.0.0: Fallback to 'ENVIRONMENT' in case when 'BITOPS_ENVIRONMENT' is not set
# TODO: Drop 'ENVIRONMENT' backward-compatibility in the future versions
BITOPS_ENV_environment = os.environ.get("BITOPS_ENVIRONMENT", os.environ.get("ENVIRONMENT", None))
BITOPS_ENV_timeout = os.environ.get("BITOPS_TIMEOUT")

if not bitops_build_configuration.bitops:
    sys.stderr.write(
        f"Error: Invalid {BITOPS_config_file}: 'bitops' at the root level definition is required!"
    )
    sys.exit(1)

# WASHED VALUES
# This is just stacked ternary operators. Don't be scared.
# All this does is X if X is set, Y if Y is set, else default value
BITOPS_fast_fail_mode = (
    BITOPS_ENV_fast_fail_mode
    if BITOPS_ENV_fast_fail_mode is not None
    else bitops_build_configuration.bitops.fail_fast
    if bitops_build_configuration.bitops.fail_fast is not None
    else True
)

BITOPS_run_mode = (
    BITOPS_ENV_run_mode
    if BITOPS_ENV_run_mode is not None
    else bitops_build_configuration.bitops.run_mode
    if bitops_build_configuration.bitops.run_mode is not None
    else "default"
)

BITOPS_logging_level = (
    BITOPS_ENV_logging_level
    if BITOPS_ENV_logging_level is not None
    else bitops_build_configuration.bitops.logging.level
    if bitops_build_configuration.bitops.logging.level is not None
    else "DEBUG"
)

BITOPS_logging_color = (
    bitops_build_configuration.bitops.logging.color.enabled
    if bitops_build_configuration.bitops.logging.color.enabled is not None
    else False
)

BITOPS_logging_filename = (
    bitops_build_configuration.bitops.logging.filename
    if bitops_build_configuration.bitops.logging.filename is not None
    else None
)

BITOPS_logging_path = (
    bitops_build_configuration.bitops.logging.path
    if bitops_build_configuration.bitops.logging.path is not None
    else "/var/log/bitops"
)


BITOPS_plugin_dir = (
    BITOPS_ENV_plugin_dir
    if BITOPS_ENV_plugin_dir is not None
    else bitops_build_configuration.bitops.plugins.plugin_dir
    if bitops_build_configuration.bitops.plugins.plugin_dir is not None
    else "/opt/bitops/scripts/plugins/"
)

BITOPS_installed_plugins_dir = (
    BITOPS_ENV_installed_plugin_dir
    if BITOPS_ENV_installed_plugin_dir is not None
    else "/opt/bitops/scripts/installed_plugins/"
)

BITOPS_default_folder = (
    BITOPS_ENV_default_folder
    if BITOPS_ENV_default_folder is not None
    else bitops_build_configuration.bitops.default_folder
    if bitops_build_configuration.bitops.default_folder is not None
    else "_default"
)

BITOPS_timeout = (
    BITOPS_ENV_timeout
    if BITOPS_ENV_timeout is not None
    else bitops_build_configuration.bitops.timeout
    if bitops_build_configuration.bitops.timeout is not None
    else 600
)

BITOPS_logging_masks = (
    bitops_build_configuration.bitops.logging.masks
    if bitops_build_configuration.bitops.logging.masks is not None
    else None
)
