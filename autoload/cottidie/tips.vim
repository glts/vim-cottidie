" cottidie.vim - Your quotidian Vim tip in 78 characters
" Author: glts <676c7473@gmail.com>
" Date: 2013-10-06

if !exists('g:cottidie_no_default_tips')
  let g:cottidie_no_default_tips = 0
endif

if !exists('g:cottidie_tips_files')
  let g:cottidie_tips_files = []
endif

let s:tips_files = g:cottidie_no_default_tips ? [] : [expand('<sfile>:p:h').'/tips']
call extend(s:tips_files, g:cottidie_tips_files)

function! s:OpenCottidieBuffer()
  let cbufnr = bufnr('^__Cottidie__$')
  if cbufnr == -1
    silent keepalt botright new __Cottidie__
    return s:InitCottidieBuffer()
  else
    if bufwinnr(cbufnr) != -1
      execute bufwinnr(cbufnr) . 'wincmd w'
    else
      execute 'silent keepalt botright split +buffer' . cbufnr
    endif
    return 1
  endif
endfunction

function! s:InitCottidieBuffer()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal nobuflisted
  setlocal noswapfile

  let urlre = '^\%(http\|ftp\|sftp\|rcp\|scp\|dav\|rsync\|fetch\)://'
  for f in map(s:tips_files, 'v:val =~# urlre ? v:val : fnamemodify(v:val, ":p")')
    let wipeout = !bufexists(f)
    if f =~# urlre || filereadable(f)
      execute 'silent 0read ' . fnameescape(f)
      if wipeout
        execute 'silent bwipeout ^' . fnameescape(f) . '$'
      endif
    endif
  endfor

  " Make sure we are still in the Cottidie buffer, netrw may have messed it up
  execute bufwinnr(bufnr('^__Cottidie__$')) . 'wincmd w'

  " Force loading help syntax items, store 'cole' setting, and fix up tips
  setlocal filetype=help
  let s:help_conceallevel = has('conceal') ? &conceallevel : 0
  silent g/^\%(#\|\s*$\)/d _
  silent v/^[^\t]\+\t[^\t]\+/d _
  call histdel('search', -1)
  let @/ = histget('search', -1)

  if empty(getline('.'))
    silent bwipeout ^__Cottidie__$
    redraw
    echohl ErrorMsg
    echomsg 'Cottidie: No valid tips found anywhere'
    echohl None
    return 0
  endif
  return 1
endfunction

function! s:GetRandomTip()
  let last = line('$')
  let lnum = 0
  if has('python') || has('python3')
    try
      execute has('python') ? 'python << EOF' : 'python3 << EOF'
import random
import vim
vim.command('let lnum = ' + str(random.randint(1, int(vim.eval('last')))))
EOF
    catch
    endtry
  endif
  if lnum == 0
    let lnum = (str2nr(matchstr(reltimestr(reltime()), '\.\@<=\d\+')[1:]) % last) + 1
  endif
  let line = getline(lnum)
  let idx = stridx(line, "\t")
  return idx < 0 ? ['', ''] : [strpart(line, 0, idx), strpart(line, idx+strlen("\t"))]
endfunction

function! s:DisplayTip(topic, text, echomsg)
  if a:topic.a:text == ''
    return
  endif

  if a:echomsg
    redraw
    echohl helpHeader
    echomsg a:topic
    echohl None
    echomsg a:text
  else
    let tagre     = '\\\@<!|[#-)!+-~]\+|'
    let specialre = '\%(<[-a-zA-Z0-9_]\+>\)\|\%(CTRL-\%([a-zA-Z]\+\|.\)\)\|\[range]\|\[count]\|{cmd}\|{string}\|{file}\|{motion}'
    let optionre  = '''[a-z]\{2,\}'''
    let allre = '\%(' . join([tagre, specialre, optionre], '\|') . '\)'
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
  if s:OpenCottidieBuffer()
    let [topic, text] = s:GetRandomTip()
    close
    call s:DisplayTip(topic, text, a:echomsg)
  endif
endfunction
