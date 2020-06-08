function! iris#job#neovim#start(script, handle_data)
  let cmd = printf("python3 '%s'", a:script)
  let opts = {
    \"on_stdout": {_, data, __ -> s:handle_data(data, a:handle_data)},
  \}

  return jobstart(cmd, opts)
endfunction

function! s:handle_data(raw_data_list, handler)
  let raw_data_list = a:raw_data_list
  if empty(raw_data_list) | return iris#job#close() | endif

  while 1
    let eof = index(raw_data_list, "")
    let raw_data = raw_data_list[:eof-1]
    let raw_data_list = raw_data_list[eof+1:]
    call a:handler(join(raw_data, ""))
    if eof == -1 | break | endif
  endwhile
endfunction

function! iris#job#neovim#send(job, data)
  if a:job == 0 | return | endif
  return chansend(a:job, json_encode(a:data) . "\n")
endfunction
