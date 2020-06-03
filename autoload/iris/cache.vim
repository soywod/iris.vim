let s:cache = {}

function! iris#cache#read(key, default_val)
  return copy(has_key(s:cache, a:key) ? s:cache[a:key] : a:default_val)
endfunction

function! iris#cache#write(key, val)
  let s:cache[a:key] = copy(a:val)
endfunction
