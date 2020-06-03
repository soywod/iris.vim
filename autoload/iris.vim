let s:is_started = 0

function! iris#start()
  if s:is_started == 0
    call iris#api#start()
    call iris#auth#api#login()
    call iris#folder#api#select("INBOX")
    let s:is_started = 1
  else
    call iris#email#api#fetch_all()
  endif
endfunction
