let g:iris_host  = get(g:, 'iris_host', 'localhost')
let g:iris_email = get(g:, 'iris_email', 'iris')

command! Iris call iris#email#ui#list()
