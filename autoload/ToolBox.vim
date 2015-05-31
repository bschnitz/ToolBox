" several function tools for scripting vim
"
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
func ToolBox#InitRememberLastTabAndWindow()
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
func ToolBox#GetActTabAndWin()
  return [tabpagenr(), winnr(), ToolBox#WindowMarkers#GetWindowMark()]
endfunc

" returns [tabnr, winnr, winident] of the last tab and window visited
"
" Comment:
" winident will be "" if not existing
"
" Return Value:
" As stated in the description and [] if the window didn't change after starting
" vim or ToolBox#InitRememberLastTabAndWindow() wasn't yet called
func ToolBox#GetLastTabAndWin()
  if ! exists('s:last_tabwin_visited')
    return []
  else
    return s:last_tabwin_visited
  endif
endfunc

"H vim: set tw=80 colorcolumn=+1 :
