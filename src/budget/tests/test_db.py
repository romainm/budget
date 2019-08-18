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


if __name__ == '__main__':
    unittest.main()
