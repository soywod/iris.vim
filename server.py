#!/usr/bin/env python3

import json
import logging
import os
import quopri
import re
import smtplib
import sys

from base64 import b64decode
from email import policy
from email.header import Header
from email.mime.text import MIMEText
from email.parser import BytesParser
from imapclient.imapclient import IMAPClient
from imapclient.imapclient import SEEN

logging.basicConfig(filename='iris.log', level=logging.INFO)

_imap = None
_smtp = None

_host = None
_email = None
_password = None

def get_flags_str(flags):
    flags_str = ''

    flags_str += 'N' if not b'\\Seen' in flags else ' '
    flags_str += '@' if b'\\Answered' in flags else ' '
    flags_str += '!' if b'\\Flagged' in flags else ' '
    flags_str += '#' if b'\\Draft' in flags else ' '

    return flags_str
    
def get_last_seq():
    search = _imap.search(['NOT', 'DELETED', '*'])
    fetch = _imap.fetch(search, ['UID'])
    try:
        return fetch.popitem()[0]
    except:
        return 0

def get_emails(last_seq):
    emails = []

    criteria = ['NOT', 'DELETED']
    if (last_seq > 49): criteria.append('%d:%d' % (last_seq, last_seq - 49))

    search = _imap.search(criteria)
    fetch = _imap.fetch(search, ['ENVELOPE', 'INTERNALDATE', 'FLAGS'])

    for [uid, data] in fetch.items():
        envelope = data[b'ENVELOPE']
        subject = decode(envelope.subject.decode())
        from_ = envelope.from_[0]
        from_ = '@'.join([decode(from_.mailbox.decode()), decode(from_.host.decode())])
        to = envelope.to[0]
        to = '@'.join([decode(to.mailbox.decode()), decode(to.host.decode())])
        date_ = data[b'INTERNALDATE'].strftime('%d/%m/%y, %Hh%M')

        email = dict()
        email['id'] = uid
        email['subject'] = subject.replace('_', ' ')
        email['from'] = from_
        email['to'] = to
        email['date'] = date_
        email['flags'] = get_flags_str(data[b'FLAGS'])

        emails.insert(0, email)

    return emails

def get_email(id, format):
    fetch = _imap.fetch([id], ['BODY[]'])
    content = _get_email_content(id, fetch.popitem()[1][b'BODY[]'])

    return content[format]

def _get_email_content(uid, data):
    content = dict(text=None, html=None, attachments=[])
    email = BytesParser(policy=policy.default).parsebytes(data)

    for part in email.walk():
        if part.is_multipart():
            continue

        if part.is_attachment():
            content['attachments'].append(_read_attachment(part, uid))
            continue

        if part.get_content_type() == 'text/plain':
            content['text'] = _read_text(part)
            continue

        if part.get_content_type() == 'text/html':
            content['html'] = _read_html(part, uid)
            continue

    if content['html'] and not content['text']:
        tmp = open(content['html'], 'r')
        content['text'] = tmp.read()
        tmp.close()

    return content

def _read_text(part):
    payload = part.get_payload(decode=True)
    try: return quopri.decodestring(payload).decode()
    except: pass
    try: return payload.decode()
    except: return part.get_payload()

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

    if not os.path.exists(preview):
        tmp = open(preview, 'wb')
        tmp.write(payload)
        tmp.close()

    return preview

def decode(string):
    match = re.match('^=\?(.*?)\?(.*?)\?(.*?)\?=$', string) 
    if (match == None): return string

    string_decoded = match.group(3)
    if (match.group(2).upper() == 'B'): string_decoded = b64decode(string_decoded)

    return quopri.decodestring(string_decoded).decode(match.group(1))

while True:
    request_raw = sys.stdin.readline()

    try:
        request = json.loads(request_raw.rstrip())
    except:
        continue

    if request['type'] == 'login':
        try:
            _host = request['host']
            _email = request['email']
            _password = request['password']

            _imap = IMAPClient(host=_host, port=993)
            _imap.login(_email, _password)

            folders = list(map(lambda folder: folder[2], _imap.list_folders()))

            response = dict(success=True, type='login', folders=folders)
        except Exception as error:
            response = dict(success=False, type='login', error=str(error))

    elif request['type'] == 'fetch-emails':
        try:
            emails = get_emails(request['seq'])
            response = dict(success=True, type='fetch-emails', emails=emails)
        except Exception as error:
            response = dict(success=False, type='fetch-emails', error=str(error))

    elif request['type'] == 'fetch-email':
        try:
            logging.info(request)
            email = get_email(request['id'], request['format'])
            response = dict(success=True, type='fetch-email', email=email, format=request['format'])
        except Exception as error:
            response = dict(success=False, type='fetch-email', error=str(error))

    elif request['type'] == 'select-folder':
        try:
            folder = request['folder']
            _imap.select_folder(folder)
            seq = get_last_seq()
            emails = get_emails(seq)
            response = dict(success=True, type='select-folder', folder=folder, seq=seq, emails=emails)
        except Exception as error:
            response = dict(success=False, type='select-folder', error=str(error))

    elif request['type'] == 'send-email':
        try:
            message = MIMEText(request['message'])
            message['From'] = request['headers']['from']
            message['To'] = request['headers']['to']
            message['Subject'] = Header(request['headers']['subject'])

            if 'cc' in request: message['CC'] = request['headers']['cc']
            if 'bcc' in request: message['BCC'] = request['headers']['bcc']

            logging.info(message['From'])
            smtp = smtplib.SMTP(_host)
            smtp.starttls()
            smtp.login(_email, _password)
            smtp.send_message(message)
            smtp.quit()

            _imap.append('Sent', message.as_string())

            response = dict(success=True, type='send-email')
        except Exception as error:
            response = dict(success=False, type='send-email', error=str(error))

    logging.info(json.dumps(response))
    sys.stdout.write(json.dumps(response))
    sys.stdout.flush()
