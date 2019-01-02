setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <buffer>        <silent> <CR> :call iris#ui#info('text')<CR>
nnoremap <buffer><nowait><silent> gt   :call iris#ui#info('text')<CR>
nnoremap <buffer><nowait><silent> gh   :call iris#ui#info('html')<CR>
