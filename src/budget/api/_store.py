
class TransactionFilter(object):
    def __init__(self):
        self.date = None
        self.amountLessThan = None
        self.amountMoreThan = None
        self.namePattern = None
        self.categoryPattern = None
        self.hash = None


class InMemoryStore(object):
    def __init__(self) -> None:
        self._accounts = {}
        self._categories = {}
        self._transactions = []

    def transactions(self, transactionFilter=None):
        if not transactionFilter:
            return self._transactions

        transactions = []
        if transactionFilter.hash is not None:
            for transaction in self._transactions:
                if transaction.hash() == transactionFilter.hash:
                    transactions.append(transaction)
        return transactions

    def accounts(self):
        return list(self._accounts.values())

    def categories(self):
        return list(self._categories.values())

    def account(self, accountId):
        return self._accounts.get(accountId)

    def category(self, name):
        return self._categories.get(name)

    def recordAccount(self, account):
        self._accounts[account.accountId] = account

    def recordCategory(self, category):
        self._categories[category.name] = category

    def recordTransactions(self, transactions):
        self._transactions.extend(transactions)

