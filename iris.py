#!/usr/bin/env python3

import re
import vim
import urllib
import quopri

from datetime import date, datetime
from functools import reduce
from imapclient.imapclient import IMAPClient

def imap_connect():
    host = vim.vars['iris_host']
    email = vim.vars['iris_email']
    password = vim.eval('password')

    client = IMAPClient(host=host)
    client.login(email, password)
    client.select_folder('INBOX', readonly=True)

    sort = client.search(['NOT', 'DELETED', 'SINCE', date(2018, 9, 1)])
    response = client.fetch(sort, ['BODY.PEEK[HEADER]', 'INTERNALDATE'])
    client.logout()

    messages = []

    for [id, data] in response.items():
        headers = {}
        matches = re.findall('(.*?): (.*?)\r\n', data[b'BODY[HEADER]'].decode())

        for match in matches:
            headers[match[0]] = match[1]

        try:
            subject = quopri.decodestring(headers['Subject']).decode()
        except:
            subject = urllib.parse.unquote(headers['Subject'])

        messages.append(' - '.join([str(id), subject, headers['From'], data[b'INTERNALDATE'].strftime('%x')]))

    return messages
