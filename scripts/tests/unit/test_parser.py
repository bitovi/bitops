import unittest
import os

from munch import DefaultMunch
from ...plugins.config.parser import (
    convert_yaml_to_dict,
    parse_yaml_keys_to_list,
    generate_populated_schema_list,
    generate_schema_keys,
    populate_parsed_configurations,
    get_config_list,
)
from ...plugins.config.schema import SchemaObject
from ...plugins.logging import turn_off_logger

turn_off_logger()


class TestGetConfigList(unittest.TestCase):
    def setUp(self):
        self.root_dir = os.getcwd()

    def test_get_config_list_valid_inputs(self):
        config_file = "example.config.yaml"
        schema_file = "example.schema.yaml"
        cli_config_list, options_config_list = get_config_list(
            f"{self.root_dir}/scripts/tests/test_assets/{config_file}",
            f"{self.root_dir}/scripts/tests/test_assets/{schema_file}",
        )
        self.assertIsNotNone(cli_config_list)
        self.assertIsNotNone(options_config_list)
        self.assertIsInstance(cli_config_list, list)
        self.assertIsInstance(options_config_list, list)

    def test_get_config_list_invalid_file(self):
        config_file = "invalid_config.yml"
        schema_file = "invalid_schema.yml"
        with self.assertRaises(FileNotFoundError):
            get_config_list(config_file, schema_file)

    # def test_get_config_list_missing_required_config(self):
    #     config_file = "config.yml"
    #     schema_file = "schema.yml"
    #     with self.assertRaises(SystemExit):
    #         get_config_list(config_file, schema_file)


class TestConvertYamlToDict(unittest.TestCase):
    def test_convert_yaml_to_dict_with_null_values(self):
        # Setup
        inc_yaml = {"testKey1": "testValue1", "testKey2": None}
        null_replacement = "nullReplacement"

        # Execute
        result = convert_yaml_to_dict(inc_yaml, null_replacement)

        # Assert
        self.assertEqual(result.testKey1, "testValue1")
        self.assertEqual(result.testKey0, "nullReplacement")

    def test_convert_yaml_to_dict_without_null_values(self):
        # Setup
        inc_yaml = {"testKey1": "testValue1", "testKey2": None}

        # Execute
        result = convert_yaml_to_dict(inc_yaml)

        # Assert
        self.assertEqual(result.testKey1, "testValue1")
        self.assertEqual(result.testKey2, None)

    # test_convert_yaml_to_dict_with_invalid_dict
    # Function not needed. DefaultMunch handles incorrect typing


class TestParseYamlKeysToList(unittest.TestCase):
    def setUp(self):
        self.valid_schema = {
            "terraform": {
                "type": "object",
                "properties": {
                    "cli": {
                        "type": "object",
                        "properties": {
                            "targets": {
                                "type": "list",
                                "parameter": "target",
                                "export_env": "TF_TARGETS",
                            },
                            "stack-action": {
                                "type": "string",
                                "export_env": "TERRAFORM_COMMAND",
                                "required": True,
                                "default": "plan",
                            },
                        },
                    },
                    "options": {
                        "type": "object",
                        "properties": {
                            "skip-deploy": {
                                "type": "boolean",
                                "parameter": "skip-deploy",
                                "export_env": "TERRAFORM_SKIP_DEPLOY",
                            }
                        },
                    },
                },
            },
        }
        self.root_key = "terraform"

    def test_parse_yaml_keys_to_list(self):
        """
        Test parsing yaml keys to list
        """
        expected_keys_list = [
            "terraform.type",
            "terraform.properties",
            "terraform.properties.cli",
            "terraform.properties.cli.type",
            "terraform.properties.cli.properties",
            "terraform.properties.cli.properties.targets",
            "terraform.properties.cli.properties.targets.type",
            "terraform.properties.cli.properties.targets.parameter",
            "terraform.properties.cli.properties.targets.export_env",
            "terraform.properties.cli.properties.stack-action",
            "terraform.properties.cli.properties.stack-action.type",
            "terraform.properties.cli.properties.stack-action.export_env",
            "terraform.properties.cli.properties.stack-action.required",
            "terraform.properties.cli.properties.stack-action.default",
            "terraform.properties.options",
            "terraform.properties.options.type",
            "terraform.properties.options.properties",
            "terraform.properties.options.properties.skip-deploy",
            "terraform.properties.options.properties.skip-deploy.type",
            "terraform.properties.options.properties.skip-deploy.parameter",
            "terraform.properties.options.properties.skip-deploy.export_env",
        ]
        actual_keys_list = parse_yaml_keys_to_list(self.valid_schema, self.root_key)
        self.assertListEqual(expected_keys_list, actual_keys_list)
        self.assertIsInstance(actual_keys_list, list)

    def test_parse_yaml_keys_to_list_invalid_rootkey(self):
        """
        Test prase_yaml_kwys_to_list with invalid rootkey.
        Expecting KeyError
        """
        with self.assertRaises(KeyError):
            parse_yaml_keys_to_list(self.valid_schema, "not_a_root_key")

    def test_parse_yaml_keys_to_list_invalid_schema(self):
        """
        Test prase_yaml_kwys_to_list with invalid rootkey.
        Expecting TypeError
        """
        with self.assertRaises(TypeError):
            parse_yaml_keys_to_list("not_a_schema", self.root_key)


