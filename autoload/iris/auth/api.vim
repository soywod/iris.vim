function! iris#auth#api#login()
  if empty(g:iris_imap_passwd_filepath)
    if empty(g:iris_imap_passwd_show_cmd)
      redraw | echo
      let prompt = "Iris: IMAP password:" . "\n> "
      let imap_password = iris#utils#pipe("inputsecret", "iris#utils#trim")(prompt)
    else
      let imap_password = systemlist(g:iris_imap_passwd_show_cmd)[0]
    endif
  else
    let imap_password = systemlist(printf(g:iris_passwd_show_cmd, g:iris_imap_passwd_filepath))[0]
  endif

  if empty(g:iris_smtp_passwd_filepath)
    if empty(g:iris_smtp_passwd_show_cmd)
      redraw | echo
      let prompt = "Iris: SMTP password (empty=same as IMAP):" . "\n> "
      let smtp_password = iris#utils#pipe("inputsecret", "iris#utils#trim")(prompt)
    else
      let smtp_password = systemlist(g:iris_smtp_passwd_show_cmd)[0]
    endif
  else
    let smtp_password = systemlist(printf(g:iris_passwd_show_cmd, g:iris_smtp_passwd_filepath))[0]
  endif

  call iris#utils#log("logging in...")
  call iris#api#send({
    \"type": "login",
    \"imap-host": g:iris_imap_host,
    \"imap-port": g:iris_imap_port,
    \"imap-login": g:iris_imap_login,
    \"imap-password": imap_password,
    \"smtp-host": g:iris_smtp_host,
    \"smtp-port": g:iris_smtp_port,
    \"smtp-login": g:iris_smtp_login,
    \"smtp-password": smtp_password,
  \})
endfunction
