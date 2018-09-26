let s:last_seq = 0
let s:mails = []
let s:mail = {}

" --------------------------------------------------------------------- # Info #

function! iris#controller#info(request)
  let s:mail = s:mails[a:request.index]
  return iris#view#info(s:mail)
endfunction

" --------------------------------------------------------------------- # List #

function! iris#controller#list(request)
  let s:mails = a:request.mails
  return iris#view#list(s:mails)
endfunction

" ---------------------------------------------------------------------- # Seq #

function! iris#controller#seq(request)
  let s:last_seq = a:request.seq
endfunction

" ------------------------------------------------------------------ # Preview #

function! iris#controller#preview()
  let url = s:mail.content.html
  execute 'python3 import webbrowser; webbrowser.open_new("'.url.'")'
endfunction
