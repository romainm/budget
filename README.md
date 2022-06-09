# budget

Very basic application to learn QtQuick. This was built using an old version of QtQuick and has recently been refreshed to work with PySide6. Not many features are working yet though and the rest probably needs to be rewritten.
## todo

- flagging should not work in the main transaction UI. This is an import thing only. It is there to disable items.
- category not editable in the list. Instead you click on a category from the left menu.
- search should be backend search? Currently we have everything in memory and use the proxymodel to filter.

- API level, with unittests
- Import should import all transactions

- import should filter out already imported transactions
- record button not visible for some reason by default

Accounts
- list accounts on the left pane: name and current balance
- ability to set today's balance on an account
- use account label rather than account Id

Categories
- Add/Remove category
- Category Income vs Expense... does it matter?
- Category groups

Charts
- advanced: last n <unit> with unit being week / fortnight/ month/ quarter /  year

Storage
- Test tinydb


## How to build and execute

### Using pipenv

`cd` into the folder and
- `pipenv install` to install all necessary dependencies
- `pipenv shell`
- `python main.py`

In the future we'll package that with PyInstaller so it's easier to run.


## Dev notes

Transaction objects are high-level objects. You can change them directly. This should not change the database unless you manually do it.
Transaction know about the category object. You can swap that category object but cannot set a category name on a transaction.

API.createNewCategory() -> create a category in the database.

newCategory = Category("newName")
transaction.setCategory(newCategory)

// the database does not know about that yet.

the API on top of that needs to ensure that the database is in sync.



Store - read/write from disk/db
Model - Category, Transaction, Account - They know if they have been serialised or not, the serialiser is associated with the objects.
API - manages model objects, based on the serialisation strategy.


API - does not manage the store at all, that's automatic.
SqlStore: listTransactions / createTransactions / ...



