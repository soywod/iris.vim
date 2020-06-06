let s:dir = expand("<sfile>:h:h:h")
let s:path = resolve(s:dir . "/idle.py")
let s:job = v:null

function! iris#idle#start()
  let s:job = iris#job#start(s:path, function("s:handle_data"))
endfunction

function! s:handle_data(data_raw)
  if empty(a:data_raw) | return | endif
  let data = json_decode(a:data_raw)

  if !data.success
    return iris#utils#elog("idle: " . string(data.error))
  endif
endfunction

function! s:send(data)
  call iris#job#send(s:job, a:data)
endfunction

function! iris#idle#login(passwd)
  call s:send({
    \"type": "login",
    \"imap-host": g:iris_imap_host,
    \"imap-port": g:iris_imap_port,
    \"imap-login": g:iris_imap_login,
    \"imap-password": a:passwd,
    \"idle-timeout": g:iris_idle_timeout,
  \})
endfunction
