import sys

from .logging import logger
from .bitops_utilities import (
    convert_yaml_to_dict,
    generate_schema_keys,
    generate_populated_schema_list,
    populate_parsed_configurations,
)
from .utilities import load_yaml


def decli_parse_configuration(config_file, schema_file):
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

    schema_yaml = load_yaml(schema_file)
    config_yaml = load_yaml(config_file)
    schema = convert_yaml_to_dict(schema_yaml)
    schema_properties_list = generate_schema_keys(schema)
    schema_list = generate_populated_schema_list(schema, schema_properties_list, config_yaml)
    (
        cli_config_list,
        options_config_list,
        required_config_list,
    ) = populate_parsed_configurations(schema_list)
    if required_config_list:
        logger.warning("\n~~~~~ REQUIRED CONFIG ~~~~~")
        for item in required_config_list:
            logger.error(
                f"Configuration value: [{item.name}] is required. Please ensure you "
                "set this configuration value in the plugins `bitops.config.yaml`"
            )
            logger.debug(item)
            sys.exit(1)
    return cli_config_list, options_config_list
