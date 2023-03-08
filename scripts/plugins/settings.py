import os
import sys
import argparse
import operator
import yaml

from munch import DefaultMunch


def load_user_bitops_config() -> DefaultMunch:
    """
    Try to load user-specified bitops config from ops repo
    /opt/bitops_deployment/<BITOPS_ENVIRONMENT>/bitops.config.yaml
    """
    try:
        config = os.path.join(
            "/opt/bitops_deployment",
            os.environ.get("BITOPS_ENVIRONMENT", os.environ.get("ENVIRONMENT", None)),
            "bitops.config.yaml",
        )
        with open(config, "r", encoding="utf8") as file_handle:
            return yaml.load(file_handle, Loader=yaml.FullLoader)
    except TypeError:
        # This is the case when the ENVIRONMENT variable is not set.
        # This happens during the container build
        return None
    except FileNotFoundError:
        return None


def parse_config(dictionary, dotted_key_list, validate=False):
    """
    This function takes a dictionary, a list of keys in dotted notation,
    and an optional boolean argument "validate". It uses the operator.attrgetter()
    method to access the value in the dictionary associated with the dotted key list.
    """
    try:
        item = operator.attrgetter(dotted_key_list)(dictionary)
        if item is None and validate:
            return False
        if item is not None and validate:
            return True
        return item
    except AttributeError:
        # Likely cause: Nested value doesn't exist
        if validate:
            return False
        return None


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

# BitOps Schema File
BITOPS_ENV_schema_file = os.environ.get("BITOPS_BUILD_SCHEMA_YAML")
BITOPS_schema_file = (
    BITOPS_ENV_schema_file if BITOPS_ENV_schema_file is not None else "bitops.schema.yaml"
)
with open(BITOPS_schema_file, "r", encoding="utf8") as stream:
    BITOPS_schema_yaml = yaml.load(stream, Loader=yaml.FullLoader)

# BitOps User configuration
BITOPS_user_config_yaml = load_user_bitops_config()

# Updating from Bitops build config
bitops_build_configuration = DefaultMunch.fromDict(BITOPS_config_yaml, None)
bitops_schema_configuration = DefaultMunch.fromDict(BITOPS_schema_yaml, None)
bitops_user_configuration = DefaultMunch.fromDict(BITOPS_user_config_yaml, None)

# ENVIRONMENT
BITOPS_ENV_fast_fail_mode = os.environ.get("BITOPS_FAST_FAIL")
BITOPS_ENV_run_mode = os.environ.get("BITOPS_MODE")  # TODO: CLEAN
BITOPS_ENV_logging_level = os.environ.get("BITOPS_LOGGING_LEVEL")
BITOPS_ENV_plugin_dir = os.environ.get("BITOPS_PLUGIN_DIR")

BITOPS_ENV_default_folder = os.environ.get("BITOPS_DEFAULT_FOLDER")
# v2.0.0: Fallback to 'ENVIRONMENT' in case when 'BITOPS_ENVIRONMENT' is not set
# TODO: Drop 'ENVIRONMENT' backward-compatibility in the future versions
BITOPS_ENV_environment = os.environ.get("BITOPS_ENVIRONMENT", os.environ.get("ENVIRONMENT", None))
BITOPS_ENV_timeout = os.environ.get("BITOPS_TIMEOUT")  # TODO: CLEAN

if not bitops_build_configuration.bitops:
    sys.stderr.write(
        f"Error: Invalid {BITOPS_config_file}: 'bitops' at the root level definition is required!"
    )
    sys.exit(1)

# WASHED VALUES
# This is just stacked ternary operators. Don't be scared.
# All this does is X if X is set, Y if Y is set, else default value
BITOPS_FAST_FAIL_MODE = (
    # ENV
    BITOPS_ENV_fast_fail_mode
    if BITOPS_ENV_fast_fail_mode is not None
    # USER CONFIG
    else parse_config(bitops_user_configuration, "bitops.fail_fast")
    if parse_config(bitops_user_configuration, "bitops.fail_fast", validate=True)
    # BITOPS CONFIG
    else parse_config(bitops_build_configuration, "bitops.fail_fast")
    if parse_config(bitops_build_configuration, "bitops.fail_fast", validate=True)
    # DEFAULT
    else True
)

BITOPS_RUN_MODE = (
    # ENV
    BITOPS_ENV_run_mode
    if BITOPS_ENV_run_mode is not None
    # USER CONFIG
    else parse_config(bitops_user_configuration, "bitops.run_mode")
    if parse_config(bitops_user_configuration, "bitops.run_mode", validate=True)
    # BITOPS CONFIG
    else parse_config(bitops_build_configuration, "bitops.run_mode")
    if parse_config(bitops_build_configuration, "bitops.run_mode", validate=True)
    # DEFAULT
    else "default"
)

