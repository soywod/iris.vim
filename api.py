#!/usr/bin/env python3

import chardet
import email
import hashlib
import quopri
import re
import urllib
import vim
import webbrowser

from base64 import b64decode
from email import policy
from email.parser import BytesParser
from datetime import date, datetime
from functools import reduce
from imapclient.imapclient import IMAPClient

client = None

def connect():
    global client
    client = IMAPClient(host=vim.vars['iris_host'])

    email = vim.vars['iris_email']
    password = vim.eval('iris#password()')

    client.login(email, password)
    client.select_folder('INBOX', readonly=True)

def read(id):
    connect()

    sort = client.search(['UID', id])
    response = client.fetch(sort, ['BODY[]'])

    for [id, data] in response.items():
        mail = BytesParser(policy=policy.default).parsebytes(data[b'BODY[]'])
        body = mail.get_body(preferencelist=['html', 'plain'])
        hash = hashlib.sha1(mail.get('Message-ID').encode())
        path = '/tmp/%s.html' % hash.hexdigest()

        tmp = open(path, 'w')

        try:
            tmp.write(quopri.decodestring(body.get_payload()).decode())
        except:
            tmp.write(body.get_payload(decode=True).decode())

        tmp.close()
        webbrowser.open_new(path)
    return dict()

def read_all():
    connect()

    mails = []
    sort = client.search(['NOT', 'DELETED', 'SINCE', date(2018, 9, 20)])
    response = client.fetch(sort, ['ENVELOPE'])

    for [id, data] in response.items():
        mail = dict()
        envelope = data[b'ENVELOPE']
        subject = decode(envelope.subject.decode())
        from_ = envelope.from_[0]
        date_ = envelope.date.strftime('%d/%m/%y, %Hh%M')

        if (from_.name == None):
            from_ = '@'.join([decode(from_.mailbox.decode()), decode(from_.host.decode())])
        else:
            from_ = decode(from_.name.decode())

        mail['id'] = id
        mail['subject'] = subject.replace('_', ' ')
        mail['from'] = from_
        mail['date'] = date_
        mail['flags'] = '!'

        mails.insert(0, mail)

    return mails

def decode(string):
    match = re.match('^=\?(.*?)\?(.*?)\?(.*?)\?=$', string) 
    if (match == None): return string

    string_decoded = match.group(3)

    if (match.group(2).upper() == 'B'):
        string_decoded = b64decode(string_decoded)

    return quopri.decodestring(string_decoded).decode(match.group(1))
