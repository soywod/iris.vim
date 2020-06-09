let s:dir = expand("<sfile>:h:h:h")
let s:path = resolve(s:dir . "/api.py")
let s:job = v:null

function! iris#api#start()
  let s:job = iris#job#start(s:path, function("s:handle_data"))
endfunction

function! s:handle_data(data_raw)
  if empty(a:data_raw) | return | endif
  let data = json_decode(a:data_raw)

  if !data.success
    return iris#utils#elog("api: " . string(data.error))
  endif

  if data.type == "login"
    call iris#cache#write("folders", data.folders)
    call iris#utils#log("logged in!")

  elseif data.type == "select-folder"
    call iris#cache#write("folder", data.folder)
    call iris#cache#write("seq", data.seq)
    call iris#cache#write("page", 0)
    call iris#cache#write("emails", data.emails)
    call iris#ui#list_email()
    call iris#utils#log("folder changed!")

  elseif data.type == "fetch-emails"
    call iris#cache#write("emails", data.emails)
    call iris#ui#list_email()
    redraw | echo

  elseif data.type == "fetch-email"
    call iris#ui#preview_email(data.email, data.format)
    call iris#utils#log("email previewed!")

  elseif data.type == "send-email"
    call iris#cache#write("draft", [])
    call iris#utils#log("email sent!")

  elseif data.type == "extract-contacts"
    call iris#utils#log("contacts extracted!")
  endif
endfunction

function! s:send(data)
  call iris#job#send(s:job, a:data)
endfunction

function! iris#api#login(imap_passwd, smtp_passwd)
  call iris#utils#log("logging in...")
  call s:send({
    \"type": "login",
    \"imap-host": g:iris_imap_host,
    \"imap-port": g:iris_imap_port,
    \"imap-login": g:iris_imap_login,
    \"imap-passwd": a:imap_passwd,
    \"smtp-host": g:iris_smtp_host,
    \"smtp-port": g:iris_smtp_port,
    \"smtp-login": g:iris_smtp_login,
    \"smtp-passwd": a:smtp_passwd,
  \})
endfunction

function! iris#api#select_folder(folder)
  call iris#utils#log("selecting folder...")
  call s:send({
    \"type": "select-folder",
    \"folder": a:folder,
    \"chunk-size": g:iris_emails_chunk_size,
  \})
endfunction

function! iris#api#fetch_all_emails()
  let seq = iris#cache#read("seq", 0)
  let page = iris#cache#read("page", 0)

  call iris#utils#log("fetching emails...")
  call s:send({
    \"type": "fetch-emails",
    \"seq": seq + page,
    \"chunk-size": g:iris_emails_chunk_size,
  \})
endfunction

function! iris#api#prev_page_emails()
  let seq = iris#cache#read("seq", 0)
  let page = iris#cache#read("page", 0) - 1
  if page < 0 | let page = 0 | endif
  call iris#cache#write("page", page)

  call iris#utils#log("fetching previous page...")
  call s:send({
    \"type": "fetch-emails",
    \"seq": seq - (page * g:iris_emails_chunk_size),
    \"chunk-size": g:iris_emails_chunk_size,
  \})
endfunction

function! iris#api#next_page_emails()
  let seq = iris#cache#read("seq", 0)
  let page = iris#cache#read("page", 0) + 1
  call iris#cache#write("page", page)

  call iris#utils#log("fetching next page...")
  call s:send({
    \"type": "fetch-emails",
    \"seq": seq - (page * g:iris_emails_chunk_size),
    \"chunk-size": g:iris_emails_chunk_size,
  \})
endfunction

function! iris#api#preview_email(index, format)
  if a:index < 2 | return iris#utils#elog("email not found") | endif

  let emails = iris#cache#read("emails", [])
  let index = a:index - 2
  call iris#cache#write("email:index", index)

  call iris#utils#log(printf("previewing email in %s...", a:format))
  call s:send({
    \"type": "fetch-email",
    \"id": emails[index].id,
    \"format": a:format,
  \})
endfunction

function! iris#api#send_email(email)
  call iris#utils#log("sending email...")
  call s:send(iris#utils#assign(a:email, {
    \"type": "send-email",
  \}))
endfunction

function! iris#api#add_flag(data)
  call s:send(iris#utils#assign(a:data, {
    \"type": "add-flag",
  \}))
endfunction

function! iris#api#extract_contacts()
  call iris#utils#log("extracting contacts...")
  call s:send({"type": "extract-contacts"})
endfunction
