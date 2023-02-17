import os

from plugins.utilities import SchemaObject

__all__ = ["PluginConfigCLI"]


class PluginConfigCLI:
    """
    Class with rules for converting a list of plugin configuration objects into a CLI command.
    """

    PROPERTY_TYPE_WHITELIST = ["string", "integer", "boolean", "bool"]
    """
    Supported config parameter types to be composed as CLI args.
    """

    def __init__(self, cli_config_list: [SchemaObject]):
        self.cli_config_list = cli_config_list

    @property
    def env(self) -> str:
        """
        Generate an ENV variable name to be exported to the plugin.
        `BITOPS_<PLUGIN>_CLI`
        """
        if self.cli_config_list:
            plugin = self.cli_config_list[0].plugin
        else:
            plugin = os.environ.get("BITOPS_PLUGIN_NAME")

        if not plugin:
            raise ValueError("No plugin name provided for CLI environment variable.")

        return f"BITOPS_{plugin.upper()}_CLI"

    @property
    def command(self) -> str:
        """Generate a composed CLI command string to be used in a plugin."""
        command = []
        for c in self.cli_config_list:
            # TODO: Add support for objects and lists
            if c.type not in self.PROPERTY_TYPE_WHITELIST:
                continue
            # filter out any empty values
            if not c.value:
                continue

            if c.parameter:
                # bool params are passed as a CLI flag `--param`
                if c.type in ["bool", "boolean"] and str(c.value).lower() == "true":
                    command.append(f"--{c.parameter}")
                # otherwise pass as `--param=value`
                else:
                    command.append(f"--{c.parameter}={c.value}")
            else:
                # if there is no parameter, just use the `value` (treat as CLI positional argument)
                command.append(c.value)

        return " ".join(command)
