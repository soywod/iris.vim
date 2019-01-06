setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <buffer>        <silent> <CR> :call iris#email#ui#preview('text')<CR>
nnoremap <buffer><nowait><silent> gp   :call iris#email#ui#preview('html')<CR>
nnoremap <buffer><nowait><silent> gn   :call iris#email#ui#edit({})       <CR>
