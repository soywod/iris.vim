let s:compose = function('iris#utils#compose')
let s:editor = has('nvim') ? 'neovim' : 'vim8'
let s:path = resolve(expand('<sfile>:h:h:h') . '/server.py')

let s:started = 0

function! iris#server#path()
  return s:path
endfunction

" -------------------------------------------------------------------- # Start #

function! iris#server#start()
  if s:started | return | endif

  call iris#utils#log('starting the server...')
  execute 'call iris#server#' . s:editor . '#start()'

  call iris#server#login()

  let s:started = 1
endfunction

" -------------------------------------------------------------------- # Login #

function! iris#server#login()
  let prompt = 'Iris: password for ' . g:iris_email . ':' . "\n> "
  let password = s:compose('iris#utils#trim', 'inputsecret')(prompt)

  call iris#utils#log('logging in...')
  call iris#server#send({
    \'type': 'login',
    \'host': g:iris_host,
    \'email': g:iris_email,
    \'password': password,
  \})
endfunction

" ------------------------------------------------------------- # Fetch emails #

function! iris#server#fetch_emails()
  call iris#utils#log('fetching emails...')
  call iris#server#send({
    \'type': 'fetch-emails',
    \'seq': iris#db#read('seq', 0),
  \})
endfunction

" ------------------------------------------------------------ # Select folder #

function! iris#server#select_folder(folder)
  call iris#utils#log('selecting folder...')
  call iris#server#send({
    \'type': 'select-folder',
    \'folder': a:folder,
  \})
endfunction

" --------------------------------------------------------------- # Send email #

function! iris#server#send_email(email)
  call iris#utils#log('sending email...')
  call iris#server#send(iris#utils#assign(a:email, {
    \'type': 'send-email',
  \}))
endfunction

" --------------------------------------------------------------------- # Send #

function! iris#server#send(data)
  execute 'call iris#server#' . s:editor . '#send(a:data)'
endfunction

" -------------------------------------------------------------- # Handle data #

function! iris#server#handle_data(data_raw)
  if empty(a:data_raw) | return | endif
  let data = json_decode(a:data_raw)

  if !data.success
    return iris#utils#elog('server: ' . string(data.error))
  endif

  if data.type == 'login'
    call iris#db#write('folders', data.folders)
    call iris#utils#log('logged in!')

  elseif data.type == 'select-folder'
    call iris#db#write('folder', data.folder)
    call iris#db#write('seq', data.seq)
    call iris#db#write('emails', data.emails)
    call iris#ui#list_emails()
    call iris#utils#log('folder changed!')

  elseif data.type == 'fetch-emails'
    call iris#db#write('emails', data.emails)
    call iris#ui#list_emails()
    redraw | echo

  elseif data.type == 'send-email'
    call iris#db#write('draft', [])
    call iris#utils#log('email sent!')
  endif
endfunction

" ------------------------------------------------------------- # Handle close #

function! iris#server#handle_close()
  call iris#utils#elog('server: connection lost')
endfunction
