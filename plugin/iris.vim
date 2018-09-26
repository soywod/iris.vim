let s:root = expand('<sfile>:h:h')
let s:api = resolve(s:root . '/api.py')
let s:imapclient = resolve(s:root . '/imapclient')
let s:server = resolve(s:root . '/server.py')
let s:socket = expand('$XDG_RUNTIME_DIR/iris.sock')

let g:iris_host  = get(g:, 'iris_host', 'localhost')
let g:iris_email = get(g:, 'iris_email', 'iris')

function! iris#api()
  return s:api
endfunction

function! iris#server()
  return s:server
endfunction

function! iris#socket()
  return s:socket
endfunction

command! Iris call iris#login()

augroup iris
  autocmd VimEnter * call iris#start_server()
augroup END
