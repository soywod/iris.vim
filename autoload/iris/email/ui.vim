" ------------------------------------------------------------------- # Config #

let s:config = {
  \'list.from': {
    \'columns': ['from', 'subject', 'date', 'flags'],
  \},
  \'list.to': {
    \'columns': ['to', 'subject', 'date', 'flags'],
  \},
  \'labels': {
    \'from': 'FROM',
    \'to': 'TO',
    \'subject': 'SUBJECT',
    \'date': 'DATE',
    \'flags': 'FLAGS',
  \},
\}

" --------------------------------------------------------------------- # List #

function! iris#email#ui#list()
  redraw | echo
  let folder = iris#db#read('folder', 'INBOX')
  let emails = iris#db#read('emails', [])
  let template = printf('list.%s', folder == 'Sent' ? 'to' : 'from')

  silent! bdelete Iris
  silent! edit Iris

  call append(0, s:render(template, emails))
  normal! ddgg
  setlocal filetype=iris-list
endfunction

" ------------------------------------------------------------------ # Preview #

function! iris#email#ui#preview(email, format)
  if a:format == 'text'
    let email = substitute(a:email, '', '', 'g')

    silent! bdelete 'Iris preview'
    silent! edit Iris preview
    call append(0, split(email, '\n'))
    normal! ddgg
    setlocal filetype=iris-preview

  elseif a:format == 'html'
    let url = a:email
    execute 'python3 import webbrowser; webbrowser.open_new("'.url.'")'
  endif
endfunction

" ---------------------------------------------------------------------- # New #

function! iris#email#ui#new()
  silent! bdelete 'Iris new'
  silent! edit Iris new

  call append(0, [
    \'To: ',
    \'CC: ',
    \'BCC: ',
    \'Subject: ',
    \'---',
    \'',
  \])

  normal! ddgg$

  setlocal filetype=iris-edit
  let &modified = 0
endfunction

" -------------------------------------------------------------------- # Reply #

function! iris#email#ui#reply()
  let index = iris#db#read('email:index', 0)
  let email = iris#db#read('emails', [])[index]
  let message = map(getline(1, '$'), "'>' . v:val")

  silent! bdelete 'Iris reply'
  silent! edit Iris reply

  call append(0, [
    \'To: ' . email.from,
    \'CC: ',
    \'BCC: ',
    \'Subject: RE: ' . email.subject,
    \'---',
    \'',
  \] + message)

  normal! dd6G

  setlocal filetype=iris-edit
  let &modified = 0
endfunction

" ---------------------------------------------------------------- # Reply all #

function! iris#email#ui#reply_all()
  let index = iris#db#read('email:index', 0)
  let email = iris#db#read('emails', [])[index]
  let message = map(getline(1, '$'), "'>' . v:val")

  silent! bdelete 'Iris reply all'
  silent! edit Iris reply all

  call append(0, [
    \'To: ' . email.from,
    \'CC: ' . (has_key(email, 'cc') ? email.cc : ''),
    \'BCC: ' . (has_key(email, 'bcc') ? email.bcc : ''),
    \'Subject: RE: ' . email.subject,
    \'---',
    \'',
  \] + message)

  normal! dd6G

  setlocal filetype=iris-edit
  let &modified = 0
endfunction

" ------------------------------------------------------------------ # Forward #

function! iris#email#ui#forward()
  let index = iris#db#read('email:index', 0)
  let email = iris#db#read('emails', [])[index]
  let message = getline(1, '$')

  silent! bdelete 'Iris forward'
  silent! edit Iris forward

  call append(0, [
    \'To: ',
    \'CC: ',
    \'BCC: ',
    \'Subject: FW: ' . email.subject,
    \'---',
    \'',
    \'---------- Forwarded message ---------',
  \] + message)

  normal! ddgg$

  setlocal filetype=iris-edit
  let &modified = 0
endfunction

" --------------------------------------------------------------------- # Save #

function! iris#email#ui#save()
  call iris#db#write('draft', getline(1, '$'))
  call iris#utils#log('draft saved!')

  let &modified = 0
endfunction

" --------------------------------------------------------------------- # Send #

function! iris#email#ui#send()
  redraw | echo
  let draft = iris#db#read('draft', [])

  let message = join(draft[5:], "\r\n")

  let headers = {}
  let headers['from-name'] = g:iris_name
  let headers['from-email'] = g:iris_email
  let headers['to'] = iris#utils#trim(split(draft[0], ':')[1])
  let headers['subject'] = iris#utils#trim(join(split(draft[3], ':')[1:], ':'))

  let cc = iris#utils#trim(split(draft[1], ':')[1])
  if !empty(cc) | let headers['cc'] = cc | endif

  let bcc = iris#utils#trim(split(draft[2], ':')[1])
  if !empty(bcc) | let headers['bcc'] = bcc | endif

  silent! bdelete
  call iris#email#api#send({'headers': headers, 'message': message})
endfunction

" ------------------------------------------------------------------ # Renders #

function! s:render(type, lines)
  let s:max_widths = s:get_max_widths(a:lines, s:config[a:type].columns)
  let header = [s:render_line(s:config.labels, s:max_widths, a:type)]
  let line = map(copy(a:lines), 's:render_line(v:val, s:max_widths, a:type)')

  return header + line
endfunction

function! s:render_line(line, max_widths, type)
  return '|' . join(map(
    \copy(s:config[a:type].columns),
    \'s:render_cell(a:line[v:val], a:max_widths[v:key])',
  \), '')
endfunction

function! s:render_cell(cell, max_width)
  let cell_width = strdisplaywidth(a:cell[:a:max_width])
  return a:cell[:a:max_width] . repeat(' ', a:max_width - cell_width) . ' |'
endfunction

" -------------------------------------------------------------------- # Utils #

function! s:get_max_widths(lines, columns)
  let max_widths = map(copy(a:columns), 'strlen(s:config.labels[v:val])')

  for line in a:lines
    let widths = map(copy(a:columns), 'strlen(line[v:val])')
    call map(max_widths, 'max([widths[v:key], v:val])')
  endfor

  return max_widths
endfunction

function! s:get_focused_email()
  let emails = iris#db#read('emails', [])
  let index = line('.') - 2
  if  index < 0 | throw 'email not found' | endif
  
  return emails[index]
endfunction
