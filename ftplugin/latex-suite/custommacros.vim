"=============================================================================
" 	     File: custommacros.vim
"      Author: Mikolaj Machowski
" 	  Version: 1.0 
"     Created: Tue Apr 23 05:00 PM 2002 PST
"         CVS: $Id$ 
" 
"  Description: functions for processing custom macros in the
"               latex-suite/macros directory
"=============================================================================

let s:path = expand('<sfile>:p:h')

" Set path to macros dir dependent on OS {{{
if has("unix") || has("macunix")
	let s:macrodirpath = $HOME."/.vim/ftplugin/latex-suite/macros/"
elseif has("win32")
	if exists("$HOME")
		let s:macrodirpath = $HOME."/vimfiles/ftplugin/latex-suite/macros/"
	else
		let s:macrodirpath = $VIMRUNTIME."/ftplugin/latex-suite/macros/"
	endif
endif

" }}}
" SetCustomMacrosMenu: sets up the menu for Macros {{{
function! <SID>SetCustomMacrosMenu()
	let flist = Tex_FileInRtp('', 'macros')
	exe 'amenu '.g:Tex_MacrosMenuLocation.'&New :call NewMacro()<CR>'
	exe 'amenu '.g:Tex_MacrosMenuLocation.'&Redraw :call RedrawMacro()<CR>'

	let i = 1
	while 1
		let fname = Tex_Strntok(flist, ',', i)
		if fname == ''
			break
		endif
		exe "amenu ".g:Tex_MacrosMenuLocation."&Delete.&".i.":<tab>".fname." :call <SID>DeleteMacro('".fname."')<CR>"
		exe "amenu ".g:Tex_MacrosMenuLocation."&Edit.&".i.":<tab>".fname."   :call <SID>EditMacro('".fname."')<CR>"
		exe "imenu ".g:Tex_MacrosMenuLocation."&".i.":<tab>".fname." <C-r>=<SID>ReadMacro('".fname."')<CR>"
		exe "nmenu ".g:Tex_MacrosMenuLocation."&".i.":<tab>".fname." i<C-r>=<SID>ReadMacro('".fname."')<CR>"
		let i = i + 1
	endwhile
endfunction 

if g:Tex_Menus
	call <SID>SetCustomMacrosMenu()
endif

" }}}
" NewMacro: opens new file in macros directory {{{
function! <SID>NewMacro(newmacro)
	if Tex_FileInRtp(a:newmacro, 'macros') != ''
		exe "echomsg 'Macro with name '".a:newmacro."' exists. Try another one.'"
		return
	endif
	exe 'split '.s:macrodirpath.a:newmacro
	setlocal filetype=tex
endfunction

" }}}
" RedrawMacro: refreshes macro menu {{{
function! RedrawMacro()
	aunmenu TeX-Suite.Macros
	call <SID>SetCustomMacrosMenu()
endfunction

" }}}
" ChooseMacro: choose a macro file {{{
" " Description: 
function! s:ChooseMacro(ask)
	let filelist = Tex_FileInRtp('', 'macros')
	let filename = Tex_ChooseFromPrompt(
				\ a:ask."\n" . 
				\ Tex_CreatePrompt(filelist, 2, ',') .
				\ "\nEnter number or filename :",
				\ filelist, ',')
endfunction 

" }}}
" DeleteMacro: deletes macro file {{{
function! <SID>DeleteMacro(...)
	if a:0 > 0
		let filename = a:1
	else
		let filename = s:ChooseMacro('Choose a macro file for deletion :')
	endif

	" Remove only if filename is in local directory
	if !filereadable(s:macrodirpath.filename)
		call confirm('This file is not in your local directory: '.filename."\n".
					\ 'It will not be deleted.' , '&OK', 1)

	else
		let ch = confirm('Really delete '.filename.' ?', "&Yes\n&No", 2)
		if ch == 1
			call delete(s:macrodirpath.filename)
		endif
		call RedrawMacro()
	endif
