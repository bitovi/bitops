from plugins.utilities import SchemaObject

__all__ = ["PluginConfigCLI"]


class PluginConfigCLI:  # pylint: disable=too-few-public-methods
    """
    Class with rules for converting a plugin configuration objects into a CLI command.
    """

    def __init__(self, cli_config_list: [SchemaObject]):
        self.cli_config_list = cli_config_list

    def get_command(self) -> str:
        """Returns a composed CLI command string to be used in a plugin."""
        # filter out any empty values
        self.cli_config_list = list(filter(self._with_value, self.cli_config_list))

        command = []
        for c in self.cli_config_list:
            if c.parameter and c.value:
                # bool params are passed as a CLI flag `--param`
                if c.type in ["bool", "boolean"] and str(c.value).lower() == "true":
                    command.append(f"--{c.parameter}")
                # otherwise pass as `--param=value`
                else:
                    command.append(f"--{c.parameter}={c.value}")
            else:
                # if there is no parameter, just use the `value`
                command.append(c.value)

        return " ".join(command)

    def _with_value(self, item: SchemaObject) -> bool:
        """Returns True if the SchemaObject has a value."""
        return item.value
