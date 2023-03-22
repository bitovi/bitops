import os
import sys
import argparse
import operator
import yaml

from munch import DefaultMunch


def get_first(*args):
    """
    Return the first non-null variable from the input args.
    Helpful to find the first meaningful value in the chain of vars.
    """
    if not args:
        return None
    for arg in args:
        if arg is not None:
            return arg
    return args[-1]


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


def parse_config(dictionary, dotted_key_list):
    """
    This function takes a dictionary, a list of keys in dotted notation,
    and an optional boolean argument "validate". It uses the operator.attrgetter()
    method to access the value in the dictionary associated with the dotted key list.
    """
    try:
        item = operator.attrgetter(dotted_key_list)(dictionary)
        return item
    except AttributeError:
        # Likely cause: Nested value doesn't exist
        return None


parser = argparse.ArgumentParser(description="Add BitOps Usage")
parser.add_argument("--bitops_config_file", "-c", help="BitOps source usage information here")

BITOPS_CL_args, unknowns = parser.parse_known_args()

# BitOps Configuration file
BITOPS_ENV_config_file = os.environ.get("BITOPS_BUILD_CONFIG_YAML")
BITOPS_config_file = get_first(
    BITOPS_ENV_config_file, BITOPS_CL_args.bitops_config_file, "bitops.config.yaml"
)
with open(BITOPS_config_file, "r", encoding="utf8") as stream:
    BITOPS_config_yaml = yaml.load(stream, Loader=yaml.FullLoader)

# BitOps Schema File
BITOPS_ENV_schema_file = os.environ.get("BITOPS_BUILD_SCHEMA_YAML")
BITOPS_schema_file = get_first(BITOPS_ENV_schema_file, "bitops.schema.yaml")
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
BITOPS_ENV_logging_filename = os.environ.get("BITOPS_LOGGING_FILENAME")
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
BITOPS_FAST_FAIL_MODE = get_first(
    # ENV
    BITOPS_ENV_fast_fail_mode,
    # user config
    parse_config(bitops_user_configuration, "bitops.fail_fast"),
    # build config
    parse_config(bitops_build_configuration, "bitops.fail_fast"),
    # default
    True,
)

BITOPS_RUN_MODE = get_first(
    BITOPS_ENV_run_mode,
    parse_config(bitops_user_configuration, "bitops.run_mode"),
    parse_config(bitops_build_configuration, "bitops.run_mode"),
    "default",
)

BITOPS_LOGGING_LEVEL = get_first(
    BITOPS_ENV_logging_level,
    parse_config(bitops_user_configuration, "bitops.logging.level"),
    parse_config(bitops_build_configuration, "bitops.logging.level"),
    "DEBUG",
)

BITOPS_LOGGING_COLOR = get_first(
    parse_config(bitops_user_configuration, "bitops.logging.color.enabled"),
    parse_config(bitops_build_configuration, "bitops.logging.color.enabled"),
    False,
)

BITOPS_LOGGING_FILENAME = get_first(
    BITOPS_ENV_logging_filename,
    parse_config(bitops_user_configuration, "bitops.logging.filename"),
    parse_config(bitops_build_configuration, "bitops.logging.filename"),
    None,
)

BITOPS_LOGGING_PATH = get_first(
    parse_config(bitops_user_configuration, "bitops.logging.path"),
    parse_config(bitops_build_configuration, "bitops.logging.path"),
    "/var/log/bitops",
)

BITOPS_LOGGING_MASKS = get_first(
    parse_config(bitops_user_configuration, "bitops.logging.masks"),
    parse_config(bitops_build_configuration, "bitops.logging.masks"),
    None,
)

BITOPS_INSTALLED_PLUGINS_DIR = "/opt/bitops/scripts/installed_plugins/"

BITOPS_PLUGIN_DIR = get_first(
    BITOPS_ENV_plugin_dir,
    parse_config(bitops_user_configuration, "bitops.plugins.plugin_dir"),
    parse_config(bitops_build_configuration, "bitops.plugins.plugin_dir"),
    "/opt/bitops/scripts/plugins/",
)

BITOPS_DEFAULT_FOLDER = get_first(
    BITOPS_ENV_default_folder,
    parse_config(bitops_user_configuration, "bitops.default_folder"),
    parse_config(bitops_build_configuration, "bitops.default_folder"),
    "_default",
)

BITOPS_TIMEOUT = get_first(
    BITOPS_ENV_timeout,
    parse_config(bitops_user_configuration, "bitops.timeout"),
    parse_config(bitops_build_configuration, "bitops.timeout"),
    600,
)
