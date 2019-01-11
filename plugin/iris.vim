let g:iris_email = get(g:, 'iris_email', 'iris@localhost')

let g:iris_imap_host  = get(g:, 'iris_imap_host', 'localhost')
let g:iris_imap_port  = get(g:, 'iris_imap_port', 993)
let g:iris_imap_login = get(g:, 'iris_imap_login', 'user')

let g:iris_smtp_host  = get(g:, 'iris_imap_host', g:iris_imap_host)
let g:iris_smtp_port  = get(g:, 'iris_smtp_port', 587)
let g:iris_smtp_login = get(g:, 'iris_imap_login', 'user')

command! Iris call iris#start()
command! IrisFolder call iris#folder#ui#select()
