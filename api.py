#!/usr/bin/env python3

import quopri
import re
import urllib
import vim

from base64 import b64decode
from datetime import date, datetime
from functools import reduce
from imapclient.imapclient import IMAPClient

def connect():
    host = vim.vars['iris_host']
    email = vim.vars['iris_email']
    password = vim.eval('password')

    client = IMAPClient(host=host)
    client.login(email, password)
    client.select_folder('INBOX', readonly=True)

    sort = client.search(['NOT', 'DELETED', 'SINCE', date(2018, 9, 28)])
    response = client.fetch(sort, ['BODY.PEEK[HEADER]', 'INTERNALDATE'])
    client.logout()

    messages = []

    for [id, data] in response.items():
        headers = {}
        matches = re.findall('(.*?): (.*?)\r\n', data[b'BODY[HEADER]'].decode())

        for match in matches:
            headers[match[0]] = match[1]

        message = dict()
        message['id'] = str(id)
        message['subject'] = decode(headers['Subject'])
        message['from'] = decode(headers['From'])
        message['date'] = data[b'INTERNALDATE'].strftime('%d/%m/%y, %Hh%M')
        message['flags'] = '!'

        messages.insert(message)

    return messages

def decode(string):
    match = re.match('^=\?(.*?)\?(.*?)\?(.*?)\?=$', string) 
    if (match == None): return string

    string_decoded = match.group(3)

    if (match.group(2).upper() == 'B'):
        string_decoded = b64decode(string_decoded)

    return quopri.decodestring(string_decoded).decode(match.group(1))
