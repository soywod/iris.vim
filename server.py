#!/usr/bin/env python3

import json
import os
import quopri
import re
import socket as s
import sys

from base64 import b64decode
from email import policy
from email.parser import BytesParser
from imapclient.imapclient import IMAPClient

imap = None

def get_last_seq():
    search = imap.search(['NOT', 'DELETED', '*'])
    fetch = imap.fetch(search, ['UID'])
    try:
        return fetch.popitem()[1][b'SEQ']
    except:
        return 0

def get_mails(seq):
    mails = []
    criteria = ['NOT', 'DELETED']

    if (seq > 29):
        criteria.append('%d:%d' % (seq, seq - 29))

    search = imap.search(criteria)
    fetch = imap.fetch(search, ['ENVELOPE', 'BODY[]'])

    for [uid, data] in fetch.items():
        envelope = data[b'ENVELOPE']

        subject = decode(envelope.subject.decode())
        from_ = envelope.from_[0]
        date_ = envelope.date.strftime('%d/%m/%y, %Hh%M')

        if (from_.name == None):
            from_ = '@'.join([decode(from_.mailbox.decode()), decode(from_.host.decode())])
        else:
            from_ = decode(from_.name.decode())

        mail = dict()
        mail['uid'] = uid
        mail['subject'] = subject.replace('_', ' ')
        mail['from'] = from_
        mail['date'] = date_
        mail['flags'] = '!'
        mail['content'] = get_mail_content(uid, data[b'BODY[]'])

        mails.insert(0, mail)

    return mails

def get_mail_content(uid, data):
    content = dict(text=None, html=None, attachments=[])
    mail = BytesParser(policy=policy.default).parsebytes(data)

    for part in mail.walk():
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

default_socket_file = '%s/iris.sock' % os.environ.get('XDG_RUNTIME_DIR', '/tmp')

socket = s.socket(s.AF_UNIX, s.SOCK_STREAM)
socket.setsockopt(s.SOL_SOCKET, s.SO_REUSEADDR, 1)
socket_file = sys.argv[1] if len(sys.argv) > 1 else default_socket_file

try: os.remove(socket_file)
except OSError: pass

socket.bind(socket_file)
socket.listen(1)

client, address = socket.accept()

while 1:
    request = json.loads(client.recv(4096))

    if request['type'] == 'login':
        imap = IMAPClient(host=request['host'])
        imap.login(request['email'], request['password'])
        imap.select_folder('INBOX', readonly=True)
        response = dict(success=True, type='login', seq=get_last_seq())
        client.send(json.dumps(response).encode())

    elif request['type'] == 'list':
        mails = get_mails(request['seq'])
        response = dict(success=True, type='list', mails=mails)
        client.send(json.dumps(response).encode())
