import unittest
from pkg_resources import resource_filename
from budget.ofxparser import OFXParser


class MyTestCase(unittest.TestCase):
    def test_something(self):
        parser = OFXParser()
        parsedTransactions = parser.parse_file(resource_filename(__name__, 'test_data/test1.ofx'))
        from pprint import pprint
        pprint(parsedTransactions.transactions)

        self.assertEqual(parsedTransactions.accountName, '')


if __name__ == '__main__':
    unittest.main()
