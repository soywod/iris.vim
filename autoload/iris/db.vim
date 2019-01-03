let s:db = {}

" --------------------------------------------------------------------- # Read #

function! iris#db#read(key, default_val)
  return has_key(s:db, a:key) ? copy(s:db[a:key]) : copy(a:default_val)
endfunction

" -------------------------------------------------------------------- # Write #

function! iris#db#write(key, val)
  let s:db[a:key] = copy(a:val)
endfunction
