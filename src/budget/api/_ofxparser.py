import datetime
import re

from .model import Transaction


class OFXParser(object):

    def parse_file(self, filepath):
        with open(filepath) as f:
            return self.parse_ofx_content(f.read())

    def parse_ofx_content(self, content):
        ofx = content.split('<OFX>', 2)
        content = ofx[1].split('\n')
        key_value_re = re.compile('< ([^>]+) > (.*) ', re.VERBOSE)

        bank_id = account_id = account_type = full_account_name = None

        transactionData = []
        transaction = {}

        for line in content:
            re_obj = key_value_re.match(line)
            if not re_obj:
                continue
            key = re_obj.group(1)
            value = re_obj.group(2)

            if key == 'BANKID':
                bank_id = value
            elif key == 'ACCTID':
                account_id = value
            elif key == 'ACCTTYPE':
                account_type = value
            elif key == '/BANKACCTFROM':
                full_account_name = f'{bank_id}-{account_id}'
                account_type = account_type or 'Bank'
            elif key == '/CCACCTFROM':
                full_account_name = f'{account_id}'
                account_type = account_type or 'Credit'
            elif key == 'STMTTRN':
                transaction = {'import': True}
                if full_account_name:
                    transaction['account'] = full_account_name
            elif key == '/STMTTRN':
                transactionData.append(transaction)
            elif key == 'TRNAMT':
                transaction['amount'] = float(value)
            elif key == 'DTPOSTED':
                transaction['date'] = datetime.datetime.strptime(value, '%Y%m%d').date()
            elif key == 'MEMO':
                # get rid of extra whitespaces
                transaction['name'] = ' '.join(value.split())
            elif key == 'fitid':
                transaction['fitid'] = value

        transactions = []
        for d in transactionData:
            name = d.get('name')
            date = d.get('date')
            amount = d.get('amount')
            fitid = d.get('fitid')
            t = Transaction(full_account_name, name, date, amount, fitid=fitid)
            transactions.append(t)

        return transactions
