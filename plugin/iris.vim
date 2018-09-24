let s:root_dir = expand('<sfile>:h:h')
let s:script = resolve(s:root_dir . '/iris.py')

let g:iris_host  = get(g:, 'iris_host', '')
let g:iris_email = get(g:, 'iris_email', '')

let s:const = {
  \'column': ['id', 'from', 'subject', 'date', 'flags'],
  \'width': {
    \'id': 6,
    \'from': 25,
    \'subject': 27,
    \'date': 16,
    \'flags': 6,
  \},
  \'label': {
    \'id': 'ID',
    \'from': 'FROM',
    \'subject': 'SUBJECT',
    \'date': 'DATE',
    \'flags': 'FLAGS',
  \},
\}

function! IrisConnect()
  let password = inputsecret(
    \'Iris password :' .
    \"\n> "
  \)

  redraw
  echo 'Loading...'
  execute 'python3 import sys; sys.path.insert(0, "'.s:root_dir.'/imapclient")'
  execute 'py3file ' . s:script

  let columns = s:const.column
  let labels  = s:const.label

  let header   = [filter(copy(s:const.label), 'index(columns, v:key) + 1')]
  let messages = py3eval('imap_connect()')

  let thead = map(copy(header), function('s:PrintHead'))
  let tbody = map(copy(messages), function('s:PrintBody'))

  silent! edit Iris
  call append(0, thead + tbody)
  normal! ddgg
  setlocal filetype=iris
endfunction

function! s:PrintRow(row)
  let columns = s:const.column
  let widths  = s:const.width

  return join(map(
    \copy(columns),
    \'s:PrintProp(a:row[v:val], widths[v:val])',
  \), '')[:78] . ' '
endfunction

function! s:PrintHead(_, header)
  return s:PrintRow(a:header)
endfunction

function! s:PrintBody(_, mail)
  return s:PrintRow(a:mail)
endfunction

function! s:PrintProp(prop, maxlen)
  let maxlen = a:maxlen - 2
  let proplen = strdisplaywidth(a:prop[:maxlen]) + 1

  return a:prop[:maxlen] . repeat(' ', a:maxlen - proplen) . '|'
endfunction
