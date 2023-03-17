import os
import sys
import subprocess
from typing import Union
import yaml

from .settings import BITOPS_FAST_FAIL_MODE
from .logging import logger, mask_message


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


def load_yaml(inc_yaml, required=True):
    """
    This function attempts to load a YAML file from a given location,
    and exits if the file is not found. It returns the loaded YAML file if successful.
    """
    out_yaml = None
    try:
        with open(inc_yaml, "r", encoding="utf8") as stream:
            out_yaml = yaml.load(stream, Loader=yaml.FullLoader)
    except FileNotFoundError as e:
        if required:
            logger.error(
                f"Required file was not found. \
                    To fix this please add the following file: [{e.filename}]"
            )
            logger.debug(e)
            raise e

    return out_yaml


def run_cmd(command: Union[list, str]) -> subprocess.Popen:
    """Run a linux command and return Popen instance as a result"""
    try:
        with subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        ) as process:
            combined_output = ""
            for output in process.stdout:
                # TODO: parse output for secrets
                # TODO: specify plugin and output tight output (no extra newlines)
                # TODO: can we modify a specific handler to add handler.terminator = "" ?
                # TODO: This should be updated to use logger if possible
                # TODO: This should have a quiet option
                combined_output.join(output)
            logger.info(mask_message(combined_output))

            # This polls the async function to get information
            # about the status of the process execution.
            # Namely the return code which is used elsewhere.
            process.communicate()
            return process

    except Exception as exc:
        logger.error(exc)
        raise exc


def handle_hooks(mode, hooks_folder, source_folder):
    """
    Processes a bitops before/after hook by invoking bash script(s) within the hooks folder(s).
    """
    # Checks if the folder exists, if not, move on
    if not os.path.isdir(hooks_folder):
        return
    if mode not in ["before", "after"]:
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

        try:
            result = run_cmd(["bash", plugin_before_hook_script_path])
        except Exception:
            sys.exit(101)
        if result.returncode == 0:
            logger.info(f"~#~#~#~{umode} HOOK [{hook_script}] SUCCESSFULLY COMPLETED~#~#~#~")
            logger.debug(result.stdout)
        else:
            logger.warning(f"~#~#~#~{umode} HOOK [{hook_script}] FAILED~#~#~#~")
            logger.debug(result.stdout)
            if BITOPS_FAST_FAIL_MODE:
                sys.exit(result.returncode)

    os.chdir(original_directory)
    return True
