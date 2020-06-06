function! IrisFold(lnum)
  return getline(a:lnum)[0] == ">"
endfunction

setlocal buftype=nofile
setlocal cursorline
setlocal foldexpr=IrisFold(v:lnum)
setlocal foldlevel=0
setlocal foldlevelstart=0
setlocal foldmethod=expr
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <buffer> <nowait> <silent> gr  :call iris#ui#reply_email()    <cr>
nnoremap <buffer> <nowait> <silent> gR  :call iris#ui#reply_all_email()<cr>
nnoremap <buffer> <nowait> <silent> gf  :call iris#ui#forward_email()  <cr>
