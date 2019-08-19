import unittest
import tempfile
from datetime import  date as dtd

from budget.api.db import Db
from budget.api.model import Transaction, Account


class SqlTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.f = tempfile.TemporaryDirectory()

    def tearDown(self) -> None:
        self.f.cleanup()

    def test_dbCreation(self):
        db = Db(path=self.f.name + '/tmp')
        self.assertEqual(db.path(), self.f.name + '/tmp')

    def test_accountByName_when_it_does_not_exists(self):
        db = Db(path=self.f.name + '/tmp')
        account = db.accountByName('test')
        self.assertTrue(account.isValid())
        self.assertFalse(account.exists())

    def test_accountByIds(self):
        db = Db(path=self.f.name + '/tmp')
        db.recordAccount(Account(name='one'))
        db.recordAccount(Account(name='two'))
        db.recordAccount(Account(name='three'))

        accounts = db.accountByIds([1, 3])

        self.assertEqual(2, len(accounts))
        self.assertEqual({'one', 'three'}, {a.name for a in accounts})

    def test_recordAccount(self):
        db = Db(path=self.f.name + '/tmp')
        account = db.accountByName('test')
        db.recordAccount(account)
        self.assertTrue(account.isValid())
        self.assertTrue(account.exists())

    def test_accountByName_when_it_exists(self):
        db = Db(path=self.f.name + '/tmp')
        account = db.accountByName('test')
        db.recordAccount(account)
        account2 = db.accountByName('test')
        self.assertEqual(account.id, account2.id)

    def test_recordTransactions(self):
        db = Db(path=self.f.name + '/tmp')
        account = Account(name='test')
        db.recordAccount(account)
        transaction = Transaction()
        transaction.name = 'test'
        transaction.amount = 3
        transaction.account = account
        db.recordTransaction(transaction)
        self.assertTrue(transaction.isValid())
        self.assertTrue(transaction.exists())

    def test_listTransactions(self):
        db = Db(path=self.f.name + '/tmp')
        accountOne = Account(name='one')
        accountTwo = Account(name='two')
        db.recordAccount(accountOne)
        db.recordAccount(accountTwo)
        t1 = Transaction(name="a", date=dtd.today(), amount=123)
        t1.account = accountOne
        t2 = Transaction(name="b", date=dtd.today(), amount=2000)
        t2.account = accountTwo
        t3 = Transaction(name="ab", date=dtd.today(), amount=3.00)
        t3.account = accountTwo
        db.recordTransactions([t1, t2, t3])

        transactions = db.transactions('a')
        self.assertEqual({'a', 'ab'}, {t.name for t in transactions})


if __name__ == '__main__':
    unittest.main()
