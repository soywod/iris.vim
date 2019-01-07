setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <buffer>        <silent> <CR> :call iris#email#ui#preview('text')<CR>
nnoremap <buffer><nowait><silent> gp   :call iris#email#ui#preview('html')<CR>
nnoremap <buffer><nowait><silent> gn   :call iris#email#ui#new()          <CR>
nnoremap <buffer><nowait><silent> gr   :call iris#email#ui#reply()        <CR>
nnoremap <buffer><nowait><silent> gR   :call iris#email#ui#reply_all()    <CR>
nnoremap <buffer><nowait><silent> gf   :call iris#email#ui#forward()      <CR>
