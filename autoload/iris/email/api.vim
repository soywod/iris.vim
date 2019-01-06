" ------------------------------------------------------------- # Fetch emails #

function! iris#email#api#fetch()
  call iris#utils#log('fetching emails...')
  call iris#api#send({
    \'type': 'fetch-emails',
    \'seq': iris#db#read('seq', 0),
  \})
endfunction

" --------------------------------------------------------------- # Send email #

function! iris#email#api#send(email)
  call iris#utils#log('sending email...')
  call iris#api#send(iris#utils#assign(a:email, {
    \'type': 'send-email',
  \}))
endfunction
