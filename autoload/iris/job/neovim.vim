function! iris#job#neovim#start(script, handle_data)
  let cmd = printf("python3 '%s'", a:script)
  let opts = {
    \"on_stdout": {id, data, evt -> s:handle_data(id, data, evt, a:handle_data)}
  \}

  return jobstart(cmd, opts)
endfunction

function! s:handle_data(id, raw_data_list, event, handler)
  if empty(a:raw_data_list)
    return iris#job#close()
  endif

  for raw_data in a:raw_data_list
    call a:handler(raw_data)
  endfor
endfunction

function! iris#job#neovim#send(job, data)
  if a:job == 0 | return | endif
  return chansend(a:job, json_encode(a:data) . "\n")
endfunction
