let g:iris_email = get(g:, 'iris_email', 'iris@localhost')

let g:iris_imap_host  = get(g:, 'iris_imap_host', 'localhost')
let g:iris_imap_port  = get(g:, 'iris_imap_port', 993)
let g:iris_imap_login = get(g:, 'iris_imap_login', 'user')

let g:iris_smtp_host  = get(g:, 'iris_imap_host', g:iris_imap_host)
let g:iris_smtp_port  = get(g:, 'iris_smtp_port', 465)
let g:iris_smtp_login = get(g:, 'iris_imap_login', 'user')

command! Iris call iris#email#ui#list()
