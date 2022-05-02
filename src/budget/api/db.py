
import os
import sqlite3
from .db_init import createTables
from .model import Account, Transaction
from datetime import date as dtd


class Db(object):
    _instance = None

    @classmethod
    def Get(cls, dbPath='budget'):
        if not cls._instance:
            cls._instance = cls(dbPath)
        return cls._instance

    def __init__(self, path):
        self._dbPath = os.path.expandvars(path)
        self._dbFile = os.path.join(self._dbPath, 'budget.db')
        self._db = None

        if not os.path.exists(self._dbPath):
            self._makeDb()

        self._connect()

    def path(self):
        return self._dbPath

    def _makeDb(self):
        print('Creating DB: %s' % self._dbPath)
        try:
            os.makedirs(self._dbPath)
        except:
            pass

        db = sqlite3.connect(self._dbFile)
        createTables(db)

    def _connect(self):
        print('Connecting DB: %s' % self._dbFile)
        self._db = sqlite3.connect(self._dbFile,
                                   detect_types = sqlite3.PARSE_DECLTYPES |
                                                  sqlite3.PARSE_COLNAMES
                                   )
        self._db.row_factory = sqlite3.Row

    def accountByName(self, name):
        c = self._db.execute('SELECT * from accounts '
                             'WHERE name = ? '
                             'LIMIT 1', (name,))
        item = c.fetchone()
        if not item:
            return Account(name=name)

        return self._createAccountFromDict(item)

    def accountByIds(self, ids):
        if not ids:
            return []

        query = f"SELECT * FROM accounts WHERE id in ({','.join(['?']*len(ids))})"
        c = self._db.execute(query, list(ids))
        items = c.fetchall()
        return [self._createAccountFromDict(item) for item in items]

    def _createAccountFromDict(self, d):
        return Account(name=d['name'],
                       label=d['label'],
                       balanceSet=d['balanceSet'],
                       balanceSetDate=d['balanceSetDate'],
                       id_=d['id'],
                       )

    def transactions(self, ft=None):
        # temp: filter as a string by name or accountName only. Replace by proper filter object
        if ft:
            c = self._db.execute('SELECT * from transactions '
                                 'WHERE name LIKE ? '
                                 'ORDER BY date DESC, name', ('%{}%'.format(ft),))
        else:
            c = self._db.execute('SELECT * from transactions '
                                 'ORDER BY date DESC, name')

        items = c.fetchall()
        transactions = [self._createTransactionFromDict(item) for item in items]

        # process accounts and categories
        accountIds = {item['accountId'] for item in items}
        categoryIds = {item['categoryId'] for item in items}

        accounts = self.accountByIds(accountIds)
        accountById = {a.id: a for a in accounts}
        for transaction in transactions:
            transaction.account = accountById.get(transaction.accountId, Account())

        return transactions

    def _createTransactionFromDict(self, d):
        t = Transaction(name=d['name'],
                           date=dtd.fromisoformat(d['date']),
                           amount=d['amount'],
                           fitid=d['fitid'],
                           id_=d['id'],
                           )
        t.accountId = d['accountId']
        t.categoryId = d['categoryId']
        return t

    def recordAccount(self, account):
        c = self._db.execute("INSERT INTO accounts(name, label, balanceSet, balanceSetDate) VALUES (?, ?, ?, ?)",
                             (account.name, account.label, account.balanceSet, account.balanceSetDate))
        account.id = c.lastrowid
        self._db.commit()

    def recordTransaction(self, transaction, commit=True):
        account = transaction.account
        if not account.exists():
            self.recordAccount(account)

        c = self._db.execute("INSERT INTO transactions(name, date, amount, fitid, accountId, categoryId) "
                             "VALUES (?, ?, ?, ?, ?, ?)",
                             (transaction.name, transaction.date.isoformat(), transaction.amount,
                              transaction.fitid, transaction.account.id, transaction.category.id))
        transaction.id = c.lastrowid
        if commit:
            self._db.commit()

    def recordTransactions(self, transactions):
        import time
        start = time.time()
        [self.recordTransaction(t, commit=False) for t in transactions]
        self._db.commit()
        end = time.time()
        print(f'Recording {len(transactions)} took {(end-start)*1000:02}ms')
