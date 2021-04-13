if exists('g:loaded_feline') | finish | endif

if !has('nvim-0.5')
    echohl Error
    echomsg "Feline is only available for Neovim versions 0.5 and above"
    echohl clear
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

let g:loaded_feline = 1

let &cpo = s:save_cpo
unlet s:save_cpo

