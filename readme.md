# Iris.vim [WIP]

A simple mail client for Vim.

## TODO

  - [X] List mails from INBOX
    - [ ] Add pagination
  - [X] Preview `text/plain` mails
  - [X] Preview `text/html` mails in browser
  - [X] Set imap server as daemon (via sockets)
  - [ ] Preview / download attachments
  - [ ] Send a new mail
  - [ ] Reply to a mail
  - [ ] Delete mails
  - [ ] List and change mailboxes
  - [ ] Cache mails
  - [ ] Cache contacts
  - [ ] Auto-complete contacts to, cc, bcc
  - [ ] Fetch new mails in background (idle mode)

## Useful links

  - Python lib [imapclient](https://github.com/mjs/imapclient)
    - Class [IMAPClient](https://github.com/mjs/imapclient/blob/580dc6781b5bf9d4f2a1a74b5d4168ef9b842b87/imapclient/imapclient.py#L162)
    - [Example](https://github.com/mjs/imapclient/blob/master/examples/example.py)
    - [Idle example](https://github.com/mjs/imapclient/blob/master/examples/idle_example.py)
  - IMAP [RFC3501](https://tools.ietf.org/html/rfc3501)
    - [Flags](https://tools.ietf.org/html/rfc3501#section-2.3.2)
    - [Status](https://tools.ietf.org/html/rfc3501#section-6.3.10)
    - [Search](https://tools.ietf.org/html/rfc3501#section-6.4.4)
    - [Fetch](https://tools.ietf.org/html/rfc3501#section-7.4.2)
