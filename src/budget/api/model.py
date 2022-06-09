
from datetime import date as dtd


class Transaction(object):
    def __init__(self, accountId, name=None, date=None, amount=None, fitid=None, id_=None):
        self.id = id_
        self.name = name or ''
        self.date = date or dtd.today()
        self.amount = amount or 0
        self.fitid = fitid

        self.category = None
        self.accountId = accountId

        self.isMarked = False
        if self.fitid:
            hashStr = fitid
        else:
            hashStr = accountId + name + str(self.date) + str(self.amount)
        self._hash = hash(hashStr)

    def hash(self):
        return self._hash

    def isValid(self):
        return self.accountId and self.name and self.amount and self.date

    def exists(self):
        return self.id is not None

    def __repr__(self):
        return f"Transaction('{self.name}', '{self.date}', {self.amount}, '{self.category.name if self.category else '-'}')"


class Account(object):
    def __init__(self, accountId, label=None, balanceSet=None, balanceSetDate=None, id_=None):
        self.id = id_
        self.accountId = accountId or ''
        self.label = label or ''
        self.balanceSet = balanceSet or 0
        self.balanceSetDate = balanceSetDate or dtd.today()

        self.balance = 0

    def isValid(self):
        return bool(self.accountId)

    def exists(self):
        return self.id is not None

    def __repr__(self):
        return f"Account('{self.accountId}', '{self.label}', {self.balanceSet}, '{self.balanceSetDate}')"

class Category(object):
    def __init__(self, name=None):
        self.id = None
        self.name = name or ''

    def isValid(self):
        return bool(self.name)

    def exists(self):
        return self.id is not None

    def __repr__(self):
        return f"Category('{self.name}')"