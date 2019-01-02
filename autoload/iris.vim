let s:password = ''

" ------------------------------------------------------------- # Start server #

function! iris#start_server()
  let prompt = 'Iris: password for ' . g:iris_email . ':' . "\n> "
  let s:password = inputsecret(prompt)
  if empty(s:password) | return | endif

  let server = iris#server()
  let socket = iris#socket()
  let command = join(['python3', server, socket], ' ')

  return jobstart(command, {})
endfunction

" -------------------------------------------------------------------- # Login #

function! iris#login()
  call iris#utils#log('connecting...')
  call iris#socket#init(s:password)
endfunction
