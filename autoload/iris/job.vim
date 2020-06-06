let s:editor = has("nvim") ? "neovim" : "vim8"

function! iris#job#start(path, handle_data)
  execute "return iris#job#" . s:editor . "#start(a:path, a:handle_data)"
endfunction

function! iris#job#send(job, data)
  execute "call iris#job#" . s:editor . "#send(a:job, a:data)"
endfunction

function! iris#job#close()
  call iris#utils#elog("job: connection lost")
endfunction
