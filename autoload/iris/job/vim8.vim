function! iris#job#vim8#start(script, handle_data)
  if v:version < 800 | throw "version" | endif
  if !has("job") | throw "job" | endif
  if !has("channel") | throw "channel" | endif

  let cmd = printf("python3 '%s'", a:script)
  let options = {
    \"in_mode": "nl",
    \"out_mode": "nl",
    \"out_cb": {_, data -> s:handle_data(data, a:handle_data)},
    \"close_cb": function("iris#job#close"),
  \}

  return job_start(["/bin/sh", "-c", cmd], options)
endfunction

function! s:handle_data(raw_data, handler)
  return a:handler(a:raw_data)
endfunction

function! iris#job#vim8#send(job, data)
  if job_status(a:job) != "run" | return | endif
  let channel = job_getchannel(a:job)
  return ch_sendraw(channel, json_encode(a:data) . "\n")
endfunction
