if exists('b:current_syntax')
  finish
endif

syntax match iris_separator     /|/
syntax match iris_table_from    /^|.\{-}|/                    contains=iris_separator
syntax match iris_table_subject /^|.\{-}|.\{-}|/              contains=iris_table_from,iris_separator
syntax match iris_table_date    /^|.\{-}|.\{-}|.\{-}|/        contains=iris_table_from,iris_table_subject,iris_separator
syntax match iris_table_flag    /^|.\{-}|.\{-}|.\{-}|.\{-}|$/ contains=iris_table_from,iris_table_subject,iris_table_date,iris_separator
syntax match iris_table_head    /.*\%1l/                      contains=iris_separator

highlight default link iris_separator       VertSplit
highlight default link iris_table_from      Special
highlight default link iris_table_subject   String
highlight default link iris_table_date      Structure
highlight default link iris_table_flag      Comment

highlight iris_table_head term=bold,underline cterm=bold,underline gui=bold,underline

let b:current_syntax = 'iris-list'
