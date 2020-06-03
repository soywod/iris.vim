" ------------------------------------------------------------------- # Select #

function! iris#folder#ui#select()
  let folder  = iris#cache#read('folder', 'INBOX')
  let folders = iris#cache#read('folders', [])

  echo join(map(copy(folders), "printf('%s (%d)', v:val, v:key)"), ', ') . ': '
  let choice = nr2char(getchar())

  call iris#folder#api#select(folders[choice])
endfunction
