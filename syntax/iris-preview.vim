if exists("b:current_syntax") | finish | endif

syntax match iris_info_thread   /^>.*$/

highlight default link iris_info_thread   Comment

let b:current_syntax = "iris-preview"
