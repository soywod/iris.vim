let s:dir = expand("<sfile>:h:h:h")
let s:path = resolve(s:dir . "/api.py")
let s:editor = has("nvim") ? "neovim" : "vim8"

function! iris#api#path()
  return s:path
endfunction

function! iris#api#start()
  execute "call iris#api_" . s:editor . "#start()"
endfunction

function! iris#api#send(data)
  execute "call iris#api_" . s:editor . "#send(a:data)"
endfunction

function! iris#api#handle_data(data_raw)
  if empty(a:data_raw) | return | endif
  let data = json_decode(a:data_raw)

  if !data.success
    return iris#utils#elog("server: " . string(data.error))
  endif

  if data.type == "login"
    call iris#cache#write("folders", data.folders)
    call iris#utils#log("logged in!")

  elseif data.type == "select-folder"
    call iris#cache#write("folder", data.folder)
    call iris#cache#write("seq", data.seq)
    call iris#cache#write("emails", data.emails)
    call iris#email#ui#list()
    call iris#utils#log("folder changed!")

  elseif data.type == "fetch-emails"
    call iris#cache#write("emails", data.emails)
    call iris#email#ui#list()
    redraw | echo

  elseif data.type == "fetch-email"
    call iris#email#ui#preview(data.email, data.format)
    call iris#utils#log("email previewed!")

  elseif data.type == "send-email"
    call iris#cache#write("draft", [])
    call iris#utils#log("email sent!")
  endif
endfunction

function! iris#api#handle_close()
  call iris#utils#elog("server: connection lost")
endfunction
