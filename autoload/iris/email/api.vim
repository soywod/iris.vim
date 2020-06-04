function! iris#email#api#fetch_all()
  " call iris#utils#log("stopping idle mode...")
  " call iris#api#send({"type": "stop-idle"})

  call iris#utils#log("fetching emails...")
  call iris#api#send({
    \"type": "fetch-emails",
    \"seq": iris#cache#read("seq", 0),
  \})
endfunction

function! iris#email#api#preview(index, format)
  if a:index < 2 | return iris#utils#elog("email not found") | endif

  let emails = iris#cache#read("emails", [])
  let index = a:index - 2
  call iris#cache#write("email:index", index)

  call iris#utils#log(printf("previewing email in %s...", a:format))
  call iris#api#send({
    \"type": "fetch-email",
    \"id": emails[index].id,
    \"format": a:format,
  \})
endfunction

function! iris#email#api#send(email)
  call iris#utils#log("sending email...")
  call iris#api#send(iris#utils#assign(a:email, {
    \"type": "send-email",
  \}))
endfunction
