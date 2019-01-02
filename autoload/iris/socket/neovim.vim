let s:socket = 0

" --------------------------------------------------------------------- # Init #

function! iris#socket#neovim#init()
  let options = {
    \'on_data': function('s:handle_data'),
  \}

  let s:socket = sockconnect('pipe', iris#socket(), options)
  if  s:socket == 0 | throw 0 | endif
endfunction

" -------------------------------------------------------------- # Handle data #

function! s:handle_data(id, raw_data_list, event)
  if empty(a:raw_data_list)
    return iris#socket#handle_close()
  endif

  for raw_data in a:raw_data_list
    call iris#socket#handle_data(raw_data)
  endfor
endfunction

" --------------------------------------------------------------------- # Send #

function! iris#socket#neovim#send(data)
  if s:socket == 0 | return | endif
  return chansend(s:socket, json_encode(a:data))
endfunction
