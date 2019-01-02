let s:db = {}

" ----------------------------------------------------------------- # Read all #

function! iris#email#read_all()
  call iris#utils#log('reading all emails...')
  call iris#server#send({
    \'type': 'read-all-emails',
    \'seq': iris#server#seq(),
  \})
endfunction

" ----------------------------------------------------------------- # Database #

function! iris#db#read(key, default_val)
  return has_key(s:db, a:key) ? copy(s:db[a:key]) : copy(a:default_val)
endfunction

function! iris#db#write(key, val)
  let s:db[a:key] = copy(a:val)
endfunction
