let s:editor = has('nvim') ? 'neovim' : 'vim8'

" --------------------------------------------------------------------- # Init #

function! iris#socket#init(password)
  try
    execute 'call iris#socket#' . s:editor . '#init()'
  catch 'channel'
    return iris#utils#error_log('socket: missing option +channel')
  catch 'job'
    return iris#utils#error_log('socket: missing option +job')
  catch 'version'
    return iris#utils#error_log('socket: missing vim8+')
  catch
    return iris#utils#error_log('socket: init failed')
  endtry

  call iris#socket#send({
    \'type': 'login',
    \'host': g:iris_host,
    \'email': g:iris_email,
    \'password': a:password,
  \})
endfunction

" -------------------------------------------------------------- # Handle data #

function! iris#socket#handle_data(data_raw)
  if empty(a:data_raw) | return | endif
  let data = json_decode(a:data_raw)

  if !data.success
    return iris#utils#error_log('socket: ' . string(data))
  endif

  if data.type == 'login'
    redraw | echo 'Listing mails...'
    call iris#controller#seq(data)
    return iris#socket#send({'type': 'list', 'seq': data.seq})

  elseif data.type == 'list'
    redraw | echo 'Done!'
    return iris#controller#list(data)
  endif
endfunction

" ------------------------------------------------------------- # Handle close #

function! iris#socket#handle_close()
  call iris#utils#error_log('socket: connection lost')
endfunction

" --------------------------------------------------------------------- # Send #

function! iris#socket#send(data)
  execute 'call iris#socket#' . s:editor . '#send(a:data)'
endfunction
