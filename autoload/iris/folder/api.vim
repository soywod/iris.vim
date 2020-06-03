function! iris#folder#api#select(folder)
  call iris#utils#log("selecting folder...")
  call iris#api#send({
    \"type": "select-folder",
    \"folder": a:folder,
  \})
endfunction
