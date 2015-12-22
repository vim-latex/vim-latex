" filebrowser.vim: utility file for vim 6.2+
"
" Copyright: Srinath Avadhanula <srinath AT fastmail DOT fm>
" 	Parts of this file are taken from explorer.vim which is a plugin file
" 	distributed with vim under the Vim charityware license.
" License: distributed under the Vim charityware license.
"
" Settings:
" FB_CallBackFunction: the function name which gets called when the user
" 		presses <cr> on a file-name in the file browser.
" FB_AllowRegexp: A filename has to match this regexp to be displayed.
" FB_RejectRegexp: If a filename matches this regexp, then its not displayed.
" 		(Both these regexps are '' by default which means no filtering is
" 		done).

" line continuation used here.
let s:save_cpo = &cpo
set cpo&vim

"======================================================================
" Globally visible functions (API)
"======================================================================
" FB_OpenFileBrowser: opens a new buffer and displays the file list {{{
" Description:
function! FB_OpenFileBrowser(dir)
	return latexsuite#filebrowser#FB_OpenFileBrowser(a:dir)
endfunction " }}}
" FB_DisplayFiles: displays the files in a given directory {{{
" Description:
" 	Call this function only when the cursor is in a temporary buffer
function! FB_DisplayFiles(dir)
	return latexsuite#filebrowser#FB_DisplayFiles(a:dir)
endfunction " }}}
" FB_SetVar: sets script local variables from outside this script {{{
" Description:
function! FB_SetVar(varname, value)
	return latexsuite#filebrowser#FB_SetVar(a:varname, a:value)
endfunction " }}}

let &cpo = s:save_cpo

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4:nowrap
