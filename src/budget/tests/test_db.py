import unittest
import tempfile

from budget.api.db import Db


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

    def test_insertAccount(self):
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


if __name__ == '__main__':
    unittest.main()
