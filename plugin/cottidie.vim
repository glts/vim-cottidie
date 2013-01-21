" cottidie.vim - Your quotidian Vim tip in 78 characters
" Author: glts <676c7473@gmail.com>
" Date:   2013-01-21
" GetLatestVimScripts: 0 0 :AutoInstall: cottidie.vim

if exists('g:loaded_cottidie') || v:version < 702 || &cp
  finish
endif
let g:loaded_cottidie = 1

command! -nargs=0 -bang CottidieTip call cottidie#tips#CottidieTip(<bang>0)
