" ------------------------------------------------------------------ # Compose #

function! iris#utils#compose(...)
  let funcs = map(reverse(copy(a:000)), 'function(v:val)')
  return function('s:compose', [funcs])
endfunction

function! s:compose(funcs, arg)
  let data = a:arg

  for Func in a:funcs
    let data = Func(data)
  endfor

  return data
endfunction

" --------------------------------------------------------------------- # Trim #

function! iris#utils#trim(str)
  return iris#utils#compose('s:trim_left', 's:trim_right')(a:str)
endfunction

function! s:trim_left(str)
  return substitute(a:str, '^\s*', '', 'g')
endfunction

function! s:trim_right(str)
  return substitute(a:str, '\s*$', '', 'g')
endfunction

" ------------------------------------------------------------------- # Assign #

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

" ---------------------------------------------------------------------- # Sum #

function! iris#utils#sum(array)
  let total = 0

  for item in a:array
    let total += item
  endfor

  return total
endfunction

" ---------------------------------------------------------------- # Log utils #

function! iris#utils#log(msg)
  let msg = printf('Iris: %s', a:msg)
  redraw | echom msg
endfunction

function! iris#utils#elog(msg)
  let msg = printf('Iris: %s', a:msg)
  redraw | echohl ErrorMsg | echom msg | echohl None
endfunction

" ------------------------------------------------------------- # Notify utils #

function! iris#utils#notify(title, msg)
  let msg = shellescape(a:msg)

  if has('unix') 
    if has('mac')
      call system('terminal-notifier -title ' . a:title . ' -message ' . msg)
    else
      call system('notify-send ' . a:title . ' ' . msg)
    endif
  endif
endfunction
