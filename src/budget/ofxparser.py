import datetime
import re


class ParsedTransactions(object):
    def __init__(self):
        self.transactions = []
        self.accountName = None


class OFXParser(object):
    def parse_file(self, filepath):
        with open(filepath) as f:
            return self.parse_ofx_content(f.read())

    def parse_ofx_content(self, content):
        parsed_transactions = ParsedTransactions()
        ofx = content.split('<OFX>', 2)
        content = ofx[1].split('\n')
        key_value_re = re.compile('< ([^>]+) > (.*) ', re.VERBOSE)

        bank_id = account_id = account_type = full_account_id = None

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
                full_account_id = f'{bank_id}-{account_id}'
                account_type = account_type or 'Bank'
            elif key == '/CCACCTFROM':
                full_account_id = f'{bank_id}-{account_id}'
                account_type = account_type or 'Credit'
            elif key == 'STMTTRN':
                transaction = {'import': True}
                if full_account_id:
                    transaction['account_id'] = full_account_id
            elif key == '/STMTTRN':
                parsed_transactions.transactions.append(transaction)
            elif key == 'TRNAMT':
                transaction['amount'] = float(value)
            elif key == 'DTPOSTED':
                transaction['date'] = datetime.datetime.strptime(value, '%Y%m%d').date()
            elif key == 'MEMO':
                # get rid of extra whitespaces
                transaction['name'] = ' '.join(value.split())
            elif key == 'fitid':
                transaction['fitid'] = value

        return parsed_transactions
