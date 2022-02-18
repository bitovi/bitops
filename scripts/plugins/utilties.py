import yaml

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