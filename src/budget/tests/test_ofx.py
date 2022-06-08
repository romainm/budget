import unittest
from pkg_resources import resource_filename
from budget.api.ofxparser import OFXParser
from budget.api.model import Account, Transaction

class DumbApi(object):
    def account(self, name):
        return Account(name)


class MyTestCase(unittest.TestCase):
    def test_something(self):
        parser = OFXParser(DumbApi())
        parsedTransactions = parser.parse_file(resource_filename(__name__, 'test_data/test1.ofx'))
        from pprint import pprint
        pprint(parsedTransactions.transactions)

        self.assertEqual(parsedTransactions.account.name, '072015-10000000')
        self.assertEqual(len(parsedTransactions.transactions), 80)
        self.assertTrue(isinstance(parsedTransactions.transactions[0], Transaction))


if __name__ == '__main__':
    unittest.main()
