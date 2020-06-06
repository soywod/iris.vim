# 📫 Iris.vim

Simple mail client for Vim, inspired by (Neo)Mutt and Alpine.

![image](https://user-images.githubusercontent.com/10437171/83288749-2db9fb00-a1e4-11ea-9ffa-3f0b6223e3ad.png)

## Table of contents

  - [Motivation](#motivation)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Configuration](#configuration)
    - [1. Identity](#1-identity)
    - [2. IMAP](#2-imap)
    - [3. SMTP](#3-identity)
    - [4. Passwords](#4-passwords-optional)
    - [5. Idle mode](#5-idle-mode-optional)
  - [Usage](#usage)
    - [List mails](#list-mails)
    - [Change folder](#change-folder)
  - [Keybinds](#keybinds)
  - [Contributing](#contributing)

## Motivation

(Neo)Mutt and Alpine are very good terminal mail clients, but they lack of Vim
mappings. You can emulate, but it requires a lot of time, patience and
configuration. Why trying to emulate, when you can have it in Vim? VimL and
Python are strong enough to do so. The aim of Iris is to provide a simple mail
client that:

  - Allows you to manage your mails inside Vim
  - Does not slow down neither Vim nor your workflow (async+lazy)
  - Is built on the top of a robust [Python IMAP client](https://github.com/mjs/imapclient) to avoid implementing IMAP protocol logic

## Requirements

You need either Neovim or Vim8+ with:

  - Python3 support enabled (`:echo has("python3")`)
  - Job enabled (`:echo has("job")`)
  - Channel enabled (`:echo has("channel")`)

## Installation

For eg. with [`vim-plug`](https://github.com/junegunn/vim-plug):

```vim
Plug "soywod/iris.vim"
```

## Configuration

Before using Iris, you need to configure it:

### 1. Identity

```vim
let g:iris_name  = "My name"
let g:iris_mail = "your@mail.com"
```

### 2. IMAP

```vim
let g:iris_imap_host  = "your.imap.host"
let g:iris_imap_port  = 993
let g:iris_imap_login = "Your IMAP login" "Default to g:iris_mail
```

### 3. SMTP

```vim
let g:iris_smtp_host  = "your.smtp.host" "Default to g:iris_imap_host
let g:iris_smtp_port  = 587
let g:iris_smtp_login = "Your IMAP login" "Default to g:iris_mail
```

### 4. Passwords (optional)

On startup, Iris will always ask for your IMAP and SMTP passwords. To avoid
this, you can save your password in a file and encrypt it via
[GPG](https://gnupg.org/):

```bash
gpg --encrypt --sign --armor --output myfile.gpg myfile
```

```vim
let g:iris_imap_passwd_filepath = "/path/to/imap.gpg"
let g:iris_smtp_passwd_filepath = "/path/to/smtp.gpg"
```

If you want to use something else than GPG, you can set up your custom command.
For eg., using the MacOSX `security` tool:

```vim
let g:iris_imap_passwd_show_cmd = "security find-internet-password -gs IMAP_KEY -w"
let g:iris_smtp_passwd_show_cmd = "security find-internet-password -gs SMTP_KEY -w"
```

### 5. Idle mode (optional)

On startup, Iris spawns two Python jobs: one for the API, one for the [idle
mode](https://imapclient.readthedocs.io/en/2.1.0/advanced.html#watching-a-mailbox-using-idle).
The last one allows you to receive notifications on new mails. You can disable
this option or change the default timeout (every 15s):

```vim
let g:iris_idle_enabled = 1
let g:iris_idle_timeout = 15
```

## Usage

### List mails

```vim
:Iris
```

### Change folder

```vim
:IrisFolder
```

## Keybinds
### From mail list interface

Function | Keybind
--- | ---
text preview | `<Enter>`
html preview | `gp` (for `go preview`)
new mail | `gn` (for `go new`)
change folder | `gf` (for `go folder`)

### From mail preview interface

Function | Keybind
--- | ---
reply | `gr` (for `go reply`)
reply all | `gR` (for `go reply all`)
forward | `gf` (for `go forward`)

### From mail edition interface

Function | Keybind
--- | ---
save draft | `:w`
send | `gs` (for `go send`)

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

## Credits

  - [Neomutt](https://neomutt.org/)
  - [Alpine](http://alpine.x10host.com/alpine/alpine-info/)
  - [IMAPClient](https://github.com/mjs/imapclient)
    - Class [IMAPClient](https://github.com/mjs/imapclient/blob/580dc6781b5bf9d4f2a1a74b5d4168ef9b842b87/imapclient/imapclient.py#L162)
    - [Example](https://github.com/mjs/imapclient/blob/master/examples/example.py)
    - [Idle example](https://github.com/mjs/imapclient/blob/master/examples/idle_example.py)
  - IMAP [RFC3501](https://tools.ietf.org/html/rfc3501)
    - [Flags](https://tools.ietf.org/html/rfc3501#section-2.3.2)
    - [Status](https://tools.ietf.org/html/rfc3501#section-6.3.10)
    - [Search](https://tools.ietf.org/html/rfc3501#section-6.4.4)
    - [Fetch](https://tools.ietf.org/html/rfc3501#section-7.4.2)
