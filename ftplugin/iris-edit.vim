let s:contacts_path = resolve(expand("<sfile>:h:h") . '/.contacts')
let s:contacts = readfile(s:contacts_path)

function! IrisContactsComplete(findstart, base)
  if (a:findstart == 1)
    normal b
    return col(".") - 1
  else
    return filter(s:contacts, printf("v:val =~ '.*%s.*'", a:base))
  endif
endfunction

function! IrisThreadFold(lnum)
  return getline(a:lnum)[0] == ">"
endfunction

setlocal buftype=acwrite
setlocal completefunc=IrisContactsComplete
setlocal cursorline
setlocal foldexpr=IrisThreadFold(v:lnum)
setlocal foldlevel=0
setlocal foldlevelstart=0
setlocal foldmethod=expr
setlocal nowrap
setlocal omnifunc=IrisContactsComplete
setlocal startofline

nnoremap <silent> <plug>(iris-send-email) :call iris#ui#send_email()<cr>

call iris#utils#define_maps([
  \["n", "gs", "send-email"],
\])

augroup iris
  autocmd! * <buffer>
  autocmd  BufWriteCmd <buffer> call iris#ui#save_email()
augroup end
