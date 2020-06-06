function! IrisThreadFold(lnum)
  return getline(a:lnum)[0] == ">"
endfunction

setlocal buftype=acwrite
setlocal cursorline
setlocal foldexpr=IrisThreadFold(v:lnum)
setlocal foldlevel=0
setlocal foldlevelstart=0
setlocal foldmethod=expr
setlocal nowrap
setlocal startofline

nnoremap <silent> <plug>(iris-send-email) :call iris#ui#send_email()<cr>

call iris#utils#define_maps([
  \["n", "gs", "send-email"],
\])

augroup iris
  autocmd! * <buffer>
  autocmd  BufWriteCmd <buffer> call iris#ui#save_email()
augroup end
