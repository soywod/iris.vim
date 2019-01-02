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

  execute 'call iris#server#' . s:editor . '#start()'
  call iris#server#login()

  let s:started = 1
endfunction

" -------------------------------------------------------------------- # Login #

function! iris#server#login()
  let prompt = 'Iris: password for ' . g:iris_email . ':' . "\n> "
  let password = s:compose('iris#utils#trim', 'inputsecret')(prompt)

  call iris#server#send({
    \'type': 'login',
    \'host': g:iris_host,
    \'email': g:iris_email,
    \'password': password,
  \})
endfunction

" ---------------------------------------------------------- # Read all emails #

function! iris#server#read_all_emails()
  call iris#server#send({
    \'type': 'read-all-emails',
    \'seq': iris#db#read('seq', 0),
  \})
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
    return iris#utils#error_log('server: ' . string(data))
  endif

  if data.type == 'login'
    call iris#db#write('seq', data.seq)

  elseif data.type == 'read-all-emails'
    call iris#db#write('emails', data.emails)
    call iris#ui#list()
  endif
endfunction

" ------------------------------------------------------------- # Handle close #

function! iris#server#handle_close()
  call iris#utils#error_log('server: connection lost')
endfunction
