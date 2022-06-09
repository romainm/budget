
import sys

from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication
from budget.api import Api, InMemoryStore
from datetime import date as dtd


from PySide6.QtCore import (
    Qt,
    QDate,
    QObject,
    QUrl,
    Property,
    Slot,
    QAbstractListModel,
    QModelIndex,
    QSortFilterProxyModel,
    Signal
)


class ProxyModel(QSortFilterProxyModel):

    @Slot(str)
    def setFilterString(self, ft):
        self._filterString = ft.lower()
        self.setFilterCaseSensitivity(Qt.CaseInsensitive)
        self.setFilterFixedString(ft)

    def filterAcceptsRow(self, sourceRow, sourceParent):
        if not hasattr(self, '_filterString'):
            return True

        name = self.sourceModel().data(self.sourceModel().index(sourceRow, 0), TransactionModel.NameRole)
        category = self.sourceModel().data(self.sourceModel().index(sourceRow, 0), TransactionModel.CategoryRole)
        if self._filterString in category.lower() or self._filterString in name.lower():
            return True

        return False

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
    CategoryRole = Qt.UserRole + 1003  # 1259
    AccountRole = Qt.UserRole + 1004
    AmountNumRole = Qt.UserRole + 1005
    FlaggedRole = Qt.UserRole + 1006
    SelectRole = Qt.UserRole + 1007

    def __init__(self, api, parent=None):
        super(TransactionModel, self).__init__(parent)

        self._api = api

        # Each item is a dictionary of key/value pairs
        self._transactions = []
        self._flaggedIndices = set()
        self._selectedIndices = set()

    def setTransactions(self, transactions):
        self.beginResetModel()
        self._transactions = transactions
        self._flaggedIndices = set()
        for i, t in enumerate(transactions):
            if t.isMarked:
                self._flaggedIndices.add(self.index(i, 0))
        self.endResetModel()

    def transactions(self, indices=None):
        if not indices:
            return self._transactions
        return [self._transactions[i] for i in indices]

    def selectedIndices(self):
        return [i.row() for i in self._selectedIndices]

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
                return transaction.category.name if transaction.category else ""
            elif role == self.AccountRole:
                return transaction.accountId
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


class CategoryModel(QAbstractListModel):
    DataRole = Qt.UserRole + 1000

    def __init__(self, api, parent=None):
        super(CategoryModel, self).__init__(parent)

        self._api = api

    def categories(self):
        return self._api.categories()

    def data(self, index, role=DataRole):
        if 0 <= index.row() < self.rowCount() and index.isValid():
            if role == self.DataRole:
                category = self._api.categories()[index.row()]
                return category.name
        return None

    def setData(self, index, value, role):
        if role == self.DataRole:
            # expected that this is where we can change the name of a category later on if we want to
            return True
        return False

    def rowCount(self, parent=QModelIndex()):
        sys.stdout.flush()
        return len(self._api.categories())

    def roleNames(self):

        """Role names are used by QML to map key to role"""
        roles = dict()
        roles[self.DataRole] = b"modelData"
        return roles


class UIModel(QObject):

    def __init__(self, api, parent=None):
        super(UIModel, self).__init__(parent=parent)

        self._api = api

        self._transactionModel = TransactionModel(self._api)
        self._transactionModel.setTransactions(self._api.transactions())

        self._categoryModel = CategoryModel(self._api)

        self._transactionImportModel = TransactionModel(self._api)

        self._transactionModelProxy = ProxyModel()
        self._transactionModelProxy.setSourceModel(self._transactionModel)
        self._transactionModelProxy.setFilterRole(TransactionModel.NameRole)

        self._transactionImportModelProxy = ProxyModel()
        self._transactionImportModelProxy.setSourceModel(self._transactionImportModel)
        self._transactionImportModelProxy.setFilterRole(TransactionModel.NameRole)

        self._api.categoriesChanged.connect(self._categoryModel.modelReset)

    def transactionModel(self):
        return self._transactionModelProxy

    def transactionImportModel(self):
        return self._transactionImportModelProxy

    def categoryModel(self):
        return self._categoryModel

    def category(self, categoryName):
        """Return a category object. It will create it in the database if necessary."""
        self._db.createNewCategory(categoryName)

    @Slot('QVariantList')
    def loadFiles(self, filePaths):
        print('loading files: %s' % filePaths)
        for path in filePaths:
            parsedTransactions = self._api.importFile(QUrl(path).toLocalFile())
            print(f'Loaded {len(parsedTransactions)} transactions. {len([t for t in parsedTransactions if t.isMarked])} have already been recorded.')
            self._transactionImportModel.setTransactions(parsedTransactions)

    @Slot()
    def recordTransactions(self):
        self._api.recordTransactions(self._transactionImportModel.transactions())
        self._transactionModel.setTransactions(self._api.transactions())
        self._transactionImportModel.clear()

    @Slot('QString')
    def setSelectedTransactionsCategory(self, categoryName):
        transactions = self._transactionModel.transactions(self._transactionModel.selectedIndices())
        self._api.setCategory(categoryName, transactions)
        for i in self._transactionModel.selectedIndices():
            self._transactionModel.dataChanged.emit(self._transactionModel.index(i, 0), self._transactionModel.index(i,0))


def setupTempCategories():
    for cat in [
        'income rom',
        'income vero',
        'rentals only',
        'tax return',
        'crypto',
        'parents rom',
        'daily',
        'charity',
        'car insurance',
        'car rego',
        'car fuel',
        'car fees',
        'public transport',
        'fun',
        'health insurance',
        'kids allowance',
        'kids activities',
        'childcare',
        'gas',
        'phone',
        'electricity',
        'internet',
        'council',
        'water',
        'safe deposit',
        'holiday',
        'subscriptions',
        'CA membership',
        'home maintenance',
        'home insurance',
        'car service',




    ]:
        api.recordCategory(api.createCategory(cat))

if __name__ == "__main__":
    app = QApplication(sys.argv)

    store = InMemoryStore()
    api = Api(store)
    setupTempCategories()
    modelAPI = UIModel(api)

    # transactions are not yet in the database.
    # transaction = api.createTransaction('010-040', 'aldi', dtd.today(), 134.40)
    # transaction.category = api.createCategory('dailies')
    # transaction2 = api.createTransaction('010-040', 'optus', dtd.today(), 60.00)
    # transaction2.category = api.createCategory('groceries')
    # api.recordTransactions([transaction, transaction2])
    # print("transactions recorded")
    # print(api.transactions())
    # print(api.accounts())
    # print(api.categories())

    # test data
    modelAPI.loadFiles([QUrl('file:///C:/Users/romai/Downloads/OFXData (4).ofx')])
    modelAPI.recordTransactions()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("modelAPI", modelAPI)
    engine.rootContext().setContextProperty("transactionModel", modelAPI.transactionModel())
    engine.rootContext().setContextProperty("categoryModel", modelAPI.categoryModel())
    engine.rootContext().setContextProperty("transactionImportModel", modelAPI.transactionImportModel())
    engine.load('qml/main.qml')
    
    sys.exit(app.exec())
