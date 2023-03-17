import unittest
import os

from ...plugins.config.schema import SchemaObject, UnSupportDataType

from ...plugins.logging import turn_off_logger

turn_off_logger()


class TestSchemaObject(unittest.TestCase):
    """Testing the SchemaObject"""

    def setUp(self):
        self.name = "test_name"
        self.schema_key = "test.cli.example_string_object"
        self.schema_property_values = {
            "export_env": "TEST_ENV",
            "default": "NO DEFAULT FOUND",
            "enabled": False,
            "type": "string",
            "parameter": "test_name",
            "dash_type": "",
            "required": True,
            "description": None,
        }
        self.test_obj = SchemaObject(self.name, self.schema_key, self.schema_property_values)

    def test_init_set_properties(self):
        """Test SchemaObject __init__ function"""
        self.assertEqual(self.test_obj.name, self.name)
        self.assertEqual(self.test_obj.plugin, "test")
        self.assertEqual(self.test_obj.schema_key, self.schema_key)
        self.assertEqual(self.test_obj.config_key, "test.cli.example_string_object")
        self.assertEqual(self.test_obj.value, "")
        self.assertEqual(self.test_obj.schema_property_type, "cli")
        self.assertEqual(self.test_obj.export_env, "TEST_ENV")
        self.assertEqual(self.test_obj.default, "NO DEFAULT FOUND")
        self.assertFalse(self.test_obj.enabled)
        self.assertEqual(self.test_obj.type, "string")
        self.assertEqual(self.test_obj.parameter, "test_name")
        self.assertEqual(self.test_obj.dash_type, "")
        self.assertTrue(self.test_obj.required)

    def test_env(self):
        """Test SchemaObject self.env value setter"""
        self.assertEqual(self.test_obj.env, "BITOPS_TEST_TEST_NAME")

    def test_process_config(self):
        """Test SchemaObject process_config function"""
        # test default
        self.test_obj.process_config({})
        self.assertEqual(self.test_obj.value, self.test_obj.default)

        # test value from config
        self.test_obj.process_config({"test": {"cli": {"example_string_object": "config_value"}}})
        self.assertEqual(self.test_obj.value, "config_value")

        # test value from env
        os.environ["BITOPS_TEST_TEST_NAME"] = "env_value"
        self.test_obj.process_config({})
        self.assertEqual(self.test_obj.value, "env_value")

    def test_get_nested_item(self):
        """Test SchemaObject get_nested_item function"""
        search_dict = {"test": {"properties": "value"}}
        key = "test.properties"
        result = SchemaObject.get_nested_item(search_dict, key)
        self.assertEqual(result, "value")

    def test_apply_data_type(self):
        """Test SchemaObject apply_data_type function"""
        # test string
        result = SchemaObject._apply_data_type("string", "value")
        self.assertEqual(result, "value")

        # test int
        result = SchemaObject._apply_data_type("int", "3")
        self.assertEqual(result, 3)

        # test boolean
        result = SchemaObject._apply_data_type("boolean", "true")
        self.assertTrue(result)

        # test list
        result = SchemaObject._apply_data_type("list", ["a", "b", "c"])
        self.assertEqual(result, ["a", "b", "c"])

        # test invalid
        with self.assertRaises(UnSupportDataType):
            SchemaObject._apply_data_type("invalid", "value")


if __name__ == "__main__":
    unittest.main()
