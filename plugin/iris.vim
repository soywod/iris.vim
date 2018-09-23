let s:root_dir = expand('<sfile>:h:h')
let s:script = resolve(s:root_dir . '/iris.py')

let g:iris_host  = get(g:, 'iris_host', '')
let g:iris_email = get(g:, 'iris_email', '')

function! IrisConnect()
  let password = inputsecret(
    \'Iris password :' .
    \"\n> "
  \)

  redraw
  execute 'python import sys; sys.path.insert(0, "'.s:root_dir.'/imapclient")'
  execute 'pyfile ' . s:script

  let messages = map(pyeval('imap_connect()'), 'v:val[0] . " [" . join(v:val[1]["FLAGS"], ", ") . "]"')

  silent! edit Iris
  call append(0, messages)
  normal! ddgg
  setlocal filetype=iris
endfunction
