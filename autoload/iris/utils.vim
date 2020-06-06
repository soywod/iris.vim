function! iris#utils#pipe(...)
  let funcs = map(copy(a:000), "function(v:val)")
  return function("s:pipe", [funcs])
endfunction

function! s:pipe(funcs, arg)
  let data = a:arg

  for Fn in a:funcs
    let data = Fn(data)
  endfor

  return data
endfunction

function! iris#utils#trim(str)
  return iris#utils#pipe("s:trim_left", "s:trim_right")(a:str)
endfunction

function! s:trim_left(str)
  return substitute(a:str, '^\s*', "", "g")
endfunction

function! s:trim_right(str)
  return substitute(a:str, '\s*$', "", "g")
endfunction

function! iris#utils#assign(...)
  let overrides = copy(a:000)
  let base = remove(overrides, 0)

  for override in overrides
    for [key, val] in items(override)
      let base[key] = val
      unlet key val
    endfor
  endfor

  return base
endfunction

function! iris#utils#sum(array)
  let total = 0

  for item in a:array
    let total += item
  endfor

  return total
endfunction

function! iris#utils#log(msg)
  let msg = printf("Iris: %s", a:msg)
  redraw | echom msg
endfunction

function! iris#utils#elog(msg)
  let msg = printf("Iris: %s", a:msg)
  redraw | echohl ErrorMsg | echom msg | echohl None
endfunction

function! iris#utils#define_maps(maps)
  for [mode, key, plug] in a:maps
    let plug = printf("<plug>(iris-%s)", plug)

    if !hasmapto(plug, mode)
      execute printf("%smap <nowait> <buffer> %s %s", mode, key, plug)
    endif
  endfor
endfunction
