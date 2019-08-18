
import os
import sqlite3
from .db_init import createTables
from .model import Account


class Db(object):
    _instance = None

    @classmethod
    def Get(cls, dbPath='$HOME/budget'):
        if not cls._instance:
            cls._instance = cls(dbPath)
        return cls._instance

    def __init__(self, path):
        self._dbPath = path
        self._dbFile = os.path.join(os.path.expandvars(self._dbPath), 'budget.db')
        self._db = None

        if not os.path.exists(self._dbPath):
            self._makeDb()
        else:
            self._connect()

    def path(self):
        return self._dbPath

    def _makeDb(self):
        try:
            os.makedirs(self._dbPath)
        except:
            pass

        db = sqlite3.connect(self._dbFile)
        createTables(db)

    def _connect(self):
        self._db = sqlite3.connect(self._dbfile)
        self._db.row_factory = sqlite3.Row

    def addTransactions(self, transactions):
        c = self._db.cursor()
        for t in transactions:
            c.execute("INSERT INTO transactions(name, date, amount) VALUES (?, ?, ?)", (t["name"], t["date"], t["amount"]))
        self._db.commit()

    def accountByName(self, name):
        c = self._db.cursor()
        items = c.execute('SELECT * from accounts WHERE name = ? LIMIT 1', (name,))
        if not items:
            return Account(name=name)

        return self._createAccountFromDict(items[0])

    def _createAccountFromDict(self, d):
        return Account(name=d['name'],
                       label=d['label'],
                       balanceSet=d['balanceSet'],
                       balanceSetDate=d['balanceSetDate'],
                       id_=d['id'],
                       )

