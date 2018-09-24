if exists('b:current_syntax')
  finish
endif

function! s:SetSyntax()
  let columns = ['from', 'subject', 'date', 'flags']
  let widths  = {
    \'from': 21,
    \'subject': 37,
    \'date': 16,
    \'flags': 6,
  \}

  let end   = 0
  let start = 1

  for column in columns
    let end    = start + widths[column] - 1
    let region = 'region Iris' . toupper(column[0]) . column[1:]

    execute 'syntax '.region.' start=/\%'.start.'c/ end=/\%'.end.'c/'
    let start = end + 1
  endfor

  syntax match IrisSeparator /|/
  syntax match IrisHead      /.*\%1l/ contains=IrisSeparator
endfunction

call s:SetSyntax()

highlight default link IrisId         Identifier
highlight default link IrisFrom       Special
highlight default link IrisSubject    String
highlight default link IrisDate       Structure
highlight default link IrisFlags      Comment
highlight default link IrisSeparator  VertSplit

highlight IrisHead term=bold,underline cterm=bold,underline gui=bold,underline

let b:current_syntax = 'iris'
