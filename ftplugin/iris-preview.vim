function! IrisFold(lnum)
  return getline(a:lnum)[0] == '>'
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

nnoremap <buffer><nowait><silent> <C-CR> :call iris#ui#preview_email('html')<CR>
