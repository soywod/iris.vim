let s:root_dir = expand('<sfile>:h:h')
let s:script = resolve(s:root_dir . '/iris.py')

let g:iris_host  = get(g:, 'iris_host', '')
let g:iris_email = get(g:, 'iris_email', '')

let s:const = {
  \'INBOX': {
    \'column': ['id', 'from', 'subject', 'date', 'flags'],
    \'width': {
      \'id': 5,
      \'from': 26,
      \'subject': 29,
      \'date': 16,
      \'flags': 4,
    \},
  \},
\}

function! IrisConnect()
  let password = inputsecret(
    \'Iris password :' .
    \"\n> "
  \)

  redraw
  execute 'python3 import sys; sys.path.insert(0, "'.s:root_dir.'/imapclient")'
  execute 'py3file ' . s:script

  let messages = py3eval('imap_connect()')

  silent! edit Iris
  call append(0, messages)
  normal! ddgg
  setlocal filetype=iris
endfunction
