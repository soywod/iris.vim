let s:root = expand('<sfile>:h:h')
let s:api = resolve(s:root . '/api.py')
let s:imapclient = resolve(s:root . '/imapclient')

let g:iris_host  = get(g:, 'iris_host', 'localhost')
let g:iris_email = get(g:, 'iris_email', 'iris')

function! iris#api()
  return s:api
endfunction

function! iris#imapclient()
  return s:imapclient
endfunction

augroup kronos
  autocmd VimLeave * call iris#disconnect()
augroup END
