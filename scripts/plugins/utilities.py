import os
import sys
import yaml
import subprocess

from typing import Union
from .settings import BITOPS_fast_fail_mode
from .logging import logger, mask_message
from .doc import get_doc


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
