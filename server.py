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
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.parser import BytesParser
from imapclient.imapclient import IMAPClient

logging.basicConfig(filename='iris.log', level=logging.INFO)

_imap = None
_smtp = None

_host = None
_email = None
_password = None

def get_last_seq():
    search = _imap.search(['NOT', 'DELETED', '*'])
    fetch = _imap.fetch(search, ['UID'])
    try:
        return fetch.popitem()[1][b'SEQ']
    except:
        return 0

def get_emails(seq):
    emails = []
    criteria = ['NOT', 'DELETED']

    if (seq > 29):
        criteria.append('%d:%d' % (seq, seq - 29))

    search = _imap.search(criteria)
    fetch = _imap.fetch(search, ['ENVELOPE', 'BODY[]'])

    for [uid, data] in fetch.items():
        envelope = data[b'ENVELOPE']

        subject = decode(envelope.subject.decode())
        from_ = envelope.from_[0]
        date_ = envelope.date.strftime('%d/%m/%y, %Hh%M')

        if (from_.name == None):
            from_ = '@'.join([decode(from_.mailbox.decode()), decode(from_.host.decode())])
        else:
            from_ = decode(from_.name.decode())

        email = dict()
        email['uid'] = uid
        email['subject'] = subject.replace('_', ' ')
        email['from'] = from_
        email['date'] = date_
        email['flags'] = '!'
        email['content'] = get_email_content(uid, data[b'BODY[]'])

        emails.insert(0, email)

    return emails

def get_email_content(uid, data):
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

    if (match.group(2).upper() == 'B'):
        string_decoded = b64decode(string_decoded)

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

            _imap = IMAPClient(host=_host)
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

    elif request['type'] == 'select-folder':
        try:
            folder = request['folder']
            _imap.select_folder(folder, readonly=True)
            seq = get_last_seq()
            emails = get_emails(seq)
            response = dict(success=True, type='select-folder', folder=folder, seq=seq, emails=emails)
        except Exception as error:
            response = dict(success=False, type='select-folder', error=str(error))

    elif request['type'] == 'send-email':
        try:
            logging.info(request)
            email = MIMEMultipart()

            email['From'] = request['from']
            email['To'] = request['to']
            email['Subject'] = request['subject'] if request['subject'] else ''

            # if request['cc']:
            #     email['cc'] = request['cc']

            # if request['bcc']:
            #     email['bcc'] = request['cc']

            email.attach(MIMEText(request['message'], 'plain'))

            smtp = smtplib.SMTP(_host)
            smtp.starttls()
            smtp.login(_email, _password)
            smtp.sendmail(email['From'], email['To'], email.as_string())
            smtp.quit()

            response = dict(success=True, type='send-email')
        except Exception as error:
            response = dict(success=False, type='send-email', error=str(error))

    sys.stdout.write(json.dumps(response))
    sys.stdout.flush()
