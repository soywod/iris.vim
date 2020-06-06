#!/usr/bin/env python3

import json
import logging
import subprocess
import sys

from imapclient.imapclient import IMAPClient

logging.basicConfig(filename="/tmp/iris-idle.log", format="[%(asctime)s] %(message)s", level=logging.INFO, datefmt="%Y-%m-%d %H:%M:%S")

request_raw = sys.stdin.readline()
request = json.loads(request_raw.rstrip())
logging.info({key: request[key] for key in request if key not in ["imap-passwd"]})

host = request["imap-host"]
port = request["imap-port"]
login = request["imap-login"]
passwd = request["imap-passwd"]
idle_timeout = request["idle-timeout"]

imap = IMAPClient(host, port)
imap.login(login, passwd)
imap.select_folder("INBOX")
imap.idle()

def notify_new_mail():
    title = "Iris"
    msg = "New mail available!"

    if sys.platform == "darwin":
        cmd = ["terminal-notifier", "-title", title, "-message", msg]
    else:
        cmd = ["notify-send", title, msg]

    logging.info("Notify: " + " ".join(cmd))
    subprocess.Popen(cmd)

while True:
    idle_res = imap.idle_check(timeout=idle_timeout)
    logging.info("Receive: " + str(idle_res))
    for res in idle_res:
        if res[1] == b"EXISTS": notify_new_mail()
