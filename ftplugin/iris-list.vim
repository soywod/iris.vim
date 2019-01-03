setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <buffer>        <silent> <CR>    :call iris#ui#preview_email('text')<CR>
nnoremap <buffer><nowait><silent> <C-CR>  :call iris#ui#preview_email('html')<CR>
nnoremap <buffer><nowait><silent> <S-CR>  :call iris#ui#preview_email('html')<CR>
nnoremap <buffer><nowait><silent> <M-CR>  :call iris#ui#preview_email('html')<CR>
nnoremap <buffer><nowait><silent> gn      :call iris#ui#new()                <CR>
