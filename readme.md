# Iris.vim

A simple email client for Vim.

<p align="center">
  <img src="https://user-images.githubusercontent.com/10437171/51052187-381b2b00-15d6-11e9-8170-f9344b0264ea.jpeg"></img>
</p>

## Introduction

Iris is a simple email client for Vim, inspired by (Neo)Mutt and Alpine.

(Neo)Mutt and Alpine are very good terminal email clients, but they lack of Vim
mappings. You can emulate, but it requires a lot of time, patience and
configuration. Why trying to emulate, when you can have it in Vim? VimScript
and Python are strong enought to do so. I hope you will enjoy it, feel free to
contribute!

## Usage

```vim
:Iris
```

If it's your first connection, you will be prompted your IMAP password, then
your SMTP password (this last one can be skipped, the IMAP password will be
used instead).

### Change folder

```vim
:IrisFolder
```

## Keybinds
### From email list interface

Function | Keybind
--- | ---
text preview | `<Enter>`
html preview | `gp` (for `go to preview`)
new email | `gn` (for `go to new`)

### From email preview interface

Function | Keybind
--- | ---
reply | `gr` (for `go reply`)
reply all | `gR` (for `go reply all`)
forward | `gf` (for `go forward`)

### From email edition interface

Function | Keybind
--- | ---
save draft | `:w` (for `go send`)
send | `gs` (for `go send`)

## Config

Define your email address:

```vim
g:iris_email = <string>
```

Default: `iris@localhost`

### IMAP

Define host:

```vim
g:iris_imap_host = <string>
```

Default: `localhost`

Define port:

```vim
g:iris_imap_port = <number>
```

Default: `993`

Define login:

```vim
g:iris_imap_login = <string>
```

Default: `user`

### SMTP

Define host:

```vim
g:iris_smtp_host = <string>
```

Default: same as `g:iris_imap_host`

Define port:

```vim
g:iris_smtp_port = <number>
```

Default: `587`

Define login:

```vim
g:iris_smtp_login = <string>
```

Default: same as `g:iris_imap_login`

## Roadmap

### v1.0.0-alpha
  - [X] List emails from INBOX
  - [X] Preview `text/plain` emails
  - [X] Preview `text/html` emails in browser
  - [X] Set imap server as daemon (via sockets)
  - [X] Send a new email
  - [X] Reply to an email
  - [X] Forward email
  - [X] List and change folder (mailbox)
  - [ ] Support Vim8+

### v1.0.0
  - [ ] Add list pagination
  - [ ] Preview / download attachments
  - [ ] Delete emails
  - [ ] Cache emails
  - [ ] Cache contacts
  - [ ] Auto-complete contacts to, cc, bcc
  - [ ] Fetch new emails in background (idle mode)

## Contributing

Git commit messages follow the [Angular
Convention](https://gist.github.com/stephenparish/9941e89d80e2bc58a153), but
contain only a subject.

  > Use imperative, present tense: “change” not “changed” nor
  > “changes”<br>Don't capitalize first letter<br>No dot (.) at the end

Code should be as clean as possible, variables and functions use the snake case
convention. A line should never contain more than `80` characters.

Tests should be added for each new functionality. Be sure to run tests before
proposing a pull request.

## Changelog

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
