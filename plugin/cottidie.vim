" cottidie.vim - Your quotidian Vim tip in 78 characters
" Author: glts <676c7473@gmail.com>
" Date: 2013-07-06
" GetLatestVimScripts: 0 0 :AutoInstall: cottidie.vim

if exists('g:loaded_cottidie') || v:version < 703 || &cp
  finish
endif

command! -nargs=0 -bang -bar CottidieTip call cottidie#tips#CottidieTip(<bang>0)

let g:loaded_cottidie = 1
