let s:server_path = resolve(expand('<sfile>:h:h') . '/server.py')

let g:iris_host  = get(g:, 'iris_host', 'localhost')
let g:iris_email = get(g:, 'iris_email', 'iris')

function! iris#server_path()
  return s:server_path
endfunction

command! Iris call iris#ui#list_emails()
