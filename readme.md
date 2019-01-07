# Iris.vim

A simple mail client for Vim.

## Introduction

Iris is a simple mail client for Vim, inspired by (Neo)Mutt and Alpine.

(Neo)Mutt and Alpine are very good terminal mail clients, but they lack of Vim
mappings. You can emulate, but it requires a lot of time, patience and
configuration. Why trying to emulate, when you can have it in Vim? VimScript
and Python are strong enought to do so. I hope you will enjoy it, feel free to
contribute!

## Roadmap

### v1.0.0-alpha
  - [X] List mails from INBOX
  - [X] Preview `text/plain` mails
  - [X] Preview `text/html` mails in browser
  - [X] Set imap server as daemon (via sockets)
  - [X] Preview / download attachments
  - [X] Send a new mail
  - [X] Reply to a mail
  - [X] Forward mail
  - [X] List and change mailboxes
  - [ ] Support Vim8+

### v1.0.0
  - [ ] Add list pagination
  - [ ] Delete mails
  - [ ] Cache mails
  - [ ] Cache contacts
  - [ ] Auto-complete contacts to, cc, bcc
  - [ ] Fetch new mails in background (idle mode)

## Credits

  - Python lib [imapclient](https://github.com/mjs/imapclient)
    - Class [IMAPClient](https://github.com/mjs/imapclient/blob/580dc6781b5bf9d4f2a1a74b5d4168ef9b842b87/imapclient/imapclient.py#L162)
    - [Example](https://github.com/mjs/imapclient/blob/master/examples/example.py)
    - [Idle example](https://github.com/mjs/imapclient/blob/master/examples/idle_example.py)
  - IMAP [RFC3501](https://tools.ietf.org/html/rfc3501)
    - [Flags](https://tools.ietf.org/html/rfc3501#section-2.3.2)
    - [Status](https://tools.ietf.org/html/rfc3501#section-6.3.10)
    - [Search](https://tools.ietf.org/html/rfc3501#section-6.4.4)
    - [Fetch](https://tools.ietf.org/html/rfc3501#section-7.4.2)
