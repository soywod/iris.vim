let s:config = {
  \"list.from": {
    \"columns": ["from", "subject", "date", "flags"],
  \},
  \"list.to": {
    \"columns": ["to", "subject", "date", "flags"],
  \},
  \"labels": {
    \"from": "FROM",
    \"to": "TO",
    \"subject": "SUBJECT",
    \"date": "DATE",
    \"flags": "FLAGS",
  \},
\}

function! iris#email#ui#list()
  redraw | echo
  let folder = iris#cache#read("folder", "INBOX")
  let emails = iris#cache#read("emails", [])
  let template = printf("list.%s", folder == "Sent" ? "to" : "from")

  silent! bdelete Iris
  silent! edit Iris

  call append(0, s:render(template, emails))
  normal! ddgg
  setlocal filetype=iris-list
endfunction

function! iris#email#ui#preview(email, format)
  if a:format == "text"
    let email = substitute(a:email, "", "", "g")

    silent! bdelete "Iris preview"
    silent! edit Iris preview
    call append(0, split(email, "\n"))
    normal! ddgg
    setlocal filetype=iris-preview

  elseif a:format == "html"
    let url = a:email
    execute "python3 import webbrowser; webbrowser.open_new('".url."')"
  endif
endfunction

function! iris#email#ui#new()
  silent! bdelete "Iris new"
  silent! edit Iris new

  call append(0, [
    \"To: ",
    \"Cc: ",
    \"Bcc: ",
    \"Subject: ",
    \"",
  \])

  normal! ddgg$

  setlocal filetype=iris-edit
  let &modified = 0
endfunction

function! iris#email#ui#reply()
  let index = iris#cache#read("email:index", 0)
  let email = iris#cache#read("emails", [])[index]
  let message = map(getline(1, "$"), "'>' . v:val")

  if empty(email["reply-to"])
    let reply_to = email["from"]
  else
    let reply_to = email["reply-to"]
  endif

  echom string(email)
  silent! bdelete "Iris reply"
  silent! edit Iris reply

  call append(0, [
    \"In-Reply-To: " . email["message-id"],
    \"To: " . reply_to,
    \"Cc: ",
    \"Bcc: ",
    \"Subject: Re: " . email.subject,
    \"",
  \] + message)

  normal! dd6G

  setlocal filetype=iris-edit
  let &modified = 0
endfunction

function! iris#email#ui#reply_all()
  let index = iris#cache#read("email:index", 0)
  let email = iris#cache#read("emails", [])[index]
  let message = map(getline(1, "$"), "'>' . v:val")

  if empty(email["reply-to"])
    let reply_to = email["from"]
  else
    let reply_to = email["reply-to"]
  endif

  silent! bdelete "Iris reply all"
  silent! edit Iris reply all

  call append(0, [
    \"In-Reply-To: " . email["message-id"],
    \"To: " . reply_to,
    \"Cc: " . (has_key(email, "cc") ? email.cc : ""),
    \"Bcc: " . (has_key(email, "bcc") ? email.bcc : ""),
    \"Subject: Re: " . email.subject,
    \"",
  \] + message)

  normal! dd6G

  setlocal filetype=iris-edit
  let &modified = 0
endfunction

function! iris#email#ui#forward()
  let index = iris#cache#read("email:index", 0)
  let email = iris#cache#read("emails", [])[index]
  let message = getline(1, "$")

  silent! bdelete "Iris forward"
  silent! edit Iris forward

  call append(0, [
    \"To: ",
    \"Cc: ",
    \"Bcc: ",
    \"Subject: Fwd: " . email.subject,
    \"",
    \"---------- Forwarded message ---------",
  \] + message)

  normal! ddgg$

  setlocal filetype=iris-edit
  let &modified = 0
endfunction

function! iris#email#ui#save()
  call iris#cache#write("draft", getline(1, "$"))
  call iris#utils#log("draft saved!")
  let &modified = 0
endfunction

function! iris#email#ui#send()
  redraw | echo
  let draft = iris#cache#read("draft", [])

  let separator_idx = index(draft, "")

  let headers = {}
  for header in draft[:separator_idx-1]
    let header_split = split(header, ":")
    let key = header_split[0]
    let val = iris#utils#trim(join(header_split[1:], ''))
    if !empty(val) | let headers[key] = val | endif
  endfor

  let message = join(draft[separator_idx+1:], "\r\n")

  silent! bdelete
  call iris#email#api#send({
    \"headers": headers,
    \"message": message,
    \"from": {
      \"name": g:iris_name,
      \"mail": g:iris_mail,
    \}
  \})
endfunction

function! s:render(type, lines)
  let s:max_widths = s:get_max_widths(a:lines, s:config[a:type].columns)
  let header = [s:render_line(s:config.labels, s:max_widths, a:type)]
  let line = map(copy(a:lines), "s:render_line(v:val, s:max_widths, a:type)")

  return header + line
endfunction

function! s:render_line(line, max_widths, type)
  return "|" . join(map(
    \copy(s:config[a:type].columns),
    \"s:render_cell(a:line[v:val], a:max_widths[v:key])",
  \), "")
endfunction

function! s:render_cell(cell, max_width)
  let cell_width = strdisplaywidth(a:cell[:a:max_width])
  return a:cell[:a:max_width] . repeat(" ", a:max_width - cell_width) . " |"
endfunction

function! s:get_max_widths(lines, columns)
  let max_widths = map(copy(a:columns), "strlen(s:config.labels[v:val])")

  for line in a:lines
    let widths = map(copy(a:columns), "strlen(line[v:val])")
    call map(max_widths, "max([widths[v:key], v:val])")
  endfor

  return max_widths
endfunction

function! s:get_focused_email()
  let emails = iris#cache#read("emails", [])
  let index = line(".") - 2
  if  index < 0 | throw "email not found" | endif
  
  return emails[index]
endfunction
