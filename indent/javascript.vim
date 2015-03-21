" Vim indent file
" Language: Javascript
" Acknowledgement: Based off of vim-ruby maintained by Nikolai Weibull http://vim-ruby.rubyforge.org

" 0. Initialization {{{1
" =================

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal nosmartindent

" Now, set up our indentation expression and keys that trigger it.
setlocal indentexpr=GetJavascriptIndent()
setlocal formatexpr=Fixedgq(v:lnum,v:count)
setlocal indentkeys=0{,0},0),0],0\,,!^F,o,O,e

let s:cpo_save = &cpo
set cpo&vim

" 1. Variables {{{1
" ============

let s:js_keywords = '^\s*\(break\|case\|catch\|continue\|debugger\|default\|delete\|do\|else\|finally\|for\|function\|if\|in\|instanceof\|new\|return\|switch\|this\|throw\|try\|typeof\|var\|void\|while\|with\)'

" Regex of syntax group names that are or delimit string or are comments.
let s:syng_strcom = 'string\\|regex\\|comment\\c'

" Regex of syntax group names that are strings.
let s:syng_string = 'regex\\c'

" Regex of syntax group names that are strings or documentation.
let s:syng_multiline = 'blockcomment\c'

" Regex of syntax group names that are line comment.
let s:syng_linecom = 'linecomment\\c'

" Expression used to check whether we should skip a match with searchpair().
let s:skip_expr = "synIDattr(synID(line('.'),col('.'),1),'name') =~ 'regex\\|string\\|comment\\c'"

let s:line_term = '\s*\%(\%(\/\/\).*\)\=$'

" Regex that defines continuation lines, not including (, {, or [.
let s:continuation_regex = '\%([\\*+/.:]\|\%(<%\)\@<![=-]\|\W[|&?]\|||\|&&\)' . s:line_term

" Regex that defines continuation lines.
" TODO: this needs to deal with if ...: and so on
let s:msl_regex = s:continuation_regex

let s:one_line_scope_regex = '\<\%(if\|else\|for\|while\)\>[^{;]*' . s:line_term

" Regex that defines blocks.
let s:block_regex = '\%([{[]\)\s*\%(|\%([*@]\=\h\w*,\=\s*\)\%(,\s*[*@]\=\h\w*\)*|\)\=' . s:line_term

let s:var_stmt = '^\s*var'

let s:comma_first = '^\s*,'
let s:comma_last = ',\s*$'

let s:ternary = '^\s\+[?|:]'
let s:ternary_q = '^\s\+?'

let s:chain_expr = '^\s*[.,]'

" 2. Auxiliary Functions {{{1
" ======================

" Check if the character at lnum:col is inside a multi-line comment.
function! s:IsInMultilineComment(lnum, col)
  return synIDattr(synID(a:lnum, a:col, 1), 'name') =~ s:syng_multiline
endfunction

" Check if the character at lnum:col is a line comment.
function! s:IsLineComment(lnum, col)
  return synIDattr(synID(a:lnum, a:col, 1), 'name') =~ s:syng_linecom
endfunction

function! s:IndentBlock(start, end, ind, buf)
  let init_line = line('.')
  let init_pos = col('.')
  let ind = a:ind

  let line = getline(v:lnum)

  " go to openning bracket
  while searchpair(a:start, '', a:end, 'bW', s:skip_expr) > 0
    let temp_line = line('.')
    let temp_pos = col('.')

    " open bracket line starts with chain character
    if getline('.') =~ s:chain_expr
      let chained = 1
    endif

    if getline('.') =~ '^\s*switch[ (]'
        let inside_switch = 1
    endif

    " go to closing bracket
    if searchpair(a:start, '', a:end, 'W', s:skip_expr) <= 0
      break
    endif

    " check that this line does not close already indented block, and closing
    " bracket is not the first char
    if !a:buf[temp_line]

      if !(line('.') == v:lnum && line =~ '^\s*' . a:end)
        " indent by one
        let ind = ind + &sw

        " add another indent in switch blocks (
        if inside_switch
          let ind = ind + &sw
        endif
      endif

      " add another one for chained calls
      if chained
        let ind = ind + &sw
      endif

      " remember this line
      let a:buf[temp_line] += 1

    endif
    call cursor(temp_line, temp_pos)
  endw
  call cursor(init_line, init_pos)

  return ind
