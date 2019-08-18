
import sys
import os

from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtWidgets import QApplication
from budget.api.ofxparser import OFXParser
from budget.api.db import Db
import sqlite3

from PySide2.QtCore import (
    Qt,
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

class Model(QAbstractListModel):
    NameRole = Qt.UserRole + 1000
    AmountRole = Qt.UserRole + 1001
    DateRole = Qt.UserRole + 1002
    CategoryRole = Qt.UserRole + 1003
    AccountRole = Qt.UserRole + 1004
    AmountNumRole = Qt.UserRole + 1005

    def __init__(self, parent=None):
        super(Model, self).__init__(parent)

        # Each item is a dictionary of key/value pairs
        self._items = []

    def setItems(self, items):
        self.beginResetModel()
        self._items = items
        self.endResetModel()

    def data(self, index, role=Qt.DisplayRole):
        if 0 <= index.row() < self.rowCount() and index.isValid():
            item = self._items[index.row()]
            if role == self.NameRole:
                return item["name"]
            elif role == self.AmountRole:
                return '{:.2f}'.format(item["amount"])
            elif role == self.AmountNumRole:
                return item["amount"]
            elif role == self.DateRole:
                return str(item["date"])
            elif role == self.CategoryRole:
                return item.get("category", 'test')
            elif role == self.AccountRole:
                return item.get("account", 'Smart Access')

        return None

    def setData(self, index, value, role):
        print('setData', value)

    def rowCount(self, parent=QModelIndex()):
        return len(self._items)

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

    def __init__(self, model, parent=None):
        super(Backend, self).__init__(parent=parent)
        self._model = model

        self._db = Db.Get()

    @Property(QAbstractListModel)
    def transactionModel(self):
        return self._model

    @Slot('QVariantList')
    def loadFiles(self, filePaths):
        print('loading files: %s' % filePaths)
        for path in filePaths:
            parsedTransactions = OFXParser().parse_file(QUrl(path).toLocalFile())
            print(f'Loaded {len(parsedTransactions.transactions)} transactions.')
            self._model.setItems(parsedTransactions.transactions)

    def loadFile(self, filePath):
        parsedTransactions = OFXParser().parse_file(filePath)
        print(f'Loaded {len(parsedTransactions.transactions)} transactions.')
        self._model.setItems(parsedTransactions.transactions)
        print(parsedTransactions.transactions)
        self._db.addTransactions(parsedTransactions.transactions)


if __name__ == "__main__":
    app = QApplication(sys.argv)

    model = Model()
    filterModel = ProxyModel()
    filterModel.setSourceModel(model)
    filterModel.setFilterRole(Model.NameRole)

    backend = Backend(model)
    backend.loadFile('/home/romain/earlwood.ofx')

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("backend", backend)
    engine.rootContext().setContextProperty("transactionModel", filterModel)
    engine.load('qml/main.qml')
    sys.exit(app.exec_())
