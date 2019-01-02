" ------------------------------------------------------------------- # Config #

let s:config = {
  \'list': {
    \'columns': ['from', 'subject', 'date', 'flags'],
  \},
  \'labels': {
    \'from': 'FROM',
    \'subject': 'SUBJECT',
    \'date': 'DATE',
    \'flags': 'FLAGS',
  \},
\}

" --------------------------------------------------------------------- # List #

function! iris#ui#list()
  let emails = iris#db#read('emails', [])

  silent! bdelete 'Iris'
  silent! edit Iris

  call append(0, s:render('list', emails))
  normal! ddgg
  setlocal filetype=iris-list
endfunction

" --------------------------------------------------------------------- # Info #

function! iris#ui#info(type)
  let emails = iris#db#read('emails', [])
  let index = line('.') - 2
  if  index == -1 | throw 'email not found' | endif

  let email = copy(emails[index])

  if a:type == 'text'
    let email.content.text = substitute(email.content.text, '', '', 'g')

    silent! bdelete 'Iris preview'
    silent! edit Iris preview
    call append(0, split(email.content.text, '\n'))
    normal! ddgg
    setlocal filetype=iris-info

  elseif a:type == 'html'
    let url = email.content.html
    execute 'python3 import webbrowser; webbrowser.open_new("'.url.'")'
  endif
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

function! s:get_focused_task_id()
  let emails = iris#db#read('emails', [])
  let index = line('.') - 2
  if  index == -1 | throw 'email not found' | endif

  return +get(emails, index).id
endfunction
