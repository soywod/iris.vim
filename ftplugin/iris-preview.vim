function! IrisThreadFold(lnum)
  return getline(a:lnum)[0] == ">"
endfunction

setlocal buftype=nofile
setlocal cursorline
setlocal foldexpr=IrisThreadFold(v:lnum)
setlocal foldlevel=0
setlocal foldlevelstart=0
setlocal foldmethod=expr
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <silent> <plug>(iris-reply-email)      :call iris#ui#reply_email()    <cr>
nnoremap <silent> <plug>(iris-reply-all-email)  :call iris#ui#reply_all_email()<cr>
nnoremap <silent> <plug>(iris-forward-email)    :call iris#ui#forward_email()  <cr>

call iris#utils#define_maps([
  \["n", "gr", "reply-email"    ],
  \["n", "gR", "reply-all-email"],
  \["n", "gf", "forward-email"  ],
\])
