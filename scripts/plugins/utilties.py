
import yaml
import os
import subprocess
import re

from munch import DefaultMunch
from itertools import chain
from logging import root
from xml.etree.ElementTree import tostring
from .settings import BITOPS_fast_fail_mode, BITOPS_config_file
from .logging import logger

class SchemaObject:
    properties = ["export_env", "default", "enabled", "type", "parameter"]
    
    def __init__(self, name, schema_key, schema_property_type, schema_property_values=None):
        self.name = name
        self.schema_key = schema_key
        self.config_key = schema_key.replace(".properties", "")
        self.schema_property_type = schema_property_type

        self.export_env = ""
        self.default = ""
        self.enabled = ""
        self.value = ""
        self.type = ""

        if schema_property_values:
            for property in self.properties:
                try:
                    logger.debug("Schema Object setting attribute: [{}] value: [{}] from values: [{}]".format(property, schema_property_values[property], schema_property_values))
                    setattr(self, property, schema_property_values[property])
                except KeyError as exc:
                    setattr(self, property, None)
                    if BITOPS_fast_fail_mode:
                        raise exc
                    else:
                        continue
            
    def __str__(self):
        return "Schema Poperty Name: [{}]\nSchema Key: [{}]\nConfig Key: [{}]\nSchema Property Type: [{}]\nValue Set To: [{}]\nSchema Properties:\n\texport_env: [{}]\n\tdefault: [{}]\n\ttype: [{}]\n".format(self.name, self.schema_key, self.config_key, self.schema_property_type, self.value, self.export_env, self.default, self.type)
    
    def ProcessConfig(self, config_yaml):
        if self.type == "object": return
        logger.info("Searching for: [{}]".format(self.config_key))
        result = Get_Nested_Item(config_yaml, self.config_key)
        found_config_value = Apply_Data_Type(self.type, result)
        
        if found_config_value is None or found_config_value == "None":
            self.value = "BAD_CONFIG"
        elif found_config_value != "":
            logger.info("Override found for: [{}], default: [{}], new value: [{}]".format(self.name, self.default, found_config_value))
            self.value = found_config_value
        else:
            self.value = self.default
        
        AddValueToEnv(self.export_env, self.value)

def Load_Yaml(yaml_file):
    with open(yaml_file, 'r') as stream:
        try:
            plugins_yml = yaml.load(stream, Loader=yaml.FullLoader)
        except yaml.YAMLError as exc:
            logger.error(exc)
        except Exception as exc:
            logger.error(exc)
    return plugins_yml

def Load_Build_Config():
    logger.info("Loading {}".format(BITOPS_config_file))
    # Load plugin config yml
    return Load_Yaml(BITOPS_config_file)

def Apply_Data_Type(data_type, convert_value):
    if re.search("list", data_type, re.IGNORECASE):
        return list(convert_value)
    elif re.search("string", data_type, re.IGNORECASE):
        return str(convert_value)
    elif re.search("int", data_type, re.IGNORECASE):
        return int(convert_value)
    elif re.search("boolean", data_type, re.IGNORECASE) or re.search("bool", data_type, re.IGNORECASE):
        return bool(convert_value)
    else:
        if BITOPS_fast_fail_mode:
            raise ValueError("Data type not supported: [{}]".format(data_type))
        else:
            logger.warn("Data type not supported: [{}]".format(data_type))
            return None

def AddValueToEnv(export_env, value):
    if value is None or value == "" or value == "None" or export_env is None or export_env == "" :
        return
    os.environ[export_env] = str(value)
    logger.info("Setting environment variable: [{}], to value: [{}]".format(export_env, value))

def Get_Nested_Item(search_dict, key):
    obj = search_dict
    key_list = key.split(".")
    try:
        for k in key_list:
            obj = obj[k]
    except KeyError:
        return None
    return obj

def Parse_Yaml_Keys_To_List(schema, root_key, key_chain=None):
    keys_list = []
    if key_chain is None: key_chain = root_key

    for property in schema[root_key].keys():
        inner_schema = schema[root_key]
        key_value = "{}.{}".format(key_chain, property)
        keys_list.append(key_value)
        try:
            keys_list+=Parse_Yaml_Keys_To_List(inner_schema, property, key_value)
        except AttributeError as e:
            # End of keys for property, move on to next key
            continue
    return keys_list

def Get_Config_List(schema_file, config_file):          
    logger.info("Converting... Schema: [{}], Config: [{}]".format(schema_file, config_file))

    config_yaml = Load_Yaml(config_file)
    schema_yaml = Load_Yaml(schema_file)

    schema_keys_list = []
    schema_root_keys = list(schema_yaml.keys())
    root_key = schema_root_keys[0]
    schema_keys_list.append(root_key)

    schema_keys_list += Parse_Yaml_Keys_To_List(schema_yaml, root_key)
    
    logger.debug("Schema keys: [{}]".format(schema_keys_list))
    
    ignore_values = ["type", "properties", "cli", "options", root_key]
    
    schema_properties_list = [item for item in schema_keys_list if item.split(".")[-1] not in ignore_values and item.split(".")[-1] not in SchemaObject.properties]
    schema_list = []
    
    for schema_properties in schema_properties_list:
        property_name = schema_properties.split(".")[-1]
        result = Get_Nested_Item(schema_yaml, schema_properties)

        schema = SchemaObject(property_name, schema_properties, schema_properties.split(".")[2], result)
        schema.ProcessConfig(config_yaml)
        schema_list.append(schema)
    
    bad_config_list = [item for item in schema_list if item.value == "BAD_CONFIG"]
    schema_list = [item for item in schema_list if item not in bad_config_list]
    cli_config_list = [item for item in schema_list if item.schema_property_type == "cli"]
    options_config_list = [item for item in schema_list if item.schema_property_type == "options"]
    
    logger.debug("\n~~~~~ CLI OPTIONS ~~~~~")
    for item in cli_config_list:
        logger.debug(item)
    logger.debug("\n~~~~~ PLUGIN OPTIONS ~~~~~")
    for item in options_config_list:
        logger.debug(item)
    
    logger.debug("\n~~~~~ BAD SCHEMA CONFIG ~~~~~")
    for item in bad_config_list:
        logger.debug(item)
    
    return cli_config_list, options_config_list

def Generate_Cli_Command(cli_config_list):
    logger.info("Generating CLI options")
    for item in cli_config_list:
        logger.info(item)