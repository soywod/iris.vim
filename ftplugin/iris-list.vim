setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <buffer>        <silent> <CR> :call iris#email#api#preview(line("."), "text")<CR>
nnoremap <buffer>        <silent> gp   :call iris#email#api#preview(line("."), "html")<CR>
nnoremap <buffer><nowait><silent> gn   :call iris#email#ui#new()                      <CR>
nnoremap <buffer><nowait><silent> gf   :call iris#folder#ui#select()                  <CR>

" augroup irislist
"   autocmd! * <buffer>
"   autocmd BufDelete <buffer> call iris#api#send({"type": "start-idle"})
" augroup end
