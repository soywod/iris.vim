#!/usr/bin/env python3

import email
import quopri
import re
import urllib
import vim
import webbrowser

from base64 import b64decode
from datetime import date, datetime
from email import policy
from email.parser import BytesParser
from functools import reduce
from imapclient.imapclient import IMAPClient
from os import path

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

    output = dict(text=None, html=None, attachments=[])

    sort = client.search(['UID', id])
    res  = client.fetch(sort, ['BODY[]'])
    if not res: return output

    [uid, raw_mail] = res.popitem()
    mail = BytesParser(policy=policy.default).parsebytes(raw_mail[b'BODY[]'])

    for part in mail.walk():
        if part.is_multipart():
            continue

        if part.is_attachment():
            output['attachments'].append(_read_attachment(part, uid))
            continue

        if part.get_content_type() == 'text/plain':
            output['text'] = _read_text(part)
            continue

        if part.get_content_type() == 'text/html':
            output['html'] = _read_html(part, uid)
            continue

    if output['html'] and not output['text']:
        tmp = open(output['html'], 'r')
        output['text'] = tmp.read()
        tmp.close()

    return output

def preview(path):
    webbrowser.open_new(path)

def _read_text(part):
    payload = part.get_payload(decode=True)
    try: return quopri.decodestring(payload).decode()
    except: return payload.decode()

def _read_html(part, uid):
    payload = _read_text(part)
    preview = _write_preview(payload.encode(), uid)
    return preview

def _read_attachment(part, uid):
    payload = part.get_payload(decode=True)
    preview = _write_preview(payload, uid, part.get_content_subtype())
    return preview

def _write_preview(payload, uid, subtype='html'):
    preview = '/tmp/preview-%d.%s' % (uid, subtype)

    if not path.exists(preview):
        tmp = open(preview, 'wb')
        tmp.write(payload)
        tmp.close()

    return preview

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
