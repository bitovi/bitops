import sys

from munch import DefaultMunch
from ..logging import logger
from ..utilities import load_yaml
from .schema import SchemaObject


def get_config_list(config_file, schema_file):
    """
    Top level function that handles the parsing of a schema and loading of a configuration file.
    Results in a list of all schema values, their defaults and their configuration value (if set).
    """
    logger.info(
        f"\n\n\n~#~#~#~CONVERTING: \
    \n\t PLUGIN CONFIGURATION FILE PATH:    [{config_file}]    \
    \n\t PLUGIN SCHEMA FILE PATH:           [{schema_file}]    \
    \n\n"
    )
    try:
        schema_yaml = load_yaml(schema_file)
        config_yaml = load_yaml(config_file)
    except FileNotFoundError:
        sys.exit(2)
    schema = convert_yaml_to_dict(schema_yaml)
    schema_properties_list = generate_schema_keys(schema)
    schema_list = generate_populated_schema_list(schema, schema_properties_list, config_yaml)
    (
        cli_config_list,
        options_config_list,
        missing_required_config_list,
    ) = populate_parsed_configurations(schema_list)
    if missing_required_config_list:
        logger.warning("\n~~~~~ REQUIRED CONFIG ~~~~~")
        for item in missing_required_config_list:
            logger.error(
                f"Configuration value: [{item.name}] is required. Please ensure you "
                "set this configuration value in the plugins `bitops.config.yaml`"
            )
        sys.exit(1)
    return cli_config_list, options_config_list


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
    missing_required_config_list = [
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
    return (cli_config_list, options_config_list, missing_required_config_list)