endf

function! s:IndentBlockByStartPos(start, end, ind, buf)
  let init_line = line('.')
  let init_pos = col('.')
  let ind = a:ind
  while searchpair(a:start, '', a:end, 'bW', s:skip_expr) > 0
    let temp_line = line('.')
    let temp_pos = col('.')
    if searchpair(a:start, '', a:end, 'W', s:skip_expr) <= 0
      break
    endif
    if !a:buf[temp_line] " if this block was not indented yet
      let ind = ind + &sw
      let a:buf[temp_line] += 1
    endif
    call cursor(temp_line, temp_pos)
  endw
  call cursor(init_line, init_pos)
  return ind
endf

" 3. GetJavascriptIndent Function {{{1
" =========================

function! GetJavascriptIndent()

  let ind = 0
  let buf = []

  let lines = line('w$')
  let i = 0
  while i < lines
    let i += 1
    call add(buf, 0)
  endw

  " Add one indent for every nested block
  let ind = s:IndentBlock('{', '}', ind, buf)       " function body
  let ind = s:IndentBlock('\[', '\]', ind, buf)     " array elements
  let ind = s:IndentBlock('(', ')', ind, buf)     " function arguments
  " let ind = s:IndentBlockWithClosing('var ', ';', ind, buf)

  " Add 1 for multiline comments
  if s:IsInMultilineComment(v:lnum, 1)
    let ind = ind + 1
  endif

  " Add one tab for chained calls
  let line = getline(v:lnum)
  if line =~ s:chain_expr
    let ind = ind + &sw
  endif

  " pull left 'case' and 'default'
  if line =~ '^\s*\(default\|case\).*:'
    let ind = ind - &sw
  endif

  return ind
endfunction

" }}}1

let &cpo = s:cpo_save
unlet s:cpo_save

function! Fixedgq(lnum, count)
    let l:tw = &tw ? &tw : 80;

    let l:count = a:count
    let l:first_char = indent(a:lnum) + 1

    if mode() == 'i' " gq was not pressed, but tw was set
        return 1
    endif

    " This gq is only meant to do code with strings, not comments
    if s:IsLineComment(a:lnum, l:first_char) || s:IsInMultilineComment(a:lnum, l:first_char)
        return 1
    endif

    if len(getline(a:lnum)) < l:tw && l:count == 1 " No need for gq
        return 1
    endif

    " Put all the lines on one line and do normal spliting after that
    if l:count > 1
        while l:count > 1
            let l:count -= 1
            normal J
        endwhile
    endif

    let l:winview = winsaveview()

    call cursor(a:lnum, l:tw + 1)
    let orig_breakpoint = searchpairpos(' ', '', '\.', 'bcW', '', a:lnum)
    call cursor(a:lnum, l:tw + 1)
    let breakpoint = searchpairpos(' ', '', '\.', 'bcW', s:skip_expr, a:lnum)

    " No need for special treatment, normal gq handles edgecases better
    if breakpoint[1] == orig_breakpoint[1]
        call winrestview(l:winview)
        return 1
    endif

    " Try breaking after string
    if breakpoint[1] <= indent(a:lnum)
        call cursor(a:lnum, l:tw + 1)
        let breakpoint = searchpairpos('\.', '', ' ', 'cW', s:skip_expr, a:lnum)
    endif


    if breakpoint[1] != 0
        call feedkeys("r\<CR>")
    else
        let l:count = l:count - 1
    endif

    " run gq on new lines
    if l:count == 1
        call feedkeys("gqq")
    endif

    return 0
endfunction
