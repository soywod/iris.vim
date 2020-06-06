setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <buffer>          <silent> <cr>  :call iris#api#preview_email(line("."), "text")<cr>
nnoremap <buffer>          <silent> gp    :call iris#api#preview_email(line("."), "html")<cr>
nnoremap <buffer> <nowait> <silent> gn    :call iris#ui#new_email()                      <cr>
nnoremap <buffer> <nowait> <silent> gf    :call iris#ui#select_folder()                  <cr>