endfunction

" }}}
" EditMacro: edits macro file {{{
function! <SID>EditMacro(...)
	if a:0 > 0
		let filename = a:1
	else
		let filename = s:ChooseMacro('Choose a macro file for insertion:')
	endif

	if filereadable(s:macrodirpath.filename)
		exe 'split '.s:macrodirpath.filename
	else
		let ch = confirm("You are trying to edit file which is probably read-only.\n".
					\ "It will be copied to your local LaTeX-Suite macros directory\n".
					\ "and you will be operating on local copy with suffix -local.\n".
					\ "It will succeed only if ftplugin/latex-suite/macros dir exists.\n".
					\ "Do you agree?", "&Yes\n&No", 1)
		if ch == 1
			new
			exe '0read '.Tex_FileInRtp(filename, 'macros')
			exe 'write '.s:macrodirpath.filename.'-local'
		endif
		
	endif
	setlocal filetype=tex
endfunction

" }}}
" ReadMacro: reads in a macro from a macro file.  {{{
"            allowing for placement via placeholders.
function! <SID>ReadMacro(...)

	if a:0 > 0
		let filename = a:1
	else
		let filelist = Tex_FileInRtp('', 'macros')
		let filename = 
					\ Tex_ChooseFromPrompt("Choose a macro file:\n" . 
					\ Tex_CreatePrompt(filelist, 2, ',') . 
					\ "\nEnter number or name of file :", 
					\ filelist, ',')
	endif

	let fname = Tex_FileInRtp(filename, 'macros')

	let markerString = '<---- Latex Suite End Macro ---->'
	let _a = @a
	let position = line('.').' | normal! '.virtcol('.').'|'
	silent! call append(line('.'), markerString)
	silent! exec "read ".fname
	silent! exec "normal! V/^".markerString."$/-1\<CR>\"ax"
	" This is kind of tricky: At this stage, we are one line after the one we
	" started from with the marker text on it. We need to
	" 1. remove the marker and the line.
	" 2. get focus to the previous line.
	" 3. not remove anything from the previous line.
	silent! exec "normal! $v0k$\"_x"

	call Tex_CleanSearchHistory()

	let @a = substitute(@a, '['."\n\r\t ".']*$', '', '')
	let textWithMovement = IMAP_PutTextWithMovement(@a)
	let @a = _a

	return textWithMovement

endfunction

" }}}
" commands for macros {{{
com! -nargs=1 TMacroNew :call <SID>NewMacro(<f-args>)

" This macros had to have 2 versions:
if v:version >= 602 
	com! -complete=custom,Tex_CompleteMacroName -nargs=? TMacro
				\ :let s:retVal = <SID>ReadMacro(<f-args>) <bar> normal! i<C-r>=s:retVal<CR>
	com! -complete=custom,Tex_CompleteMacroName -nargs=? TMacroEdit
				\ :call <SID>EditMacro(<f-args>)
	com! -complete=custom,Tex_CompleteMacroName -nargs=? TMacroDelete
				\ :call <SID>DeleteMacro(<f-args>)

	" Tex_CompleteMacroName: for completing names in TMacro... commands {{{
	"	Description: get list of macro names with Tex_FileInRtp(), remove full path
	"	and return list of names separated with newlines.
	"
	function! Tex_CompleteMacroName(A,P,L)
		" Get name of macros from all runtimepath directories
		let macronames = Tex_FileInRtp('', 'macros')
		" Separate names with \n not ,
		let macronames = substitute(macronames,',','\n','g')
		return macronames
	endfunction

	" }}}

else
	com! -nargs=? TMacro
		\	:let s:retVal = <SID>ReadMacro(<f-args>) <bar> normal! i<C-r>=s:retVal<CR>
	com! -nargs=? TMacroEdit   :call <SID>EditMacro(<f-args>)
	com! -nargs=? TMacroDelete :call <SID>DeleteMacro(<f-args>)

endif

" }}}

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4
