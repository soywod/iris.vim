let s:is_started = 0

function! iris#start()
  if s:is_started == 0
    let imap_password = iris#ui#prompt_passwd(
      \g:iris_imap_passwd_filepath,
      \g:iris_imap_passwd_show_cmd,
      \"IMAP password"
    \)

    let smtp_password = iris#ui#prompt_passwd(
      \g:iris_smtp_passwd_filepath,
      \g:iris_smtp_passwd_show_cmd,
      \"SMTP password (empty=same as IMAP)"
    \)

    call iris#api#start()
    call iris#api#login(imap_password, smtp_password)
    call iris#api#select_folder("INBOX")

    if g:iris_idle_enabled
      call iris#idle#start()
      call iris#idle#login(imap_password)
    endif

    let s:is_started = 1
  else
    call iris#api#fetch_all_emails()
  endif
endfunction
