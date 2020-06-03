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

nnoremap <buffer><nowait><silent> gr :call iris#email#ui#reply()    <CR>
nnoremap <buffer><nowait><silent> gR :call iris#email#ui#reply_all()<CR>
nnoremap <buffer><nowait><silent> gf :call iris#email#ui#forward()  <CR>
