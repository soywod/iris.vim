let s:password = ''
let s:socket = 0

" ------------------------------------------------------------- # Start server #

function! iris#start_server()
  let prompt = '[Iris] Password for ' . g:iris_email . ':' . "\n> "
  let s:password = inputsecret(prompt)
  if empty(s:password) | return | endif

  let server = iris#server()
  let socket = iris#socket()
  let command = join(['python3', server, socket], ' ')

  return jobstart(command, {})
endfunction

" -------------------------------------------------------------------- # Login #

function! iris#login()
  redraw | echo 'Connecting...'
  let s:socket = sockconnect('pipe', iris#socket(), {'on_data': 'iris#on_data'})

  let payload = {'type': 'login'}
  let payload.host = g:iris_host
  let payload.email = g:iris_email
  let payload.password = s:password

  call chansend(s:socket, json_encode(payload))
endfunction

function! iris#on_data(id, raw_request, event)
  for raw_request in a:raw_request[:-1]
    let request = json_decode(raw_request)

    if request.type == 'login'
      redraw | echo 'Listing mails...'
      call iris#controller#seq(request)
      let response = {'type': 'list', 'seq': request.seq }
      return chansend(s:socket, json_encode(response))
    endif

    if request.type == 'list'
      redraw | echo 'Done!'
      return iris#controller#list(request)
    endif
  endfor
endfunction
