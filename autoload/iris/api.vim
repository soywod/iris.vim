let s:compose = function("iris#utils#compose")
let s:editor = has("nvim") ? "neovim" : "vim8"
let s:dir = expand("<sfile>:h:h:h")
let s:path = resolve(s:dir . "/server.py")

function! iris#api#path()
  return s:path
endfunction

" -------------------------------------------------------------------- # Login #

function! iris#api#login()
  execute 'call iris#api#' . s:editor . '#start()'
  redraw | echo

  let imap_password = systemlist(g:iris_show_passwd_cmd)[0]

  call iris#utils#log('logging in...')
  call iris#api#send({
    \'type': 'login',
    \'imap-host': g:iris_imap_host,
    \'imap-port': g:iris_imap_port,
    \'imap-login': g:iris_imap_login,
    \'imap-password': imap_password,
    \'smtp-host': g:iris_smtp_host,
    \'smtp-port': g:iris_smtp_port,
    \'smtp-login': g:iris_smtp_login,
    \'smtp-password': imap_password,
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

  elseif data.type == 'fetch-email'
    call iris#email#ui#preview(data.email, data.format)
    call iris#utils#log('email previewed!')

  elseif data.type == 'send-email'
    call iris#db#write('draft', [])
    call iris#utils#log('email sent!')
  endif
endfunction

" ------------------------------------------------------------- # Handle close #

function! iris#api#handle_close()
  call iris#utils#elog('server: connection lost')
endfunction
