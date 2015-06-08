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
" Description:
" marking windows to be able to identify them even after rearangements
" Last Change:	2015-05-30
" Maintainer:	  Benjamin Schnitzler <benjaminschnitzler@googlemail.com>
" License:	    This file is placed in the public domain.
" Comments:     
" · The code in this file shall be at most 80 characters in width

if exists("g:loaded_ToolBox_WindowMarkers")
  finish
endif
let g:loaded_ToolBox_WindowMarkers = 1


"H Implementation

" mark the current window with an identifier
"
" Comments:
" sets w:WindowMarkers_window_mark; the mark should never be empty ("")
"
" Arguments:
" mark - (optional) the identifier chosen for this window; if mark is not given,
"        this function function tests, if the window already has an identifier
"        and if not, it chooses one (one which is not already taken) and marks
"        the window with it
"
" Return Value:
" the chosen identifier
func ToolBox#WindowMarkers#MarkWindow(...)
  let w:WindowMarkers_window_mark = ""
  if a:0 > 0
    let w:WindowMarkers_window_mark = a:1
  else
    let w:WindowMarkers_window_mark = ToolBox#WindowMarkers#GetWindowMark()
    if w:WindowMarkers_window_mark ==# ""
      let l:Marks = ToolBox#WindowMarkers#GetWindowMarks()
      let w:WindowMarkers_window_mark = max(l:Marks) + 1
    endif
  endif
  return w:WindowMarkers_window_mark
endfunc

" get the mark for for the specified window
"
" Comments:
" uses w:WindowMarkers_window_mark
"
" Arguments:
" 1 winnr - (optional, defaults to 0)
"           either a windows's number or 0 for the current window
" 2 tabnr - (optional, defaults to 0)
"           either a tab's number or 0 for the current tab
" 3 defval - (optional, defaults to "")
"            a default value for the mark, in case it doesn't exist
"
" Warning:
" if winnr == 0 and tabnr != 0, the function is not determined to return
" anything useful.
"
" Return Value:
" the identifier (mark) for the specified window,
" or an empty string, if this identifier does not exist
func ToolBox#WindowMarkers#GetWindowMark( ... )
  let l:winnr = a:0 > 0 ? a:1 : 0
  let l:Tabnr = a:0 < 2 || a:2 == 0 ? tabpagenr() : a:2
  let l:defval = a:0 > 2 ? a:3 : ""
  let l:var = gettabwinvar( l:Tabnr, l:winnr, 'WindowMarkers_window_mark', l:defval )
  return l:var
endfunc

" get a list of all existing window marks
"
" Return Value:
" a list containing all marks of all windows
func ToolBox#WindowMarkers#GetWindowMarks()
  let l:Marks = []
  for l:Tabnr in range(1, tabpagenr('$'))
    for l:winnr in range(1, tabpagewinnr(l:Tabnr, '$'))
      let l:mark = ToolBox#WindowMarkers#GetWindowMark( l:winnr, l:Tabnr )
      if l:mark != ""
        call add( l:Marks, l:mark )
      endif
    endfor
  endfor
  return l:Marks
endfunc

" search a marked window and return [tabnr, winnr]
"
" Comments:
" uses w:WindowMarkers_window_mark; the mark "" may not be searched for
"
" Arguments:
" mark - the identifier of the window in question
"
" Return Value:
" [tabnr, winnr] where tabnr is the tab number containing the window in question
" and winnr is its number relative to the other windows in the containing tab.
" returns an empty list, if no window could be found for this mark
func ToolBox#WindowMarkers#GetWindowNumberByMark(mark)
  for l:Tabnr in range(1, tabpagenr('$'))
    for l:winnr in range(1, tabpagewinnr(l:Tabnr, '$'))
      if ToolBox#WindowMarkers#GetWindowMark( l:winnr, l:Tabnr ) ==# a:mark
        return [ l:Tabnr, l:winnr ]
      endif
    endfor
  endfor
  return []
endfunc

" test if the window specified by mark exists
"
" Comments:
" uses w:WindowMarkers_window_mark; the mark "" may not be searched for
"
" Arguments:
" mark - the identifier of the window in question
"
" Return Value:
" 1 if the window exists, 0 otherwise
func ToolBox#WindowMarkers#MarkedWindowExists(mark)
  return ! empty(ToolBox#WindowMarkers#GetWindowNumberByMark(a:mark))
endfunc

" search a marked window and focus it
"
" Comments:
" uses w:WindowMarkers_window_mark; the mark "" may not be used
"
" Arguments:
" mark - the identifier of the window in question
"
" Return Value:
" [tabnr, winnr] where tabnr is the tab number containing the window in question
" and winnr is its number relative to the other windows in the containing tab.
" returns an empty list, if no window could be found for this mark
func ToolBox#WindowMarkers#GoToWindowByMark(mark)
  let l:winpos = ToolBox#WindowMarkers#GetWindowNumberByMark(a:mark)
  if len(l:winpos) > 0
    exe "tabnext ".l:winpos[0]
    exe l:winpos[1] . "wincmd w"
  endif
endfunc

"H vim: set tw=80 colorcolumn=+1 :