BITOPS_LOGGING_LEVEL = (
    # ENV
    BITOPS_ENV_logging_level
    if BITOPS_ENV_logging_level is not None
    # USER CONFIG
    else parse_config(bitops_user_configuration, "bitops.logging.level")
    if parse_config(bitops_user_configuration, "bitops.logging.level", validate=True)
    # BITOPS CONFIG
    else parse_config(bitops_build_configuration, "bitops.logging.level")
    if parse_config(bitops_build_configuration, "bitops.logging.level", validate=True)
    # DEFAULT
    else "DEBUG"
)

BITOPS_LOGGING_COLOR = (
    # USER CONFIG
    parse_config(bitops_user_configuration, "bitops.logging.color.enabled")
    if parse_config(bitops_user_configuration, "bitops.logging.color.enabled", validate=True)
    # BITOPS CONFIG
    else parse_config(bitops_build_configuration, "bitops.logging.color.enabled")
    if parse_config(bitops_build_configuration, "bitops.logging.color.enabled", validate=True)
    # DEFAULT
    else False
)

BITOPS_LOGGING_FILENAME = (
    # USER CONFIG
    parse_config(bitops_user_configuration, "bitops.logging.filename")
    if parse_config(bitops_user_configuration, "bitops.logging.filename", validate=True)
    # BITOPS CONFIG
    else parse_config(bitops_build_configuration, "bitops.logging.filename")
    if parse_config(bitops_build_configuration, "bitops.logging.filename", validate=True)
    # DEFAULT
    else None
)

BITOPS_LOGGING_PATH = (
    # USER CONFIG
    parse_config(bitops_user_configuration, "bitops.logging.path")
    if parse_config(bitops_user_configuration, "bitops.logging.path", validate=True)
    # BITOPS CONFIG
    else parse_config(bitops_build_configuration, "bitops.logging.path")
    if parse_config(bitops_build_configuration, "bitops.logging.path", validate=True)
    # DEFAULT
    else "/var/log/bitops"
)

BITOPS_LOGGING_MASKS = (
    # USER CONFIG
    parse_config(bitops_user_configuration, "bitops.logging.masks")
    if parse_config(bitops_user_configuration, "bitops.logging.masks", validate=True)
    # BITOPS CONFIG
    else parse_config(bitops_build_configuration, "bitops.logging.masks")
    if parse_config(bitops_build_configuration, "bitops.logging.masks", validate=True)
    # DEFAULT
    else None
)

BITOPS_INSTALLED_PLUGINS_DIR = "/opt/bitops/scripts/installed_plugins/"
BITOPS_PLUGIN_DIR = (
    # ENV
    BITOPS_ENV_plugin_dir
    if BITOPS_ENV_plugin_dir is not None
    # USER CONFIG
    else parse_config(bitops_user_configuration, "bitops.plugins.plugin_dir")
    if parse_config(bitops_user_configuration, "bitops.plugins.plugin_dir", validate=True)
    # BITOPS CONFIG
    else parse_config(bitops_build_configuration, "bitops.plugins.plugin_dir")
    if parse_config(bitops_build_configuration, "bitops.plugins.plugin_dir", validate=True)
    # DEFAULT
    else "/opt/bitops/scripts/plugins/"
)

BITOPS_DEFAULT_FOLDER = (
    # ENV
    BITOPS_ENV_default_folder
    if BITOPS_ENV_default_folder is not None
    # USER CONFIG
    else parse_config(bitops_user_configuration, "bitops.default_folder")
    if parse_config(bitops_user_configuration, "bitops.default_folder", validate=True)
    # BITOPS CONFIG
    else parse_config(bitops_build_configuration, "bitops.default_folder")
    if parse_config(bitops_build_configuration, "bitops.default_folder", validate=True)
    # DEFAULT
    else "_default"
)

BITOPS_TIMEOUT = (
    # ENV
    BITOPS_ENV_timeout
    if BITOPS_ENV_timeout is not None
    # USER CONFIG
    else parse_config(bitops_user_configuration, "bitops.timeout")
    if parse_config(bitops_user_configuration, "bitops.timeout", validate=True)
    # BITOPS CONFIG
    else parse_config(bitops_build_configuration, "bitops.timeout")
    if parse_config(bitops_build_configuration, "bitops.timeout", validate=True)
    # DEFAULT
    else 600
)
