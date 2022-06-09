import unittest
from pkg_resources import resource_filename
from budget.api._ofxparser import OFXParser
from budget.api.model import Transaction


class MyTestCase(unittest.TestCase):
    def test_something(self):
        parser = OFXParser()
        parsedTransactions = parser.parse_file(resource_filename(__name__, 'test_data/test1.ofx'))
        from pprint import pprint
        pprint(parsedTransactions)

        self.assertEqual(len(parsedTransactions), 80)
        self.assertTrue(isinstance(parsedTransactions[0], Transaction))


if __name__ == '__main__':
    unittest.main()
