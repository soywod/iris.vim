#!/usr/bin/env python3

import json
import logging
import os
import quopri
import re
import smtplib
import subprocess
import sys
import threading

from base64 import b64decode
from email import policy
from email.header import Header
from email.mime.text import MIMEText
from email.parser import BytesParser
from email.utils import formataddr
from email.utils import formatdate
from email.utils import make_msgid
from imapclient.imapclient import IMAPClient

logging.basicConfig(filename="/tmp/iris.log", level=logging.INFO)

imap_client = None
imap_host = imap_port = imap_login = imap_passwd = None
smtp_host = smtp_port = smtp_login = smtp_passwd = None

idle_thread = None
is_idle = is_folder_selected = False

def notify_new_mail():
    title = "Iris"
    msg = "New mail available!"

    if sys.platform == "darwin":
        cmd = ["terminal-notifier", "-title", title, "-message", msg]
    else:
        cmd = ["notify-send", title, msg]

    subprocess.Popen(cmd)

def handle_idle():
    while True:
        global imap_client, is_idle

        if not is_idle: break
        idle_res = imap_client.idle_check(timeout=15)

        if idle_res: logging.info("idle received: " + str(idle_res))

        for res in idle_res:
            if res[1] == b"EXISTS": notify_new_mail()

def get_emails(last_seq):
    global imap_client

    emails = []
    if last_seq == 0: return emails

    ids = "%d:%d" % (last_seq, last_seq - 49) if (last_seq > 49) else "%d:%d" % (last_seq, 1)
    fetch = imap_client.fetch(ids, ["ENVELOPE", "INTERNALDATE", "FLAGS"])

    for [uid, data] in fetch.items():
        envelope = data[b"ENVELOPE"]
        subject = decode(envelope.subject.decode())
        from_ = envelope.from_[0]
        from_ = "@".join([decode(from_.mailbox.decode()), decode(from_.host.decode())])
        to = envelope.to[0]
        to = "@".join([decode(to.mailbox.decode()), decode(to.host.decode())])
        date_ = data[b"INTERNALDATE"].strftime("%d/%m/%y, %Hh%M")

        email = dict()
        email["id"] = uid
        email["subject"] = subject.replace("_", " ")
        email["from"] = from_
        email["to"] = to
        email["date"] = date_
        email["flags"] = get_flags_str(data[b"FLAGS"])

        emails.insert(0, email)

    return emails

def get_email(id, format):
    global imap_client

    fetch = imap_client.fetch([id], ["BODY[]"])
    content = get_email_content(id, fetch.popitem()[1][b"BODY[]"])

    return content[format]

def get_flags_str(flags):
    flags_str = ""

    flags_str += "N" if not b"\\Seen" in flags else " "
    flags_str += "@" if b"\\Answered" in flags else " "
    flags_str += "!" if b"\\Flagged" in flags else " "
    flags_str += "#" if b"\\Draft" in flags else " "

    return flags_str
    
def get_email_content(uid, data):
    content = dict(text=None, html=None, attachments=[])
    email = BytesParser(policy=policy.default).parsebytes(data)

    for part in email.walk():
        if part.is_multipart():
            continue

        if part.is_attachment():
            content["attachments"].append(read_attachment(part, uid))
            continue

        if part.get_content_type() == "text/plain":
            content["text"] = read_text(part)
            continue

        if part.get_content_type() == "text/html":
            content["html"] = read_html(part, uid)
            continue

    if content["html"] and not content["text"]:
        tmp = open(content["html"], "r")
        content["text"] = tmp.read()
        tmp.close()

    return content

def read_text(part):
    payload = part.get_payload(decode=True)
    try: return quopri.decodestring(payload).decode()
    except: pass
    try: return payload.decode()
    except: return part.get_payload()

def read_html(part, uid):
    payload = read_text(part)
    preview = write_preview(payload.encode(), uid)

    return preview

def read_attachment(part, uid):
    payload = part.get_payload(decode=True)
    preview = write_preview(payload, uid, part.get_content_subtype())

    return preview

