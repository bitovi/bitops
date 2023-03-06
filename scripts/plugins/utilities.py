import os
import sys
import subprocess
import re
from typing import Union
from munch import DefaultMunch
import yaml

from .doc import get_doc
from .logging import logger, mask_message
from .settings import BITOPS_fast_fail_mode


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
                    if BITOPS_fast_fail_mode:
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

        if BITOPS_fast_fail_mode:
            logger.error(f"Data type not supported: [{data_type}]")
            sys.exit(101)

        logger.warning(f"Data type not supported: [{data_type}]")
        return None


def add_value_to_env(export_env, value):
    """
    Takes a variable name and value and loads them into an environment variable.
    This is used to pass variables to the plugins.

    Old behavior: (TO BE DEPRECATED)
        export_env: ANSIBLE_VERBOSITY
        export BITOPS_ANSIBLE_VERBOSITY=1
    New behavior:
        export_env: ANSIBLE_VERBOSITY
        export ANSIBLE_VERBOSITY=1

    We keep the old behavior for backwards compatibility.
    """
    if value is None or value == "" or value == "None" or not export_env:
        return

    if isinstance(value, bool):
        value = str(value).lower()

    if isinstance(value, list):
        value = " ".join(value)

    os.environ[export_env] = str(value)
    logger.info(f"Setting export environment variable: [{export_env}], to value: [{value}]")

    # Normally, "export_env: TERRAFORM_VERSION" should be exported as is.
    # Here we prefix with "BITOPS_" for backwards compatibility.
    # TODO: Remove this in a future releases after updating all plugins
    if not export_env.startswith("BITOPS_"):
        export_env = f"BITOPS_{export_env}"
        os.environ[export_env] = str(value)
        logger.info(
            f"Setting export environment variable: [{export_env}], to value: [{value}] (old)"
        )


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


def load_yaml(inc_yaml):
    """
    This function attempts to load a YAML file from a given location,
    and exits if the file is not found. It returns the loaded YAML file if successful.
    """
    out_yaml = None
    try:
        with open(inc_yaml, "r", encoding="utf8") as stream:
            out_yaml = yaml.load(stream, Loader=yaml.FullLoader)
    except FileNotFoundError as e:
        msg, exit_code = get_doc("missing_required_file")
        logger.error(f"{msg} [{e.filename}]")
        logger.debug(e)
        sys.exit(exit_code)
    return out_yaml


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
    return (
        cli_config_list,
        options_config_list,
        required_config_list
    )


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


def run_cmd(command: Union[list, str]) -> subprocess.Popen:
    """Run a linux command and return Popen instance as a result"""
    try:
        with subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        ) as process:
            for combined_output in process.stdout:
                # TODO: parse output for secrets
                # TODO: specify plugin and output tight output (no extra newlines)
                # TODO: can we modify a specific handler to add handler.terminator = "" ?
                sys.stdout.write(mask_message(combined_output))

            # This polls the async function to get information
            # about the status of the process execution.
            # Namely the return code which is used elsewhere.
            process.communicate()

    except Exception as exc:
        logger.error(exc)
        sys.exit(101)
    return process
