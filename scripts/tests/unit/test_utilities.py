import os
import unittest
import subprocess
from unittest.mock import patch

from ...plugins.utilities import add_value_to_env, load_yaml, run_cmd, handle_hooks


class TestAddValueToEnv(unittest.TestCase):
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
    """
    Class for testing the load_yaml function.
    """

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

    # def test_load_yaml_with_invalid_filename(self):
    #     """
    #     Test the load_yaml function with a non-existent file.
    #     """
    #     with self.assertRaises(FileNotFoundError):
    #         load_yaml("invalid_file.yaml")


class TestRunCmd(unittest.TestCase):
    def setUp(self):
        self.command = "ls"

    def test_run_cmd(self):
        process = run_cmd(self.command)
        self.assertIsInstance(process, subprocess.Popen)
        self.assertEqual(process.stdout, subprocess.PIPE)
        self.assertEqual(process.stderr, subprocess.STDOUT)
        self.assertTrue(process.universal_newlines)
        self.assertIsNotNone(process.communicate())


class TestHandleHooks(unittest.TestCase):
    def setUp(self):
        self.hooks_folder = "./test_folder/hooks"
        self.source_folder = "./test_folder/source"
        self.hook_script = "test_script.sh"
        self.mode = "before"
        self.original_cwd = os.getcwd()

    def tearDown(self):
        os.chdir(self.original_cwd)

    def test_handle_hooks_called_with_invalid_folder(self):
        """
        Test handle_hooks with invalid folder path
        """
        invalid_folder = "./invalid_folder"
        result = handle_hooks(self.mode, invalid_folder, self.source_folder)
        self.assertIsNone(result)

    def test_handle_hooks_called_with_valid_folder(self):
        """
        Test handle_hooks with valid folder path
        """
        valid_folder = "./test_folder"
        result = handle_hooks(self.mode, valid_folder, self.source_folder)
        self.assertIsInstance(result, subprocess.Popen)

    @patch("subprocess.Popen")
    def test_handle_hooks_called_with_valid_hook_script(self, mock_subprocess_popen):
        """
        Test handle_hooks with valid hook script
        """
        valid_hook_script = "test_script.sh"
        result = handle_hooks(self.mode, self.hooks_folder, self.source_folder)
        mock_subprocess_popen.assert_called_with(["bash", valid_hook_script])
        self.assertIsInstance(result, subprocess.Popen)

    def test_handle_hooks_called_with_invalid_hook_script(self):
        """
        Test handle_hooks with invalid hook script
        """
        invalid_hook_script = "invalid_script.sh"
        result = handle_hooks(self.mode, self.hooks_folder, self.source_folder)
        self.assertIsInstance(result, subprocess.Popen)  # Should still return a Popen instance


if __name__ == "__main__":
    unittest.main()
