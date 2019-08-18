
CREATE_ACCOUNTS = """
CREATE TABLE accounts(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT UNIQUE,
label TEXT,
balanceSetDate INT NOT NULL,
balanceSet REAL DEFAULT 0
);
"""

CREATE_TRANSACTIONS = """
CREATE TABLE transactions(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT,
date INT NOT NULL,
amount REAL DEFAULT 0,
fitid INT,
accountId INT REFERENCES accounts(id),
categoryId INT REFERENCES categories(id)
);
"""

CREATE_CATEGORIES = """
CREATE TABLE categories(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT
);
"""

def createTables(db):
    c = db.cursor()
    c.execute(CREATE_ACCOUNTS)
    c.execute(CREATE_TRANSACTIONS)
    c.execute(CREATE_CATEGORIES)
    db.commit()

