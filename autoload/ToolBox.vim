" ToolBox - scripting tools for vim
"
" Copyright (C) 2015 Benjamin Schnitzler
"
" This program is free software; you can redistribute it and/or modify it under
" the terms of the GNU General Public License as published by the Free Software
" Foundation; either version 3 of the License, or (at your option) any later
" version.
"
" This program is distributed in the hope that it will be useful, but WITHOUT
" ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
" FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License along with
" this program; if not, see <http://www.gnu.org/licenses/>.
"
" Description:  various function for scripting vim
" Last Change:	2015-05-31
" Maintainer:	  Benjamin Schnitzler <benjaminschnitzler@googlemail.com>
" License:	    This file is placed in the public domain.
" Comments:     
" · The code in this file shall be at most 80 characters in width

if exists("g:loaded_ToolBox")
  finish
endif
let g:loaded_ToolBox = 1


"H Implementation

" will remember the combination of last tab and window visited and the
" identifying mark, if existing
"
" Comments:
" sets s:last_tabwin_visited on window change
func! ToolBox#InitRememberLastTabAndWindow()
  let s:last_tabwin_visited = []
  augroup LastTabWindowVisit
    autocmd!
    autocmd WinLeave * let s:last_tabwin_visited = ToolBox#GetActTabAndWin()
  augroup END
endfunc

" returns [tabnr, winnr, winident] of the current tab and window
"
" Comment:
" winident will be "" if not existing
func! ToolBox#GetActTabAndWin()
  return [tabpagenr(), winnr(), ToolBox#WindowMarkers#GetWindowMark()]
endfunc

" move to a window by tab number and window number
"
" Arguments:
" winnr - the window number of the destination window
" tabnr - the destination tab, if 0, the current tab (optional, defaults to 0)
func! ToolBox#GoToTabAndWin( winnr, ... )
  if a:0 > 0 && a:1 > 0
    exe "tabnext ".a:1
  endif
  exe a:winnr . "wincmd w"
endfunc

" returns [tabnr, winnr, winident] of the last tab and window visited
"
" Comment:
" winident will be "" if not existing
"
" Return Value:
" As stated in the description and [] if the window didn't change after starting
" vim or ToolBox#InitRememberLastTabAndWindow() wasn't yet called
func! ToolBox#GetLastTabAndWin()
  if ! exists('s:last_tabwin_visited')
    return []
  else
    return s:last_tabwin_visited
  endif
endfunc

" substitute without using magic
"
" Arguments:
" string      - string which contains substrings to replace
" match       - string which shall be replaced
" replacement - replacements for the strings to replace
" flags       - (optional) will be provided to substitute()
func! ToolBox#SubstituteNoMagic( string, match, replacement, ... )
  return substitute(
        \a:string,
        \'\V'.escape(a:match,'\'),
        \escape(a:replacement, '\'),
        \a:0 > 0 ? a:1 : ''
  \)
endfunc

" substitute the keys from the dict. occeuring in string with the coresp. values
"
" Arguments:
" string - string which contains substrings to replace
" Dict   - provides the replacements
"
" Comment:
" invoke ToolBox#SubstituteNoMagic on string for every key in Dict,
" using the keys as match Argument and the values as replacement argument.
" the replacement is always performed global and the order is undetermined.
func! ToolBox#SubstituteFromDictionary( string, Dict )
  let l:string = a:string
  for l:it in items(a:Dict)
    let l:string = ToolBox#SubstituteNoMagic( l:string, l:it[0], l:it[1], 'g' )
  endfor
  return l:string
endfunc

" find a line containing pattern backwards (towards the beginning of the file)
"
" Arguments:
" pattern - the pattern to search for (see match())
" linenr  - the line to start at (optional, defaults to line('.'))
"
" Return Value:
" 0, if no line matching the pattern was found, the line number of the line
" containing the pattern otherwise
"
" Comments:
" · operates on the current buffer
" · doesn't wrap at the end/beginning of the file
func! ToolBox#FindLineBackwards( pattern, ... )
  let l:linenr = a:0 > 0 ? a:1 : line('.')
  while l:linenr > 0 && match(getline(l:linenr), a:pattern) == -1
    let l:linenr -= 1
  endwhile
  return l:linenr
endfunc

" determine if a path is absolute or relative
func! ToolBox#IsAbsPath(path)
  return a:path =~# '^/'
endfunc

" create an absolute path from relpath using absdir
"
" Arguments:
" absdir  - an absolute path to a directory under which <relpath> is located
" relpath - a relative path
"
" Comment:
" if relpath is an absolute path, it will be returned unmodified
func! ToolBox#GetAbsPath(absdir, relpath)
  if ToolBox#IsAbsPath(a:relpath)
    return a:relpath
  else
    return a:absdir . '/' . a:relpath
  endif
endfunc

" get the filetype (detected by vim) of a file
"
" Arguments:
" filepath - the path to the file whose filetype shall be detected
func! ToolBox#DetectFiletype( filepath )
  " store bufhidden setting
  let l:bh = &bh

  " store the current buffers number to be able to switch back
  let l:bufnr = bufnr('.')

  " set bufhidden to hide, to make it possible to hide current buffer
  set bh=hide

  let l:dstbuf = bufnr(a:filepath)
  if l:dstbuf != -1
    " buffer already open, just change to it
    exe l:dstbuf . "bnext"

    " get the filetype
    let l:filetype = &ft
  else
    " open the file in a new buffer
    exe "silent view ".a:filepath

    " get the filetype
    let l:filetype = &ft

    " close the recently opened buffer
    bdelete
  endif

  " get back to the previously opened buffer
  exe l:bufnr . "bnext"

  " restore bufhidden setting
  let &bh = l:bh

  return l:filetype
endfunc

"H vim: set tw=80 colorcolumn=+1 :