class TestGeneratePopulatedSchemaList(unittest.TestCase):
    def setUp(self):
        self.valid_schema = {
            "terraform": {
                "type": "object",
                "properties": {
                    "cli": {
                        "type": "object",
                        "properties": {
                            "targets": {
                                "type": "list",
                                "parameter": "target",
                                "export_env": "TF_TARGETS",
                            },
                            "stack-action": {
                                "type": "string",
                                "export_env": "TERRAFORM_COMMAND",
                                "required": True,
                                "default": "plan",
                            },
                        },
                    },
                    "options": {
                        "type": "object",
                        "properties": {
                            "skip-deploy": {
                                "type": "boolean",
                                "parameter": "skip-deploy",
                                "export_env": "TERRAFORM_SKIP_DEPLOY",
                            }
                        },
                    },
                },
            },
        }
        self.config_yaml = {
            "terraform": {"cli": {"stack-action": "apply"}, "options": {"skip-deploy": True}},
        }

    def test_generate_populated_schema_list(self):
        schema_properties_list = generate_schema_keys(self.valid_schema)
        result = generate_populated_schema_list(
            convert_yaml_to_dict(self.valid_schema), schema_properties_list, self.config_yaml
        )

        self.assertEqual(len(result), 3)
        self.assertTrue(isinstance(result[0], SchemaObject))
        self.assertEqual(result[0].name, "targets")
        self.assertEqual(result[1].name, "stack-action")
        self.assertEqual(result[2].name, "skip-deploy")
        self.assertEqual(result[0].plugin, "terraform")
        self.assertEqual(result[0].export_env, "TF_TARGETS")
        self.assertEqual(result[0].default, None)
        self.assertEqual(result[1].default, "plan")
        self.assertEqual(result[0].enabled, None)
        self.assertEqual(result[0].type, "list")
        self.assertEqual(result[1].parameter, None)
        self.assertEqual(result[1].required, True)
        self.assertEqual(result[1].dash_type, None)
        self.assertEqual(result[0].description, None)


class TestGenerateSchemaKeys(unittest.TestCase):
    def test_schema_keys_list_not_empty(self):
        """Test that the generated schema keys list is not empty"""
        schema = {
            "example_schema": {"property_1": {"type": "string"}, "property_2": {"type": "integer"}}
        }
        self.assertFalse(not generate_schema_keys(schema))
        self.assertEqual(len(generate_schema_keys(schema)), 2)

    def test_schema_keys_list_contains_correct_values(self):
        """Test that the generated schema keys list contains the correct values"""
        schema = {
            "example_schema": {"property_1": {"type": "string"}, "property_2": {"type": "integer"}}
        }
        self.assertIn("example_schema.property_1", generate_schema_keys(schema))
        self.assertIn("example_schema.property_2", generate_schema_keys(schema))


class TestPopulateParsedConfigurations(unittest.TestCase):
    def setUp(self):
        self.valid_schema = {
            "terraform": {
                "type": "object",
                "properties": {
                    "cli": {
                        "type": "object",
                        "properties": {
                            "targets": {
                                "type": "list",
                                "parameter": "target",
                                "export_env": "TF_TARGETS",
                            },
                            "stack-action": {
                                "type": "string",
                                "export_env": "TERRAFORM_COMMAND",
                                "required": True,
                                "default": "plan",
                            },
                        },
                    },
                    "options": {
                        "type": "object",
                        "properties": {
                            "skip-deploy": {
                                "type": "boolean",
                                "parameter": "skip-deploy",
                                "export_env": "TERRAFORM_SKIP_DEPLOY",
                            }
                        },
                    },
                },
            },
        }
        self.config_yaml = {
            "terraform": {"cli": {"stack-action": "apply"}, "options": {"skip-deploy": True}},
        }
        schema_properties_list = generate_schema_keys(self.valid_schema)
        self.schema_list = generate_populated_schema_list(
            convert_yaml_to_dict(self.valid_schema), schema_properties_list, self.config_yaml
        )

    def test_cli_config_list(self):
        cli_config_list = populate_parsed_configurations(self.schema_list)[0]
        # for item in cli_config_list:
        # print(item)
        self.assertEqual(cli_config_list[0].schema_property_type, "cli")
        self.assertEqual(cli_config_list[1].schema_property_type, "cli")
        with self.assertRaises(IndexError):
            cli_config_list[2]

    def test_options_config_list(self):
        options_config_list = populate_parsed_configurations(self.schema_list)[1]

        self.assertEqual(options_config_list[0].schema_property_type, "options")
        with self.assertRaises(IndexError):
            options_config_list[1]

    def test_missing_required_config_list_empty_list(self):
        required_config_list = populate_parsed_configurations(self.schema_list)[2]
        self.assertFalse(required_config_list)

    def test_missing_required_config_list(self):
        test_required_schema_value = [
            SchemaObject(
                "test_config",
                "terraform.cli.test_config",
                DefaultMunch.fromDict(
                    {
                        "type": "string",
                        "export_env": "TEST_COMMAND",
                        "required": True,
                        "default": "",
                    }
                ),
            )
        ]

        self.schema_list += test_required_schema_value
        required_config_list = populate_parsed_configurations(self.schema_list)[2]
        self.assertTrue(required_config_list)
        self.assertEqual(required_config_list[0].name, "test_config")
        self.assertTrue(required_config_list[0].required)
        with self.assertRaises(IndexError):
            required_config_list[1]


if __name__ == "__main__":
    unittest.main()
