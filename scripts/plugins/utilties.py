import yaml
import shyaml
import os

config_file = "build.config.yaml"

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
    print("Converting... Schema: [{}], Config: [{}]".format(schema_file, config_file))

    def Parse_Yaml_To_List(schema, root_key=None, key_chain=None):
        keys_list = []
        if key_chain is None: key_chain = root_key

        for property in schema[root_key].keys():
            inner_schema = schema[root_key]
            key_value = "{}.{}".format(key_chain, property)
            keys_list.append(key_value)
            try:
                keys_list+=Parse_Yaml_To_List(inner_schema, property, key_value)
            except AttributeError as e:
                # End of keys for property, continue to move on to next key
                continue
        return keys_list
                
    
    with open(schema_file) as schema_fh:
        try:
            schema_yaml = yaml.load(schema_fh, Loader=yaml.FullLoader)

            keys_list = []
            root_keys = list(schema_yaml.keys())
            root_key = root_keys[0]
            keys_list.append(root_key)

            keys_list += Parse_Yaml_To_List(schema_yaml, root_key)
            print("Schema keys: [{}]".format(keys_list))
            

        except yaml.YAMLError as exc:
            print(exc)
        except Exception as exc:
            print(exc)
        
        
        print("Done")

    return "Finished"