import unittest


class TestHello(unittest.TestCase):
    """Basic test example demonstrating the hello world."""

    def test_hello(self):
        """Test hello world."""
        self.assertEqual(True, True)


if __name__ == "__main__":
    unittest.main()
