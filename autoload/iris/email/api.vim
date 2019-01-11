" -------------------------------------------------------------------- # Fetch #

function! iris#email#api#fetch()
  call iris#utils#log('fetching emails...')
  call iris#api#send({
    \'type': 'fetch-emails',
    \'seq': iris#db#read('seq', 0),
  \})
endfunction

" ------------------------------------------------------------------ # Preview #

function! iris#email#api#preview(index, format)
  if a:index < 2 | return iris#utils#elog('email not found') | endif

  let emails = iris#db#read('emails', [])
  let index = a:index - 2
  call iris#db#write('email:index', index)

  call iris#utils#log(printf('previewing email in %s...', a:format))
  call iris#api#send({
    \'type': 'fetch-email',
    \'id': emails[index].id,
    \'format': a:format,
  \})
endfunction

" --------------------------------------------------------------------- # Send #

function! iris#email#api#send(email)
  call iris#utils#log('sending email...')
  call iris#api#send(iris#utils#assign(a:email, {
    \'type': 'send-email',
  \}))
endfunction
