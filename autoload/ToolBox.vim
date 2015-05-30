" Vim plugin containing various helper tools for scripting vim
" Last Change:	2015-05-30
" Maintainer:	  Benjamin Schnitzler <benjaminschnitzler@googlemail.com>
" License:	    This file is placed in the public domain.
" Comments:     
" · The code in this file shall be at most 80 characters in width
" Todo: see s:Cheet.filter_regions

if exists("g:loaded_ToolBox")
  finish
endif
let g:loaded_ToolBox = 1

" mark the current window with an identifier
"
" Comments:
" sets w:ToolBox_window_mark; the mark should never be empty ("")
"
" Arguments:
" mark - (optional) the identifier chosen for this window; if mark is not given,
"        this function function tests, if the window already has an identifier
"        and if not, it chooses one (one which is not already taken) and marks
"        the window with it
"
" Return Value:
" the chosen identifier
func ToolBox#MarkWindow(...)
  let w:ToolBox_window_mark = ""
  if a:0 > 0
    let w:ToolBox_window_mark = a:1
  else
    let w:ToolBox_window_mark = ToolBox#GetWindowMark()
    if w:ToolBox_window_mark == ""
      let l:marks = ToolBox#GetWindowMarks()
      let w:ToolBox_window_mark = max(l:marks) + 1
    endif
  endif
  return w:ToolBox_window_mark
endfunc

" get the mark for for the specified window
"
" Comments:
" uses w:ToolBox_window_mark
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
func ToolBox#GetWindowMark( ... )
  let l:winnr = 0
  let l:tabnr = 0
  let l:defval = ""
  if a:0 > 0
    let l:winnr = a:1
  endif
  if a:0 > 1
    let l:tabnr = a:1
  endif
  if a:0 > 2
    let l:defval = a:3
  endif
  return gettabwinvar( l:tabnr, a:winnr, 'ToolBox_window_mark', l:defval )
endfunc

" get a list of all existing window marks
"
" Return Value:
" a list containing all marks of all windows
func ToolBox#GetWindowMarks
  let l:marks = []
  for l:tabnr in range(1, tabpagenr('$'))
    for l:winnr in range(1, tabpagewinnr(l:tabnr, '$'))
      let l:mark = ToolBox#GetWindowMark( l:winnr, l:tabnr )
      if l:mark != ""
        call add( l:marks, l:mark )
      endif
    endfor
  endfor
  return l:marks
endfunc

" search a marked window and return [tabnr, winnr]
"
" Comments:
" uses w:ToolBox_window_mark; the mark "" may not be searched for
"
" Arguments:
" mark - the identifier of the window in question
"
" Return Value:
" [tabnr, winnr] where tabnr is the tab number containing the window in question
" and winnr is its number relative to the other windows in the containing tab.
" returns an empty list, if no window could be found for this mark
func ToolBox#GetWindowNumberByMark(mark)
  for l:tabnr in range(1, tabpagenr('$'))
    for l:winnr in range(1, tabpagewinnr(l:tabnr, '$'))
      if ToolBox#GetWindowMark( l:winnr, l:tabnr ) == a:mark
        return [ l:tabnr, l:winnr ]
      endif
    endfor
  endfor
  return []
endfunc

"H vim: set tw=80 colorcolumn=+1 :
