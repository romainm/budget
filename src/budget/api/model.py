
from datetime import date

class Transaction(object):
    def __init__(self):
        self.id = None
        self.name = ''
        self.date = date.today()
        self.amount = 0
        self.fitid = None
        self.category = Category()
        self.account = Account()

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
        self.balanceSetDate = balanceSetDate or date.today()

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
