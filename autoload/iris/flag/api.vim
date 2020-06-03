function! iris#flag#api#add(data)
  call iris#api#send(iris#utils#assign(a:data, {
    \"type": "add-flag",
  \}))
endfunction
