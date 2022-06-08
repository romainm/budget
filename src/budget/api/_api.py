
from budget.api.model import Category, Transaction, Account

from PySide6.QtCore import (
    QObject,
    Signal
)

class Api(QObject):

    categoriesChanged = Signal()

    def __init__(self, store) -> None:
        QObject.__init__(self)
        self._store = store

    def transactions(self):
        return self._store.transactions()

    def categories(self):
        return self._store.categories()

    def accounts(self):
        return self._store.accounts()

    def account(self, accountId):
        return self._store.account(accountId)

    def createTransaction(self, accountId, name, date, amount, fitid=None):
        return Transaction(accountId, name, date, amount, fitid)

    def createCategory(self, name):
        existingCategory = self._store.category(name)
        if existingCategory:
            return existingCategory

        return Category(name)

    def createAccount(self, accountId, accountLabel=None):
        existingAccount = self._store.account(accountId)
        if existingAccount:
            return existingAccount

        return Account(accountId, accountLabel)

    def recordTransactions(self, transactions):
        # ensure accounts exist.
        accountIds = {t.accountId for t in transactions if self._store.account(t.accountId) is None}
        for accountId in accountIds:
            self._store.recordAccount(self.createAccount(accountId))

        # ensure categories exist.
        categories = {t.category for t in transactions if t.category}
        for category in categories:
            if self._store.category(category.name) is None:
                self._store.recordCategory(category)

        self._store.recordTransactions(transactions)
        return

    def recordCategory(self, category):
        self._store.recordCategory(category)
        self.categoriesChanged.emit()

    def recordAccount(self, account):
        self._store.recordAccount(account)

    def setCategory(self, categoryName, transactions):
        category = self._store.category(categoryName)
        if not category:
            category = Category(categoryName)
            self.recordCategory(category)
        for t in transactions:
            t.category = category
