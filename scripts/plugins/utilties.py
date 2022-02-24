from itertools import chain
from logging import root
import yaml
import os
import subprocess
from munch import DefaultMunch


config_file = os.environ.get("BITOPS_BUILD_CONFIG_YAML", "build.config.yaml")

def Load_Build_Config():
    print("Loading {}".format(config_file))
    # Load plugin config yml
    with open(config_file, 'r') as stream:
        try:
            plugins_yml = yaml.load(stream, Loader=yaml.FullLoader)
        except yaml.YAMLError as exc:
            print(exc)
        except Exception as exc:
            print(exc)
  
    return plugins_yml

def Convert_Schema(schema_file, config_file):
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
                # End of keys for property, continue to move on to next key
                continue
        return keys_list
                
    print("Converting... Schema: [{}], Config: [{}]".format(schema_file, config_file))

    schema_keys_list = []
    with open(schema_file) as schema_fh:
        try:
            schema_yaml = yaml.load(schema_fh, Loader=yaml.FullLoader)

            schema_keys_list = []
            schema_root_keys = list(schema_yaml.keys())
            root_key = schema_root_keys[0]
            schema_keys_list.append(root_key)

            schema_keys_list += Parse_Yaml_Keys_To_List(schema_yaml, root_key)

        except yaml.YAMLError as exc:
            print(exc)
        except Exception as exc:
            print(exc)

    print("Schema keys: [{}]".format(schema_keys_list))
    
    class SchemaObject:
        def __init__(self, name, schema_key, schema_property_type):
            self.name = name
            self.schema_key = schema_key
            self.schema_property_type = schema_property_type

            self.export_env = ""
            self.default = ""
            self.enabled = ""

        def __str__(self):
            #print("Printing values for [{}]".format(self.name))
            #for item in self.properties:
            #    print("{} | {}".format(item['property_name'], item['value']))
            #return ""
            return "Schema Poperty Name: [{}]\nSchema Key: [{}]\nSchema Property Type: [{}]\nSchema Properties:\n\texport_env: [{}]\n\tdefault: [{}]\n\ttype: [{}]\n".format(self.name, self.schema_key, self.schema_property_type, self.export_env, self.default, self.type)
                
        def AddProperties(self, property, value):
            if property == "export_env": self.export_env = value
            if property == "default": self.default = value
            if property == "enabled": self.enabled = value
            if property == "type": self.type = value


    ignore_values = ["type", "properties", "cli", "options", root_key]
    property_values = ["export_env", "default", "type"]
    
    schema_properties_list = [item for item in schema_keys_list if item.split(".")[-1] not in ignore_values and item.split(".")[-1] not in property_values]
    schema_list = []

    for schema_properties in schema_properties_list:
        property_name = schema_properties.split(".")[-1]
        # print("Object Property Name: [{}]\n\tSchema_Key: [{}]".format(property_name, schema_properties))
        schema = SchemaObject(property_name, schema_properties, schema_properties.split(".")[2])
        for config_property in property_values:
            result = subprocess.run(["cat {} | shyaml get-value {}".format(schema_file, "{}.{}".format(schema_properties, config_property))], 
                universal_newlines = True,
                capture_output=True, 
                shell=True)
            
            found_config_value = result.stdout
            schema.AddProperties(config_property, found_config_value)
            #print("Property: [{}], Config: [{}], ValueFound: [{}]".format(property_name, config_property, found_config_value))
        schema_list.append(schema)
    
    # for schema in schema_list:
    #     print(schema)
    
    cli_config_list = [item for item in schema_list if item.schema_property_type == "cli"]
    options_config_list = [item for item in schema_list if item.schema_property_type == "options"]
    print("\n~~~~~ CLI OPTIONS ~~~~~")
    for item in cli_config_list:
        print(item)
    print("\n~~~~~ PLUGIN OPTIONS ~~~~~")
    for item in options_config_list:
        print(item)

    return "CLI options"