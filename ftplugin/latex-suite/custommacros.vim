"=============================================================================
" 	     File: custommacros.vim
"      Author: Mikolaj Machowski
" 	  Version: 1.0 
"     Created: Tue Apr 23 05:00 PM 2002 PST
" Last Change: czw maj 09 10:00  2002 U
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
		exe "amenu ".g:Tex_MacrosMenuLocation."&".i.":<tab>".fnameshort." :call <SID>ReadMacro('".fnameshort."')<CR>"
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

	let _a = @a
	let fname = glob(s:path."/macros/".filename)
	silent! exec "normal! o¡!¡Temp Line¡!¡\<ESC>k"
	silent! exec "read ".fname
	silent! exec "normal! V/^¡!¡Temp Line¡!¡$/-1\<CR>\"ax"
	call Tex_CleanSearchHistory()
	
	silent! exec "normal! i\<C-r>='¡!¡Start here¡!¡'.IMAP_PutTextWithMovement(@a)\<CR>"
	let pos = line('.').'| normal! '.virtcol('.').'|'

	call search('^¡!¡Temp Line¡!¡$')
	. d _
	call search('¡!¡Start here¡!¡')
	silent! normal! v15l"_x

	call TeX_pack_all()

	silent! exe pos
	if col('.') < strlen(getline('.'))
		silent! normal! l
	endif
	silent! startinsert
endfunction

" }}}
" commands for macros {{{
com! -nargs=? TMacro          :call <SID>ReadMacro(<f-args>)
com! -nargs=0 TMacroNew       :call <SID>NewMacro()
com! -nargs=? TMacroEdit      :call <SID>EditMacro(<f-args>)
com! -nargs=? TMacroDelete    :call <SID>DeleteMacro(<f-args>)

" }}}

" vim:fdm=marker:ts=4:sw=4:noet
