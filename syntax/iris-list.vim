if exists("b:current_syntax")
  finish
endif

syntax match iris_mail          /[a-zA-Z\.\_]\+@[a-zA-Z\.\_]\+/
syntax match iris_separator     /|/
syntax match iris_table_flag    /^|.\{-}|/                    contains=iris_table_flag,iris_separator
syntax match iris_table_mail    /^|.\{-}|.\{-}|/              contains=iris_table_flag,iris_table_mail,iris_separator
syntax match iris_table_subject /^|.\{-}|.\{-}|.\{-}|/        contains=iris_table_flag,iris_table_mail,iris_table_subject,iris_separator
syntax match iris_table_date    /^|.\{-}|.\{-}|.\{-}|.\{-}|$/ contains=iris_table_flag,iris_table_mail,iris_table_subject,iris_table_date,iris_separator
syntax match iris_table_head    /.*\%1l/                      contains=iris_separator
syntax match iris_new_mail      /^|N.*|$/                     contains=iris_table_flag,iris_separator

highlight default link iris_mail            Tag
highlight default link iris_separator       VertSplit
highlight default link iris_table_flag      Comment
highlight default link iris_table_subject   String
highlight default link iris_table_date      Structure

highlight iris_table_head term=bold,underline cterm=bold,underline gui=bold,underline
highlight iris_new_mail   term=bold           cterm=bold           gui=bold

let b:current_syntax = "iris-list"
