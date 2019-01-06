let s:compose = function('iris#utils#compose')
let s:editor = has('nvim') ? 'neovim' : 'vim8'
let s:path = resolve(expand('<sfile>:h:h:h') . '/server.py')

let s:started = 0

function! iris#api#path()
  return s:path
endfunction

" -------------------------------------------------------------------- # Start #

function! iris#api#start()
  if s:started | return | endif

  call iris#utils#log('starting the server...')
  execute 'call iris#api#' . s:editor . '#start()'

  call iris#api#login()

  let s:started = 1
endfunction

" -------------------------------------------------------------------- # Login #

function! iris#api#login()
  let prompt = 'Iris: password for ' . g:iris_email . ':' . "\n> "
  let password = s:compose('iris#utils#trim', 'inputsecret')(prompt)

  call iris#utils#log('logging in...')
  call iris#api#send({
    \'type': 'login',
    \'host': g:iris_host,
    \'email': g:iris_email,
    \'password': password,
  \})
endfunction

" --------------------------------------------------------------------- # Send #

function! iris#api#send(data)
  execute 'call iris#api#' . s:editor . '#send(a:data)'
endfunction

" -------------------------------------------------------------- # Handle data #

function! iris#api#handle_data(data_raw)
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
    call iris#email#ui#list()
    call iris#utils#log('folder changed!')

  elseif data.type == 'fetch-emails'
    call iris#db#write('emails', data.emails)
    call iris#email#ui#list()
    redraw | echo

  elseif data.type == 'send-email'
    call iris#db#write('draft', [])
    call iris#utils#log('email sent!')
  endif
endfunction

" ------------------------------------------------------------- # Handle close #

function! iris#api#handle_close()
  call iris#utils#elog('server: connection lost')
endfunction
