let s:curr_data = ""

function! iris#job#neovim#start(script, handle_data)
  let cmd = printf("python3 '%s'", a:script)
  let opts = {
    \"on_stdout": {_, data, __ -> s:handle_data(data, a:handle_data)},
  \}

  return jobstart(cmd, opts)
endfunction

function! s:handle_data(raw_data_list, handler)
  let curr_list = a:raw_data_list
  if empty(curr_list) | return iris#job#close() | endif

  while 1
    let eof = index(curr_list, "")

    if eof == -1
      let s:curr_data .= join(curr_list, "")
      break
    else
      let prev_list = curr_list[:eof-1]
      let curr_list = curr_list[eof+1:]
      let s:curr_data .= join(prev_list, "")
      call a:handler(s:curr_data)
      let s:curr_data = join(curr_list, "")
    endif
  endwhile
endfunction

function! iris#job#neovim#send(job, data)
  if a:job == 0 | return | endif
  return chansend(a:job, json_encode(a:data) . "\n")
endfunction
