import os
import unittest
import subprocess
from ...plugins.utilities import add_value_to_env, load_yaml, run_cmd, handle_hooks
from ...plugins.logging import turn_off_logger

turn_off_logger()


class TestAddValueToEnv(unittest.TestCase):
    """Testing add_value_to_env utilties function"""

    def setUp(self):
        self.export_env = ""
        self.value = ""
        os.environ.clear()

    def test_add_value_to_env_with_value(self):
        """Test the add_value_to_env() function with valid value"""
        self.export_env = "ANSIBLE_VERBOSITY"
        self.value = "1"

        add_value_to_env(self.export_env, self.value)
        self.assertEqual(os.environ[self.export_env], self.value)
        self.assertEqual(os.environ["BITOPS_" + self.export_env], self.value)

    def test_add_value_to_env_with_none(self):
        """Test the add_value_to_env() function with None"""
        self.export_env = "ANSIBLE_VERBOSITY"
        self.value = None

        add_value_to_env(self.export_env, self.value)
        self.assertNotIn(self.export_env, os.environ)
        self.assertNotIn("BITOPS_" + self.export_env, os.environ)

    def test_add_value_to_env_with_list(self):
        """Test the add_value_to_env() function with a list"""
        self.export_env = "ANSIBLE_VERBOSITY"
        self.value = ["1", "2", "3"]

        add_value_to_env(self.export_env, self.value)
        self.assertEqual(os.environ[self.export_env], " ".join(self.value))
        self.assertEqual(os.environ["BITOPS_" + self.export_env], " ".join(self.value))


class TestLoadYAML(unittest.TestCase):
    """Testing load_yaml utilties function"""

    def setUp(self):
        root_dir = os.getcwd()
        self.inc_yaml = f"{root_dir}/prebuilt-config/omnibus/bitops.config.yaml"

    def test_load_yaml(self):
        """
        Test the load_yaml function.
        """
        out_yaml = load_yaml(self.inc_yaml)
        self.assertIsNotNone(out_yaml)
        self.assertIsInstance(out_yaml, dict)

    def test_load_yaml_with_required_invalid_filename(self):
        """
        Test the load_yaml function with a non-existent file.
        """
        with self.assertRaises(FileNotFoundError):
            load_yaml("invalid_file.yaml")

    def test_load_yaml_with_invalid_filename(self):
        """
        Test the load_yaml function with a non-existent file.
        """
        self.assertIsNone(load_yaml("invalid_file.yaml", required=False))


class TestRunCmd(unittest.TestCase):
    """Testing run_cmd utilties function"""

    def test_valid_run_cmd(self):
        """
        Test the run_cmd function with a valid command
        """
        process = run_cmd("ls")
        self.assertIsInstance(process, subprocess.Popen)
        self.assertTrue(process.universal_newlines)
        self.assertEqual(process.returncode, 0)
        self.assertEqual(process.args, "ls")

    def test_invalid_run_cmd(self):
        """
        Test the run_cmd function with a valid command
        """
        with self.assertRaises(Exception) as context:
            run_cmd("not_a_real_command")
        self.assertIsInstance(context.exception, FileNotFoundError)


class TestHandleHooks(unittest.TestCase):
    """Testing handle_hooks utilties function"""

    def setUp(self):
        self.original_cwd = os.getcwd()
        self.hooks_folder = f"{self.original_cwd}/scripts/tests/test_assets/bitops.before-deploy.d"
        self.source_folder = f"{self.original_cwd}/scripts/tests/test_assets"

    def tearDown(self):
        os.chdir(self.original_cwd)

    def test_handle_hooks_called_with_invalid_folder(self):
        """
        Test handle_hooks with invalid folder path
        """

        invalid_folder = "./invalid_folder"
        result = handle_hooks("before", invalid_folder, self.source_folder)
        self.assertIsNone(result)

    def test_handle_hooks_called_with_invalid_mode(self):
        """
        Test handle_hooks with invalid mode
        """
        result = handle_hooks("random_mode.exe", self.hooks_folder, self.source_folder)
        self.assertIsNone(result)

    def test_handle_hooks_called_with_valid_folder(self):
        """
        Test handle_hooks with valid folder path
        """

        result = handle_hooks("before", self.hooks_folder, self.source_folder)
        self.assertTrue(result)


if __name__ == "__main__":
    unittest.main()
