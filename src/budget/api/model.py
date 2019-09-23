
from datetime import date as dtd

class Transaction(object):
    def __init__(self, name=None, date=None, amount=None, fitid=None, id_=None):
        self.id = id_
        self.name = name or ''
        self.date = date or dtd.today()
        self.amount = amount or 0
        self.fitid = fitid

        self.category = Category()
        self.account = Account()

        self.isMarked = False

    def isValid(self):
        return self.name and self.amount and self.date

    def exists(self):
        return self.id is not None


class Account(object):
    def __init__(self, name=None, label=None, balanceSet=None, balanceSetDate=None, id_=None):
        self.id = id_
        self.name = name or ''
        self.label = label or ''
        self.balanceSet = balanceSet or 0
        self.balanceSetDate = balanceSetDate or dtd.today()

        self.balance = 0

    def isValid(self):
        return bool(self.name)

    def exists(self):
        return self.id is not None


class Category(object):
    def __init__(self):
        self.id = None
        self.name = ''

    def isValid(self):
        return bool(self.name)

    def exists(self):
        return self.id is not None
