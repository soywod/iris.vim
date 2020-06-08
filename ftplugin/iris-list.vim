setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <silent> <plug>(iris-preview-text-email) :call iris#api#preview_email(line("."), "text")<cr>
nnoremap <silent> <plug>(iris-preview-html-email) :call iris#api#preview_email(line("."), "html")<cr>
nnoremap <silent> <plug>(iris-new-email)          :call iris#ui#new_email()                      <cr>
nnoremap <silent> <plug>(iris-prev-page-emails)   :call iris#api#prev_page_emails()              <cr>
nnoremap <silent> <plug>(iris-next-page-emails)   :call iris#api#next_page_emails()              <cr>
nnoremap <silent> <plug>(iris-select-folder)      :call iris#ui#select_folder()                  <cr>

call iris#utils#define_maps([
  \["n", "<cr>",  "preview-text-email"],
  \["n", "gp",    "preview-html-email"],
  \["n", "gn",    "new-email"         ],
  \["n", "<c-b>", "prev-page-emails"  ],
  \["n", "<c-f>", "next-page-emails"  ],
  \["n", "gf",    "select-folder"     ],
\])
