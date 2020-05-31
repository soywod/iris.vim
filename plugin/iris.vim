let g:iris_passwd_show_cmd = "gpg --decrypt --batch --no-tty -q '%s'"

let g:iris_name   = get(g:, "iris_name", "Iris")
let g:iris_email  = get(g:, "iris_email", "iris@localhost")
let g:iris_mail   = get(g:, "iris_mail", g:iris_email)

let g:iris_imap_host            = get(g:, "iris_imap_host", "localhost")
let g:iris_imap_port            = get(g:, "iris_imap_port", 993)
let g:iris_imap_login           = get(g:, "iris_imap_login", g:iris_mail)
let g:iris_imap_passwd_filepath = get(g:, "iris_imap_passwd_filepath", "")
let g:iris_imap_passwd_show_cmd = get(g:, "iris_imap_passwd_show_cmd", "")

let g:iris_smtp_host            = get(g:, "iris_smtp_host", g:iris_imap_host)
let g:iris_smtp_port            = get(g:, "iris_smtp_port", 587)
let g:iris_smtp_login           = get(g:, "iris_smtp_login", g:iris_mail)
let g:iris_smtp_passwd_filepath = get(g:, "iris_smtp_passwd_filepath", g:iris_imap_passwd_filepath)
let g:iris_smtp_passwd_show_cmd = get(g:, "iris_smtp_passwd_show_cmd", g:iris_imap_passwd_show_cmd)

command! Iris call iris#start()
command! IrisFolder call iris#folder#ui#select()