def write_preview(payload, uid, subtype="html"):
    preview = "/tmp/preview-%d.%s" % (uid, subtype)

    if not os.path.exists(preview):
        tmp = open(preview, "wb")
        tmp.write(payload)
        tmp.close()

    return preview

def decode(string):
    match = re.match(r"^=\?(.*?)\?(.*?)\?(.*?)\?=$", string) 
    if (match == None): return string

    string_decoded = match.group(3)
    if (match.group(2).upper() == "B"): string_decoded = b64decode(string_decoded)

    return quopri.decodestring(string_decoded).decode(match.group(1))

while True:
    request_raw = sys.stdin.readline()
    logging.info(request_raw.rstrip())

    try: request = json.loads(request_raw.rstrip())
    except: continue

    if request["type"] == "login":
        try:
            imap_host = request["imap-host"]
            imap_port = request["imap-port"]
            imap_login = request["imap-login"]
            imap_passwd = request["imap-password"]

            smtp_host = request["smtp-host"]
            smtp_port = request["smtp-port"]
            smtp_login = request["smtp-login"]
            smtp_passwd = request["smtp-password"]

            imap_client = IMAPClient(host=imap_host, port=imap_port)
            imap_client.login(imap_login, imap_passwd)

            folders = list(map(lambda folder: folder[2], imap_client.list_folders()))

            response = dict(success=True, type="login", folders=folders)
        except Exception as error:
            response = dict(success=False, type="login", error=str(error))

    elif request["type"] == "start-idle" and not is_idle:
        try:
            is_idle = True
            imap_client.idle()
            idle_thread = threading.Thread(target=handle_idle)
            idle_thread.setDaemon(True)
            idle_thread.start()
            response = dict(success=True, type="start-idle")
        except Exception as error:
            response = dict(success=False, type="start-idle")

    elif request["type"] == "stop-idle" and is_idle:
        try:
            logging.info('stop idle')
            is_idle = False
            idle_thread.join()
            imap_client.idle_done()
            response = dict(success=True, type="stop-idle")
        except Exception as error:
            response = dict(success=False, type="stop-idle")

    elif request["type"] == "fetch-emails":
        try:
            emails = get_emails(request["seq"])
            response = dict(success=True, type="fetch-emails", emails=emails)
        except Exception as error:
            response = dict(success=False, type="fetch-emails", error=str(error))

    elif request["type"] == "fetch-email":
        try:
            email = get_email(request["id"], request["format"])
            response = dict(success=True, type="fetch-email", email=email, format=request["format"])
        except Exception as error:
            response = dict(success=False, type="fetch-email", error=str(error))

    elif request["type"] == "select-folder":
        try:
            folder = request["folder"]
            seq = imap_client.select_folder(folder)[b"UIDNEXT"]
            emails = get_emails(seq)
            is_folder_selected = True
            response = dict(success=True, type="select-folder", folder=folder, seq=seq, emails=emails)
        except Exception as error:
            response = dict(success=False, type="select-folder", error=str(error))

    elif request["type"] == "send-email":
        try:
            from_name = request["headers"]["from-name"]
            from_email = request["headers"]["from-email"]

            message = MIMEText(request["message"])
            message["From"] = formataddr((from_name, from_email))
            message["To"] = request["headers"]["to"]
            message["Subject"] = Header(request["headers"]["subject"])
            message["Date"] = formatdate(localtime=True)
            message["Message-Id"] = make_msgid()

            if "cc" in request: message["CC"] = request["headers"]["cc"]
            if "bcc" in request: message["BCC"] = request["headers"]["bcc"]

            logging.info(message)
            smtp = smtplib.SMTP(host=smtp_host, port=smtp_port)
            smtp.starttls()
            smtp.login(smtp_login, smtp_passwd)
            smtp.send_message(message)
            smtp.quit()

            imap_client.append("Sent", message.as_string())

            response = dict(success=True, type="send-email")
        except Exception as error:
            response = dict(success=False, type="send-email", error=str(error))

    logging.info(json.dumps(response))
    sys.stdout.write(json.dumps(response) + "\n")
    sys.stdout.flush()
