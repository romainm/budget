
import sys
import os

from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtWidgets import QApplication
from budget.api.ofxparser import OFXParser
from budget.api.db import Db

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

    @Slot()
    def unselectAll(self):
        self.sourceModel().unselectAll()

    @Slot(int, int)
    def selectBlock(self, start, end):

        start_ = min(start, end)
        end_ = max(start, end)
        selectedIndices = {self.mapToSource(self.index(i, 0)) for i in range(start_, end_+1)}
        self.sourceModel().selectIndices(selectedIndices)

    @Slot()
    def flagSelectedItems(self):
        self.sourceModel().flagSelectedItems()

    @Slot()
    def unflagSelectedItems(self):
        self.sourceModel().unflagSelectedItems()

class TransactionModel(QAbstractListModel):
    NameRole = Qt.UserRole + 1000
    AmountRole = Qt.UserRole + 1001
    DateRole = Qt.UserRole + 1002
    CategoryRole = Qt.UserRole + 1003
    AccountRole = Qt.UserRole + 1004
    AmountNumRole = Qt.UserRole + 1005
    FlaggedRole = Qt.UserRole + 1006
    SelectRole = Qt.UserRole + 1007

    def __init__(self, parent=None):
        super(TransactionModel, self).__init__(parent)

        # Each item is a dictionary of key/value pairs
        self._transactions = []
        self._flaggedIndices = set()
        self._selectedIndices = set()

    def setTransactions(self, transactions):
        self.beginResetModel()
        self._transactions = transactions
        self._flaggedIndices = set()
        self.endResetModel()

    def transactions(self):
        return self._transactions

    def unselectAll(self):
        self._selectedIndices = set()
        self.dataChanged.emit(self.index(0,0), self.index(self.rowCount()-1, 0))

    def selectIndices(self, modelIndices):
        currentMin = min([i.row() for i in self._selectedIndices])
        currentMax = max([i.row() for i in self._selectedIndices])
        self._selectedIndices = set(modelIndices)
        self.dataChanged.emit(self.index(currentMin,0), self.index(currentMax, 0))

        [self.dataChanged.emit(m, m) for m in modelIndices]

    def flagSelectedItems(self):
        for i in self._selectedIndices:
            if i not in self._flaggedIndices:
                self._flaggedIndices.add(i)
                self.dataChanged.emit(i, i)

    def unflagSelectedItems(self):
        for i in self._selectedIndices:
            if i in self._flaggedIndices:
                self._flaggedIndices.remove(i)
                self.dataChanged.emit(i, i)

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
            elif role == self.FlaggedRole:
                return index in self._flaggedIndices
            elif role == self.SelectRole:
                return index in self._selectedIndices

        return None

    def setData(self, index, value, role):
        if role == self.FlaggedRole:
            if value:
                self._flaggedIndices.add(index)
            else:
                self._flaggedIndices.remove(index)
            self.dataChanged.emit(index, index)
            return True
        elif role == self.SelectRole:
            if value:
                self._selectedIndices.add(index)
            else:
                self._selectedIndices.remove(index)
            self.dataChanged.emit(index, index)
            return True
        return False

    def rowCount(self, parent=QModelIndex()):
        return len(self._transactions)

    def roleNames(self):
        """Role names are used by QML to map key to role"""
        roles = dict()
        roles[self.NameRole] = b"name"
        roles[self.AmountRole] = b"amount"
        roles[self.AmountNumRole] = b"amountNum"
        roles[self.DateRole] = b"date"
        roles[self.CategoryRole] = b"category"
        roles[self.AccountRole] = b"account"
        roles[self.FlaggedRole] = b"flagged"
        roles[self.SelectRole] = b"selected"
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
            self._transactionImportModel.setTransactions(parsedTransactions.transactions)

    @Slot()
    def recordTransactions(self):
        self._db.recordTransactions(self._transactionImportModel.transactions())
        self._transactionModel.setTransactions(self._db.transactions())
        self._transactionImportModel.clear()


if __name__ == "__main__":
    app = QApplication(sys.argv)

    backend = Backend()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("backend", backend)
    engine.rootContext().setContextProperty("transactionModel", backend.transactionModel())
    engine.rootContext().setContextProperty("transactionImportModel", backend.transactionImportModel())
    engine.load('../qml/main.qml')
    sys.exit(app.exec_())
