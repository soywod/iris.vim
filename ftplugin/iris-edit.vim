function! IrisFold(lnum)
  return getline(a:lnum)[0] == '>'
endfunction

setlocal buftype=acwrite
setlocal cursorline
setlocal foldexpr=IrisFold(v:lnum)
setlocal foldlevel=0
setlocal foldlevelstart=0
setlocal foldmethod=expr
setlocal nowrap
setlocal startofline

nnoremap <buffer><nowait><silent> gs :call iris#email#ui#send()<CR>

augroup iris
  autocmd! * <buffer>
  autocmd  BufWriteCmd <buffer> call iris#email#ui#save()
augroup end
