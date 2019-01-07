if exists('b:current_syntax') | finish | endif

syntax match iris_info_thread   /^>.*$/
syntax match iris_info_email    /[a-zA-Z\.\_]\+@[a-zA-Z\.\_]\+/
syntax match iris_info_to       /^To:/
syntax match iris_info_cc       /^CC:/
syntax match iris_info_bcc      /^BCC:/
syntax match iris_info_subject  /^Subject:/
syntax match iris_info_separtor /^---.*/

highlight default link iris_info_thread   Comment
highlight default link iris_info_separtor Comment
highlight default link iris_info_email    Tag
highlight default link iris_info_to       Structure
highlight default link iris_info_cc       Structure
highlight default link iris_info_bcc      Structure
highlight default link iris_info_subject  Structure

let b:current_syntax = 'iris-edit'
