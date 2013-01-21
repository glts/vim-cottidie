" cottidie.vim - Your quotidian Vim tip in 78 characters
" Author: glts <676c7473@gmail.com>
" Date:   2013-01-21

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:cottidie_default_tips')
  let g:cottidie_default_tips = expand('<sfile>:p:h').'/tips'
endif

if !exists('g:cottidie_extra_tips')
  let g:cottidie_extra_tips = []
endif

function! s:warn(msg)
  redraw
  echohl WarningMsg
  echomsg 'Cottidie: ' . a:msg
  echohl None
endfunction

function! s:error(msg)
  redraw
  echohl ErrorMsg
  echomsg 'Cottidie: ' . a:msg
  echohl None
endfunction

function! s:GoToCottidieBuffer()
  let cbufnr = bufnr('^__Cottidie__$')
  if cbufnr == -1
    silent keepalt botright vnew __Cottidie__
    return s:InitCottidieBuffer()
  else
    if bufwinnr(cbufnr) != -1
      exe bufwinnr(cbufnr).'wincmd w'
    else
      exe 'silent keepalt botright vsplit +buffer'.cbufnr
    endif
    return 1
  endif
endfunction

function! s:path(str)
  if a:str =~# '^\%(http\|s\=ftp\|rcp\|scp\|dav\|rsync\|fetch\)://'
    let path = a:str
  else
    let path = fnamemodify(resolve(a:str), ':p')
  endif
  return path
endfunction

" Initializes the hidden __Cottidie__ buffer by reading the default and extra
" tips files and doing simple validity checks.
function! s:InitCottidieBuffer()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal nobuflisted
  setlocal noswapfile

  " Special processing only for the default tips file
  if g:cottidie_default_tips !=# ''
    let path = s:path(g:cottidie_default_tips)
    let wipeout = !bufexists(path)
    exe 'silent 0read '.fnameescape(path)
    if wipeout
      exe 'silent bwipeout ^'.fnameescape(path).'$'
    endif

    let ln = nextnonblank(0)
    let validtips = 0
    for i in range(ln, ln+2)
      if getline(i) =~? '^#.*\%(cottidie\|tips\)'
        let validtips = 1
      endif
    endfor
    if !validtips
      %delete _
      call s:warn("No default tips found")
    endif
  endif

  for f in map(g:cottidie_extra_tips, 's:path(v:val)')
    let wipeout = !bufexists(f)
    exe 'silent 0read '.fnameescape(f)
    if wipeout
      exe 'silent bwipeout ^'.fnameescape(f).'$'
    endif
  endfor

  " Force loading help syntax highlighting items and &cole setting
  setlocal filetype=help
  let s:help_conceallevel = has('conceal') ? &conceallevel : 0

  silent g/^\%(#\|\%(\s*$\)\)/delete _
  call histdel('search', -1)
  let @/ = histget('search', -1)

  if search('^[^\t]\+\t[^\t]\+$', 'cw') == 0
    silent bwipeout ^__Cottidie__$
    call s:error("No tips found anywhere")
    return 0
  endif
  return 1
endfunction

function! s:CloseCottidieBuffer()
  let cbufwinnr = bufwinnr(bufnr('^__Cottidie__$'))
  if cbufwinnr != -1
    exe cbufwinnr.'wincmd w'
    close
  endif
endfunction

" Tries to obtain a random line number for the buffer, then gets the line and
" returns it as a tip in the form of a [topic, text] pair.
function! s:GetRandomTip()

  let last = line('$')
  let n = -1

  if has('python') || has('python3')
    try
      exe has('python') ? 'python << EOF' : 'python3 << EOF' |" python << EOF
import random, vim
vim.command('let n = ' + str( random.randint(1, int(vim.eval('last'))) ))
EOF
    catch
      call s:warn('Error generating random integer')
    endtry
  endif
  if !(0 < n && n <= last)
    let n = (str2nr(matchstr(reltimestr(reltime()), '\.\@<=\d\+')[1:]) % last) + 1
  endif

  let line = getline(n)
  if line !~# '^[^\t]\+\t[^\t]\+$'
    throw 'Invalid tip "'.line.'"'
  endif
  return split(getline(n), '\t')
endfunction

function! s:DisplayTip(topic, text, echomsg)
  if a:echomsg
    redraw
    echohl helpHeader
    echomsg a:topic
    echohl None
    echomsg a:text
  else
    let tagre     = '\\\@<!|[#-)!+-~]\+|'
    let specialre = '\%(<[-a-zA-Z0-9_]\+>\)\|\%(CTRL-\%([a-zA-Z]\+\|.\)\)\|\%(\[range]\)\|\%({cmd}\)'
    let optionre  = '''\%([a-z]\{2,\}\|\%(t_..\)\)'''
    let allre = '\%('.join([tagre, specialre, optionre], '\|').'\)'
    let parts = split(a:text, '\%('.allre.'\zs\)\|\%(.\{-1,}'.allre.'\@=\zs\)')

    redraw
    echohl helpHeader
    echo a:topic
    echohl None

    echo ''
    for p in parts
      if p =~# specialre
        echohl helpSpecial
        echon p
        echohl None
      elseif p =~# optionre
        echohl helpOption
        echon p
        echohl None
      elseif p =~# tagre
        if s:help_conceallevel < 2
          echohl helpBar
          echon '|'
        endif
        echohl helpHyperTextJump
        echon p[1:-2]
        if s:help_conceallevel < 2
          echohl helpBar
          echon '|'
        endif
        echohl None
      else
        echon p
      endif
    endfor
  endif
endfunction

function! cottidie#tips#CottidieTip(echomsg)
  if s:GoToCottidieBuffer()
    try
      let [topic, text] = s:GetRandomTip()
      call s:CloseCottidieBuffer()
      call s:DisplayTip(topic, text, a:echomsg)
    catch
      call s:CloseCottidieBuffer()
      call s:error(v:exception)
    endtry
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
