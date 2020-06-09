let s:config = {
  \"list.from": {
    \"columns": ["flags", "from", "subject", "date"],
  \},
  \"list.to": {
    \"columns": ["flags", "to", "subject", "date"],
  \},
  \"labels": {
    \"from": "FROM",
    \"to": "TO",
    \"subject": "SUBJECT",
    \"date": "DATE",
    \"flags": "FLAGS",
  \},
\}

function! iris#ui#prompt_passwd(filepath, show_cmd, prompt)
  if empty(a:filepath)
    if empty(a:show_cmd)
      redraw | echo
      let prompt = "Iris: " . a:prompt . ":\n> "
      return iris#utils#pipe("inputsecret", "iris#utils#trim")(prompt)
    else
      return systemlist(a:show_cmd)[0]
    endif
  else
    return systemlist(printf(g:iris_passwd_show_cmd, a:filepath))[0]
  endif
endfunction

function! iris#ui#select_folder()
  let folder  = iris#cache#read("folder", "INBOX")
  let folders = iris#cache#read("folders", [])

  if &rtp =~ "fzf.vim"
    call fzf#run({
      \"source":  folders,
      \"sink": function("iris#api#select_folder"),
      \"down": "25%",
    \})
  else
    echo join(map(copy(folders), "printf('%s (%d)', v:val, v:key)"), ", ") . ": "
    let choice = nr2char(getchar())
    call iris#api#select_folder(folders[choice])
  endif
endfunction

function! iris#ui#list_email()
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

function! iris#ui#preview_email(email, format)
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

function! iris#ui#new_email()
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

function! iris#ui#reply_email()
  let index = iris#cache#read("email:index", 0)
  let email = iris#cache#read("emails", [])[index]
  let message = map(getline(1, "$"), "'>' . v:val")

  if empty(email["reply-to"])
    let reply_to = email["from"]
  else
    let reply_to = email["reply-to"]
  endif

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

function! iris#ui#reply_all_email()
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

function! iris#ui#forward_email()
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

function! iris#ui#save_email()
  call iris#cache#write("draft", getline(1, "$"))
  call iris#utils#log("draft saved!")
  let &modified = 0
endfunction

function! iris#ui#send_email()
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
  call iris#api#send_email({
    \"headers": headers,
    \"message": message,
    \"from": {
      \"name": g:iris_name,
      \"email": g:iris_mail,
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
  let cell_width = strdisplaywidth(a:cell[:a:max_width-1])
  return a:cell[:a:max_width-1] . repeat(" ", a:max_width - cell_width) . " |"
endfunction

function! s:get_max_widths(lines, columns)
  let max_widths = map(copy(a:columns), "strlen(s:config.labels[v:val])")

  for line in a:lines
    let widths = map(copy(a:columns), "strlen(line[v:val])")
    call map(max_widths, "max([widths[v:key], v:val])")
  endfor

  let tbl_width = iris#utils#sum(max_widths) + len(max_widths) * 2 + 1
  let win_width = winwidth(0)
  let num_width = (&number || &relativenumber) ? &numberwidth : 0
  let diff_width = tbl_width - win_width + num_width - 1

  if diff_width > 0
    let to_column_idx = index(s:config["list.to"]["columns"], "to")
    let to_column_diff = diff_width / 3
    let max_widths[to_column_idx] -= to_column_diff
    let subject_column_idx = index(s:config["list.to"]["columns"], "subject")
    let subject_column_diff = diff_width - to_column_diff + 1
    let max_widths[subject_column_idx] -= subject_column_diff
  endif

  return max_widths
endfunction

function! s:get_focused_email()
  let emails = iris#cache#read("emails", [])
  let index = line(".") - 2
  if  index < 0 | throw "email not found" | endif
  
  return emails[index]
endfunction
