import sys
import os
import re

from ..logging import logger
from ..settings import BITOPS_FAST_FAIL_MODE
from ..utilities import add_value_to_env


class SchemaObject:  # pylint: disable=too-many-instance-attributes
    """
    The SchemaObject is a class that is used to parse the bitops.schema.yaml into a python object.
    Further functionality will parse the object against a bitops.config.yaml.
    If a match is found between the bitops.schema and the bitops.config,
    the config value is loaded into the SchemaObject.
    """

    properties = [
        "export_env",
        "default",
        "enabled",
        "type",
        "parameter",
        "required",
        "dash_type",
        "description",
    ]

    def __init__(self, name, schema_key, schema_property_values=None):
        self.name = name
        self.plugin = schema_key.split(".")[0]

        self.schema_key = schema_key
        self.config_key = schema_key.replace(".properties", "")

        self.value = ""

        self.schema_property_type = self.config_key.split(".")[1] or None

        self.export_env = ""
        self.default = "NO DEFAULT FOUND"
        self.enabled = ""
        self.type = "object"
        self.parameter = ""
        self.dash_type = ""
        self.required = False

        if schema_property_values:
            for _property in self.properties:
                try:
                    setattr(self, _property, schema_property_values[_property])
                except KeyError as exc:
                    setattr(self, _property, None)
                    logger.error(exc)
                    if BITOPS_FAST_FAIL_MODE:
                        sys.exit(101)

        logger.info(f"\n\tNEW SCHEMA:{self.print_schema()}")

    def __str__(self):
        return f"\n\tSCHEMA:{self.print_schema()}"

    def print_schema(self):
        """
        Visual representation of the schema object parsed.
        """
        return f"\n\t\tName:         [{self.name}]\
            \n\t\tSchema Key:   [{self.schema_key}]\
            \n\t\tConfig_Key:   [{self.config_key}]\
            \n\t\tSchema Type:  [{self.schema_property_type}]\
            \n                      \
            \n\t\tExport Env:   [{self.export_env}]\
            \n\t\tDefault:      [{self.default}]\
            \n\t\tEnabled:      [{self.enabled}]\
            \n\t\tType:         [{self.type}]\
            \n\t\tParameter:    [{self.parameter}]\
            \n\t\tDash Type:    [{self.dash_type}]\
            \n\t\tRequired:     [{self.required}]\
            \n                      \
            \n\t\tValue Set:    [{self.value}]"

    @property
    def env(self) -> str:
        """
        Environment Variable name automatically associated with config property.
        Generated as "BITOPS_<PLUGIN>_<PROPERTY>", replacing all
        "-" with "_" and converting to uppercase.
        ENV variables specified by users take precedence over defaults and config values.

        Example:
        ```
            schema_key = "ansible.properties.options.extra-vars"
                =>
            env = "BITOPS_ANSIBLE_EXTRA_VARS"
        ```
        """
        plugin = self.plugin.replace("-", "_").upper()
        prop = self.name.replace("-", "_").upper()
        return f"BITOPS_{plugin}_{prop}"

    def process_config(self, config_yaml):
        """
        Function that processes the bitops.config against the SchemaObject,
        with the defaults loaded from the bitops.schema.
        It also checks that the type for the SchemaObject matches that in the configuration.
        """
        if self.type == "object":
            return
        result = SchemaObject.get_nested_item(config_yaml, self.config_key)
        logger.info(f"\n\tSearching for: [{self.config_key}]\n\t\tResult Found: [{result}]")
        found_config_value = SchemaObject._apply_data_type(self.type, result)

        # Priority: ENV > Config > Defaults
        if self.env in os.environ:
            self.value = os.environ[self.env]
            logger.info(f"ENV override found for: [{self.name}]. New value: [{self.value}]")
        elif found_config_value:
            logger.info(
                f"Config override found for: [{self.name}], default: [{self.default}], "
                f"new value: [{found_config_value}]"
            )
            self.value = found_config_value
        else:
            self.value = self.default

        add_value_to_env(self.export_env, self.value)

    @staticmethod
    def get_nested_item(search_dict, key):
        """
        Parses yaml (schema/config) based on SchemaObject properties path.
        """
        logger.debug(
            f"\n\t\tSEARCHING FOR KEY:  [{key}]    \
                    \n\t\tSEARCH_DICT:        [{search_dict}]"
        )
        obj = search_dict
        key_list = key.split(".")
        try:
            for k in key_list:
                obj = obj[k]
        except (KeyError, TypeError):
            return None
        logger.debug(f"\n\t\tKEY [{key}] \n\t\tRESULT FOUND:   [{obj}]")
        return obj

    @staticmethod
    def _apply_data_type(data_type, convert_value):
        """
        Converts incoming variable into `type of` based on SchemaObject.type property.
        """
        if data_type == "object" or convert_value is None:
            return None

        if re.search("list", data_type, re.IGNORECASE):
            return list(convert_value)
        if re.search("string", data_type, re.IGNORECASE):
            return str(convert_value)
        if re.search("int", data_type, re.IGNORECASE):
            return int(convert_value)
        if re.search("boolean", data_type, re.IGNORECASE) or re.search(
            "bool", data_type, re.IGNORECASE
        ):
            return bool(convert_value)

        if BITOPS_FAST_FAIL_MODE:
            logger.error(f"Data type not supported: [{data_type}]")
            raise UnSupportDataType(f"Data type not supported: [{data_type}]")

        logger.warning(f"Data type not supported: [{data_type}]")
        return None


class UnSupportDataType(Exception):
    """Raised when an unsupported data type is passed in to a function"""

    def __init__(self, message):
        self.message = message
