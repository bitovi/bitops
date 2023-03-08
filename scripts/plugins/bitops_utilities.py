import os
import sys
from munch import DefaultMunch

from .logging import logger
from .settings import BITOPS_fast_fail_mode
from .schema import SchemaObject
from .utilities import run_cmd


def parse_yaml_keys_to_list(schema, root_key, key_chain=None):
    """
    Recursive function that iterates over a schema and generates
    a configuration property path list.
    """
    keys_list = []
    if key_chain is None:
        key_chain = root_key

    for _property in schema[root_key].keys():
        inner_schema = schema[root_key]
        key_value = f"{key_chain}.{_property}"
        keys_list.append(key_value)
        try:
            keys_list += parse_yaml_keys_to_list(inner_schema, _property, key_value)
        except AttributeError:
            # End of keys for property, move on to next key
            continue
    return keys_list


def convert_yaml_to_dict(inc_yaml, null_replacement=None):
    """
    This function takes in a YAML object and converts it to a Python
    Dictionary object, optionally replacing null values with a specified value.
    """
    return DefaultMunch.fromDict(inc_yaml, null_replacement)


def generate_schema_keys(schema):
    """
    This function generates a list of properties from a given schema
    by parsing it, and also removes certain values from the list.
    """
    schema_keys_list = []
    schema_root_keys = list(schema.keys())
    root_key = schema_root_keys[0]
    schema_keys_list.append(root_key)

    schema_keys_list += parse_yaml_keys_to_list(schema, root_key)

    logger.debug(f"Schema keys: [{schema_keys_list}]")

    ignore_values = ["type", "properties", "cli", "options", root_key]

    schema_properties_list = [
        item
        for item in schema_keys_list
        if item.split(".")[-1] not in ignore_values
        and item.split(".")[-1] not in SchemaObject.properties
    ]
    return schema_properties_list


def generate_populated_schema_list(schema, schema_properties_list, config_yaml):
    """
    This function takes a schema, a list of schema properties and a
    configuration yaml file, and returns a populated list of schema objects.
    """
    schema_list = []

    for schema_properties in schema_properties_list:
        logger.debug(f"Starting a new property search for schema_property: [{schema_properties}]")
        property_name = schema_properties.split(".")[-1]

        result = SchemaObject.get_nested_item(schema, schema_properties)

        schema_object = SchemaObject(property_name, schema_properties, result)
        schema_object.process_config(config_yaml)
        schema_list.append(schema_object)
    return schema_list


def populate_parsed_configurations(schema_list):
    """
    This function takes a list of "schema_list" and parses it into
    different lists based on the value, type and requirements of each item.
    It also prints out messages to the logger as it goes.
    """
    bad_config_list = [item for item in schema_list if item.value == "BAD_CONFIG"]
    parsed_schema_list = [item for item in schema_list if item not in bad_config_list]
    cli_config_list = [item for item in parsed_schema_list if item.schema_property_type == "cli"]
    options_config_list = [
        item for item in parsed_schema_list if item.schema_property_type == "options"
    ]
    required_config_list = [
        item for item in parsed_schema_list if item.required is True and not item.value
    ]

    logger.debug("\n~~~~~ CLI OPTIONS ~~~~~")
    for item in cli_config_list:
        logger.debug(item)
    logger.debug("\n~~~~~ PLUGIN OPTIONS ~~~~~")
    for item in options_config_list:
        logger.debug(item)
    logger.debug("\n~~~~~ BAD SCHEMA CONFIG ~~~~~")
    for item in bad_config_list:
        logger.debug(item)
    return (cli_config_list, options_config_list, required_config_list)


def handle_hooks(mode, hooks_folder, source_folder):
    """
    Processes a bitops before/after hook by invoking bash script(s) within the hooks folder(s).
    """
    # Checks if the folder exists, if not, move on
    if not os.path.isdir(hooks_folder):
        return

    original_directory = os.getcwd()
    os.chdir(source_folder)

    umode = mode.upper()
    logger.info(f"INVOKING {umode} HOOKS")
    # Check what's in the ops_repo/<plugin>/bitops.before-deploy.d/
    hooks = sorted(os.listdir(hooks_folder))
    msg = f"\n\n~#~#~#~BITOPS {umode} HOOKS~#~#~#~"
    for hook in hooks:
        msg += "\n\t" + hook
    logger.debug(msg)

    for hook_script in hooks:
        # Invoke the hook script

        plugin_before_hook_script_path = hooks_folder + "/" + hook_script
        os.chmod(plugin_before_hook_script_path, 775)

        result = run_cmd(["bash", plugin_before_hook_script_path])
        if result.returncode == 0:
            logger.info(f"~#~#~#~{umode} HOOK [{hook_script}] SUCCESSFULLY COMPLETED~#~#~#~")
            logger.debug(result.stdout)
        else:
            logger.warning(f"~#~#~#~{umode} HOOK [{hook_script}] FAILED~#~#~#~")
            logger.debug(result.stdout)
            if BITOPS_fast_fail_mode:
                sys.exit(result.returncode)

    os.chdir(original_directory)
