import os
import sys
import subprocess
import re
import yaml

from munch import DefaultMunch
from .logging import logger
from .settings import (
    BITOPS_fast_fail_mode,
    BITOPS_config_file,
)


class SchemaObject:
    properties = [
        "export_env",
        "default",
        "enabled",
        "type",
        "parameter",
        "required",
        "dash_type",
    ]

    def __init__(self, name, schema_key, schema_property_values=None):
        self.name = name
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
                    if BITOPS_fast_fail_mode:
                        raise exc

        logger.info(f"\n\tNEW SCHEMA:{self.print_schema()}")

    def __str__(self):
        return f"\n\tSCHEMA:{self.print_schema()}"

    def print_schema(self):
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

    def process_config(self, config_yaml):
        if self.type == "object":
            return
        result = get_nested_item(config_yaml, self.config_key)
        logger.info(f"\n\tSearching for: [{self.config_key}]\n\t\tResult Found: [{result}]")
        found_config_value = apply_data_type(self.type, result)

        if found_config_value:
            logger.info(
                f"Override found for: [{self.name}], default: [{self.default}], "
                f"new value: [{found_config_value}]"
            )
            self.value = found_config_value
        else:
            self.value = self.default

        add_value_to_env(self.export_env, self.value)


def parse_values(item):
    return item.replace("properties.", "")


def load_yaml(yaml_file):
    with open(yaml_file, "r", encoding="utf8") as stream:
        try:
            plugins_yml = yaml.load(stream, Loader=yaml.FullLoader)
        except yaml.YAMLError as exc:
            logger.error(exc)
        except Exception as exc:
            logger.error(exc)
    return plugins_yml


def load_build_config():
    logger.info(f"Loading {BITOPS_config_file}")
    # Load plugin config yml
    return load_yaml(BITOPS_config_file)


def apply_data_type(data_type, convert_value):
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
        raise ValueError(f"Data type not supported: [{data_type}]")

    logger.warning(f"Data type not supported: [{data_type}]")
    return None


def add_value_to_env(export_env, value):
    if value is None or value == "" or value == "None" or export_env is None or export_env == "":
        return

    export_env = "BITOPS_" + export_env
    os.environ[export_env] = str(value)
    logger.info("Setting environment variable: [{export_env}], to value: [{value}]")


def get_nested_item(search_dict, key):
    logger.debug(
        f"\n\t\tSEARCHING FOR KEY:  [{key}]    \
                  \n\t\tSEARCH_DICT:        [{search_dict}]"
    )
    obj = search_dict
    key_list = key.split(".")
    try:
        for k in key_list:
            obj = obj[k]
    except KeyError:
        return None
    logger.debug(f"\n\t\tKEY [{key}] \n\t\tRESULT FOUND:   [{obj}]")
    return obj


def parse_yaml_keys_to_list(schema, root_key, key_chain=None):
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


def get_config_list(config_file, schema_file):
    logger.info(
        f"\n\n\n~#~#~#~CONVERTING: \
    \n\t PLUGIN CONFIGURATION FILE PATH:    [{config_file}]    \
    \n\t PLUGIN SCHEMA FILE PATH:           [{schema_file}]    \
    \n\n"
    )

    try:
        with open(schema_file, "r", encoding="utf8") as stream:
            schema_yaml = yaml.load(stream, Loader=yaml.FullLoader)
        with open(config_file, "r", encoding="utf8") as stream:
            config_yaml = yaml.load(stream, Loader=yaml.FullLoader)
    except FileNotFoundError as err:
        logger.error(f"REQUIRED FILE NOT FOUND: [{err.filename}]")

    schema = DefaultMunch.fromDict(schema_yaml, None)

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

    schema_list = []

    # WASH
    logger.debug("Washed schema values are")
    for item in schema_properties_list:
        logger.debug(item)

    for schema_properties in schema_properties_list:
        logger.debug("Starting a new property search")
        property_name = schema_properties.split(".")[-1]

        result = get_nested_item(schema, schema_properties)

        schema_object = SchemaObject(property_name, schema_properties, result)
        schema_object.process_config(config_yaml)
        schema_list.append(schema_object)

    bad_config_list = [item for item in schema_list if item.value == "BAD_CONFIG"]
    schema_list = [item for item in schema_list if item not in bad_config_list]
    cli_config_list = [item for item in schema_list if item.schema_property_type == "cli"]
    options_config_list = [item for item in schema_list if item.schema_property_type == "options"]
    required_config_list = [
        item for item in schema_list if item.required is True and not item.value
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

    if required_config_list:
        logger.warning("\n~~~~~ REQUIRED CONFIG ~~~~~")
        for item in required_config_list:
            logger.error(
                f"Configuration value: [{item.name}] is required. Please ensure you "
                "set this configuration value in the plugins `bitops.config.yaml`"
            )
            logger.debug(item)
            sys.exit()

    return cli_config_list, options_config_list


def generate_cli_command(cli_config_list):
    logger.info("Generating CLI options")
    for item in cli_config_list:
        logger.info(item)


def handle_hooks(mode, hooks_folder):
    # Checks if the folder exists, if not, move on
    if not os.path.isdir(hooks_folder):
        return

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
        try:
            result = subprocess.run(
                ["bash", plugin_before_hook_script_path],
                universal_newlines=True,
                capture_output=True,
                check=False,
            )

        except Exception as exc:
            logger.error(exc)
            if BITOPS_fast_fail_mode:
                sys.exit(101)

        if result.returncode == 0:
            logger.info(f"~#~#~#~{umode} HOOK [{hook_script}] SUCCESSFULLY COMPLETED~#~#~#~")
            logger.debug(result.stdout)
        else:
            logger.warning(f"~#~#~#~{umode} HOOK [{hook_script}] FAILED~#~#~#~")
            logger.debug(result.stdout)
