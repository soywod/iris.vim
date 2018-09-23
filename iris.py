import vim

from datetime import date
from imapclient.imapclient import IMAPClient

def imap_connect():
    host = vim.vars['iris_host']
    email = vim.vars['iris_email']
    password = vim.eval('password')

    client = IMAPClient(host=host)
    client.login(email, password)
    client.select_folder('INBOX', readonly=True)

    sort = client.search(['NOT', 'DELETED', 'SINCE', date(2018, 9, 1)])
    response = client.fetch(sort, ['FLAGS', 'RFC822.SIZE'])
    client.logout()

    return response.items()
