"=============================================================================
" 	     File: custommacros.vim
"      Author: Mikolaj Machowski
" 	  Version: 1.0 
"     Created: Tue Apr 23 05:00 PM 2002 PST
" Last Change: Thu Dec 26 05:00 PM 2002 PST
" 
"  Description: functions for processing custom macros in the
"               latex-suite/macros directory
"=============================================================================

let s:path = expand('<sfile>:p:h')

" SetCustomMacrosMenu: sets up the menu for Macros {{{
function! <SID>SetCustomMacrosMenu()
	let flist = glob(s:path."/macros/*")
	exe 'amenu '.g:Tex_MacrosMenuLocation.'&New :call NewMacro()<CR>'
	exe 'amenu '.g:Tex_MacrosMenuLocation.'&Redraw :call RedrawMacro()<CR>'

	let i = 1
	while 1
		let fname = Tex_Strntok(flist, "\n", i)
		if fname == ''
			break
		endif
		let fnameshort = fnamemodify(fname, ':p:t:r')
		exe "amenu ".g:Tex_MacrosMenuLocation."&Delete.&".i.":<tab>".fnameshort." :call <SID>DeleteMacro('".fnameshort."')<CR>"
		exe "amenu ".g:Tex_MacrosMenuLocation."&Edit.&".i.":<tab>".fnameshort."   :call <SID>EditMacro('".fnameshort."')<CR>"
		exe "imenu ".g:Tex_MacrosMenuLocation."&".i.":<tab>".fnameshort." <C-r>=<SID>ReadMacro('".fnameshort."')<CR>"
		exe "nmenu ".g:Tex_MacrosMenuLocation."&".i.":<tab>".fnameshort." i<C-r>=<SID>ReadMacro('".fnameshort."')<CR>"
		let i = i + 1
	endwhile
endfunction 

if g:Tex_Menus
	call <SID>SetCustomMacrosMenu()
endif

" }}}
" NewMacro: opens new file in macros directory {{{
function! NewMacro()
	exe "cd ".s:path."/macros"
	new
	set filetype=tex
endfunction

" }}}
" RedrawMacro: refreshes macro menu {{{
function! RedrawMacro()
	aunmenu TeX-Suite.Macros
	call <SID>SetCustomMacrosMenu()
endfunction

" }}}
" DeleteMacro: deletes macro file {{{
function! <SID>DeleteMacro(...)
	if a:0 > 0
		let filename = a:1
	else
		let pwd = getcwd()
		exe 'cd '.s:path.'/macros'
		let filename = Tex_ChooseFile('Choose a macro file for deletion :')
		exe 'cd '.pwd
	endif

	let ch = confirm('Really delete '.filename.' ?', 
		\"Yes\nNo", 2)
	if ch == 1
		call delete(s:path.'/macros/'.filename)
	endif
	call RedrawMacro()
endfunction

" }}}
" EditMacro: edits macro file {{{
function! <SID>EditMacro(...)
	if a:0 > 0
		let filename = a:1
	else
		let pwd = getcwd()
		exe 'cd '.s:path.'/macros'
		let filename = Tex_ChooseFile('Choose a macro file for insertion:')
		exe 'cd '.pwd
	endif

	exe "split ".s:path."/macros/".filename
	exe "lcd ".s:path."/macros/"
	set filetype=tex
endfunction

" }}}
" ReadMacro: reads in a macro from a macro file.  {{{
"            allowing for placement via placeholders.
function! <SID>ReadMacro(...)

	if a:0 > 0
		let filename = a:1
	else
		let pwd = getcwd()
		exe 'cd '.s:path.'/macros'
		let filename = Tex_ChooseFile('Choose a macro file for insertion:')
		exe 'cd '.pwd
	endif

	let fname = s:path.'/macros/'.filename

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
com! -nargs=? TMacro          :call <SID>ReadMacro(<f-args>)
com! -nargs=0 TMacroNew       :call <SID>NewMacro()
com! -nargs=? TMacroEdit      :call <SID>EditMacro(<f-args>)
com! -nargs=? TMacroDelete    :call <SID>DeleteMacro(<f-args>)

" }}}

" vim:fdm=marker:ts=4:sw=4:noet
