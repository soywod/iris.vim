function! IrisFold(lnum)
  return getline(a:lnum)[0] == '>' || getline(a:lnum + 1)[0] == '>' || getline(a:lnum + 2)[0] == '>'
endfunction

setlocal buftype=acwrite
setlocal cursorline
setlocal foldexpr=IrisFold(v:lnum)
setlocal foldlevel=0
setlocal foldlevelstart=0
setlocal foldmethod=expr
setlocal nowrap
setlocal startofline

nnoremap <buffer><nowait><silent> gs :call iris#ui#send_draft()<CR>

augroup iris
  autocmd! * <buffer>
  autocmd  BufWriteCmd <buffer> call iris#ui#save_draft()
augroup end
