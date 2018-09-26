let s:const = {
  \'column': ['from', 'subject', 'date', 'flags'],
  \'width': {
    \'from': 21,
    \'subject': 37,
    \'date': 16,
    \'flags': 6,
  \},
  \'label': {
    \'from': 'FROM',
    \'subject': 'SUBJECT',
    \'date': 'DATE',
    \'flags': 'FLAGS',
  \},
\}

" --------------------------------------------------------------------- # Info #

function! iris#view#info(mail)
  let mail = copy(a:mail)
  let mail.content.text = substitute(mail.content.text, '', '', 'g')

  silent! edit Iris viewer
  call append(0, split(mail.content.text, '\n'))
  normal! ddgg
  setlocal filetype=iris-viewer
endfunction

" --------------------------------------------------------------------- # List #

function! iris#view#list(mails)
  let columns = s:const.column
  let labels  = s:const.label

  let header  = [filter(copy(s:const.label), 'index(columns, v:key) + 1')]

  let thead = map(copy(header), function('s:PrintHead'))
  let tbody = map(copy(a:mails), function('s:PrintBody'))

  silent! edit Iris
  call append(0, thead + tbody)
  normal! ddgg
  setlocal filetype=iris
endfunction

" ------------------------------------------------------------------ # Helpers #

function! s:PrintHead(_, header)
  return s:PrintRow(a:header)
endfunction

function! s:PrintBody(_, mail)
  return s:PrintRow(a:mail)
endfunction

function! s:PrintRow(row)
  let columns = s:const.column
  let widths  = s:const.width

  return join(map(
    \copy(columns),
    \'s:PrintProp(a:row[v:val], widths[v:val])',
  \), '')[:78] . ' '
endfunction

function! s:PrintProp(prop, maxlen)
  let maxlen = a:maxlen - 2
  let proplen = strdisplaywidth(a:prop[:maxlen]) + 1

  return a:prop[:maxlen] . repeat(' ', a:maxlen - proplen) . '|'
endfunction
