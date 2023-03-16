import os
import unittest
import subprocess

from ..plugins.utilities import add_value_to_env, load_yaml, run_cmd


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


if __name__ == "__main__":
    unittest.main()
