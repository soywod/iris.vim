let s:job = 0

" --------------------------------------------------------------------- # Init #

function! iris#server#neovim#start()
  let cmd = printf('python3 "%s"', iris#server#path())
  let opts = {'on_stdout': function('s:handle_stdout')}
  let s:job = jobstart(cmd, opts)
endfunction

" ------------------------------------------------------------ # Handle stdout #

function! s:handle_stdout(id, raw_data_list, event)
  if empty(a:raw_data_list)
    return iris#server#handle_close()
  endif

  for raw_data in a:raw_data_list
    call iris#server#handle_data(raw_data)
  endfor
endfunction

" --------------------------------------------------------------------- # Send #

function! iris#server#neovim#send(data)
  if s:job == 0 | return | endif
  return chansend(s:job, json_encode(a:data) . "\n")
endfunction
