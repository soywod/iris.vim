let s:job = {}

" --------------------------------------------------------------------- # Init #

function! iris#api#vim8#start()
  if v:version < 800 | throw 'version' | endif
  if !has('job') | throw 'job' | endif
  if !has('channel') | throw 'channel' | endif

  " let cmd = printf('python3 "%s"', iris#api#path())
  let cmd = printf('python3 "%s"', iris#api#path())
  let options = {
    \'in_mode': 'nl',
    \'out_mode': 'nl',
    \'out_cb': function('s:handle_out'),
    \'close_cb': function('s:handle_close'),
  \}

  let s:job = job_start(cmd, options)
endfunction

" --------------------------------------------------------------- # Handle out #

function! s:handle_out(id, raw_data)
  echom 'data'
  echom string(a:raw_data)
  return iris#api#handle_data(a:raw_data)
endfunction

" ------------------------------------------------------------- # Handle close #

function! s:handle_close(channel)
  echom 'close'
  return iris#api#handle_close()
endfunction

" --------------------------------------------------------------------- # Send #

function! iris#api#vim8#send(data)
  if job_status(s:job) != 'run' | return | endif
  let channel = job_getchannel(s:job)

  return ch_sendraw(channel, json_encode(a:data) . "\n")
endfunction
