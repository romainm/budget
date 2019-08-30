
import sys
import os

from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtWidgets import QApplication
from budget.api.ofxparser import OFXParser
from budget.api.db import Db
import sqlite3

from PySide2.QtCore import (
    Qt,
    QDate,
    QObject,
    QUrl,
    Property,
    Slot,
    QAbstractListModel,
    QModelIndex,
    QSortFilterProxyModel,
)


class ProxyModel(QSortFilterProxyModel):

    @Slot(str)
    def setFilterString(self, ft):
        self.setFilterCaseSensitivity(Qt.CaseInsensitive)
        self.setFilterFixedString(ft)

    @Property(float)
    def amount(self, index):
        return 12
        return self._transactions[index].amount


class TransactionModel(QAbstractListModel):
    NameRole = Qt.UserRole + 1000
    AmountRole = Qt.UserRole + 1001
    DateRole = Qt.UserRole + 1002
    CategoryRole = Qt.UserRole + 1003
    AccountRole = Qt.UserRole + 1004
    AmountNumRole = Qt.UserRole + 1005

    def __init__(self, parent=None):
        super(TransactionModel, self).__init__(parent)

        # Each item is a dictionary of key/value pairs
        self._transactions = []

    def setTransactions(self, transactions):
        self.beginResetModel()
        self._transactions = transactions
        self.endResetModel()

    def transactions(self):
        return self._transactions

    def clear(self):
        self.setTransactions([])

    def data(self, index, role=Qt.DisplayRole):
        if 0 <= index.row() < self.rowCount() and index.isValid():
            transaction = self._transactions[index.row()]
            if role == self.NameRole:
                return transaction.name
            elif role == self.AmountRole:
                return '{:.2f}'.format(transaction.amount)
            elif role == self.AmountNumRole:
                return transaction.amount
            elif role == self.DateRole:
                return QDate(transaction.date)
            elif role == self.CategoryRole:
                return transaction.category.name
            elif role == self.AccountRole:
                return transaction.account.name

        return None

    def setData(self, index, value, role):
        print('setData', value)

    def rowCount(self, parent=QModelIndex()):
        return len(self._transactions)

    def roleNames(self):
        """Role names are used by QML to map key to role"""
        print('rolenames called')
        roles = dict()
        roles[self.NameRole] = b"name"
        roles[self.AmountRole] = b"amount"
        roles[self.AmountNumRole] = b"amountNum"
        roles[self.DateRole] = b"date"
        roles[self.CategoryRole] = b"category"
        roles[self.AccountRole] = b"account"
        return roles


class Backend(QObject):

    def __init__(self, parent=None):
        super(Backend, self).__init__(parent=parent)

        self._db = Db.Get()
        self._transactionModel = TransactionModel()
        self._transactionModel.setTransactions(self._db.transactions())

        self._transactionImportModel = TransactionModel()

        self._transactionModelProxy = ProxyModel()
        self._transactionModelProxy.setSourceModel(self._transactionModel)
        self._transactionModelProxy.setFilterRole(TransactionModel.NameRole)

        self._transactionImportModelProxy = ProxyModel()
        self._transactionImportModelProxy.setSourceModel(self._transactionImportModel)
        self._transactionImportModelProxy.setFilterRole(TransactionModel.NameRole)

    def transactionModel(self):
        return self._transactionModelProxy

    def transactionImportModel(self):
        return self._transactionImportModelProxy

    @Slot('QVariantList')
    def loadFiles(self, filePaths):
        print('loading files: %s' % filePaths)
        for path in filePaths:
            parsedTransactions = OFXParser(self._db).parse_file(QUrl(path).toLocalFile())
            print(f'Loaded {len(parsedTransactions.transactions)} transactions.')
            # self._db.recordTransactions(parsedTransactions.transactions)
            self._transactionImportModel.setTransactions(parsedTransactions.transactions)

    @Slot()
    def recordTransactions(self):
        self._db.recordTransactions(self._transactionImportModel.transactions())
        self._transactionModel.setTransactions(self._db.transactions())
        self._transactionImportModel.clear()


if __name__ == "__main__":
    app = QApplication(sys.argv)

    transactionModel = TransactionModel()

    backend = Backend()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("backend", backend)
    engine.rootContext().setContextProperty("transactionModel", backend.transactionModel())
    engine.rootContext().setContextProperty("transactionImportModel", backend.transactionImportModel())
    engine.load('../qml/main.qml')
    sys.exit(app.exec_())
