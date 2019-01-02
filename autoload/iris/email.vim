let s:seq = 0
let s:mails = []
let s:mail = {}

" ----------------------------------------------------------------- # Read all #

function! iris#email#read_all()
  call iris#utils#log('reading all emails...')
  call iris#server#send({
    \'type': 'read-all-emails',
    \'seq': iris#server#seq(),
  \})
endfunction

" ------------------------------------------------------------------ # Set seq #

function! iris#email#seq(seq)
  let s:seq = a:seq
endfunction
