setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <buffer><silent> <CR> :call iris#ui#info(line('.') - 2)<CR>
