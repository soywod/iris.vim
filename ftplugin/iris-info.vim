function! IrisFold(lnum)
  return getline(a:lnum)[0] == '>' || getline(a:lnum + 1)[0] == '>' || getline(a:lnum + 2)[0] == '>'
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

nnoremap <buffer><nowait><silent> gh :call iris#ui#info('html')<CR>
