"        File: wizardfuncs.vim
"      Author: Mikolaj Machowski <mikmach@wp.pl>
" Description: 
" 
" Installation:
"      History: pluginized by Srinath Avadhanula
"               ( srinath@fastmail.fm)
"=============================================================================

if exists('s:doneOnce')
	finish
endif
let s:doneOnce = 1
" ==============================================================================
" Specialized functions for handling sections from command line
" ============================================================================== 

com! -nargs=? TSection call Tex_section(<f-args>)
com! -nargs=? TSectionAdvanced call Tex_section_adv(<f-args>)

" Tex_VisSecAdv: handles visual selection for sections {{{
function! Tex_VisSecAdv(section)
	let shorttitle =  input("Short title? ")
	let toc = input("Include in table of contents [y]/n ? ")
	let sstructure = "\\".a:section
	if ( toc == "" || toc == "y" )
		let toc = ""
	else
		let toc = "*"
	endif
	if shorttitle != ""
		let shorttitle = '['.shorttitle.']'
	endif
	exe "normal `>a}\<cr>\<esc>`<i".sstructure.toc.shorttitle."{"
endfunction 

" }}}
" Tex_InsSecAdv: section wizard in insert mode {{{
function! Tex_InsSecAdv(structure)
	let ttitle = input("Title? ")
	let shorttitle =  input("Short title? ")
	let toc = input("Include in table of contents [y]/n ? ")
	"Structure
	let sstructure = "\\".a:structure
	"TOC
	if ( toc == "" || toc == "y" )
		let toc = ""
	else
		let toc = "*"
	endif
	"Shorttitle
	if shorttitle != ""
		let shorttitle = '['.shorttitle.']'
	endif
	"Title
	let ttitle = '{'.ttitle.'}'
	"Happy end?
	return sstructure.toc.shorttitle.ttitle 
endfunction 


" }}}
function! Tex_section(...) "{{{
	silent let pos = line('.').' | normal! '.virtcol('.').'|'
	silent let last_section_value = s:Tex_section_detection()
	if a:0 == 0
		silent let last_section_name = s:Tex_section_name(last_section_value)
		silent call s:Tex_section_call(last_section_name)
	elseif a:1 =~ "[+=\-]"
		silent let sec_arg = a:1
		silent let curr_section_value = s:Tex_section_curr_rel_value(sec_arg, last_section_value)
		silent let curr_section_name = s:Tex_section_name(curr_section_value)
		silent call s:Tex_section_call(curr_section_name)
	elseif a:1 == "?"
		echo s:last_section_line
	else
		silent let curr_section_value = s:Tex_section_curr_value(a:1)
		silent let curr_section_name = s:Tex_section_name(curr_section_value)
		silent call s:Tex_section_call(curr_section_name)
	endif
	silent exe pos
endfunction "}}}
function! Tex_section_adv(...) "{{{
	let pos = line('.').' | normal! '.virtcol('.').'|'
	silent let last_section_value = s:Tex_section_detection()
	if a:0 == 0
		silent let last_section_name = s:Tex_section_name(last_section_value)
		let section = Tex_InsSecAdv(last_section_name)
	elseif a:1 =~ "[+=\-]"
		silent let sec_arg = a:1
		silent let curr_section_value = s:Tex_section_curr_rel_value(sec_arg, last_section_value)
		silent let curr_section_name = s:Tex_section_name(curr_section_value)
		let section = Tex_InsSecAdv(curr_section_name)
	else
		silent let curr_section_value = s:Tex_section_curr_value(a:1)
		silent let curr_section_name = s:Tex_section_name(curr_section_value)
		silent call s:Tex_section_call(curr_section_name)
		let section = Tex_InsSecAdv(curr_section_name)
	endif
	exe "normal i".section
	exe pos
endfunction "}}}
function! s:Tex_section_detection() "{{{
	let pos = line('.').' | normal! '.virtcol('.').'|'
	let last_section1 = search("\\\\\subparagraph\\|\\\\paragraph\\|\\\\subsubsection\\|\\\\subsection\\|\\\\section\\|\\\\chapter\\|\\\part\)", "b")
	exe pos
	let last_section2 = search("\\\\\part\\|\\\\chapter\\|\\\\section\\|\\\\subsection\\|\\\\subsubsection\\|\\\\paragraph\\|\\\subparagraph\)", "b")
	if last_section1 > last_section2
		let last_section = last_section1
	else
		let last_section = last_section2
	endif
	if last_section != 0
		exe last_section
		if getline(".") =~ "\\\\part"
			let last_section_value = 0
		elseif getline(".") =~ "\\\\chapter"
			let last_section_value = 1
		elseif getline(".") =~ "\\\\section"
			let last_section_value = 2
		elseif getline(".") =~ "\\\\subsection"
			let last_section_value = 3
		elseif getline(".") =~ "\\\\subsubsection"
			let last_section_value = 4
		elseif getline(".") =~ "\\\\paragraph"
			let last_section_value = 5
		elseif getline(".") =~ "\\\\subparagraph"
			let last_section_value = 6
		endif
		let s:last_section_line = getline(".")
	else
		let last_section_value = 0
	endif
	exe pos
	return last_section_value
endfunction "}}}
function! s:Tex_section_curr_value(sec_arg) "{{{
	if a:sec_arg == "pa" || a:sec_arg == "0" || a:sec_arg == "part"
		let curr_section_value = 0
	elseif a:sec_arg == "ch" || a:sec_arg == "1" || a:sec_arg == "chapter"
		let curr_section_value = 1
	elseif a:sec_arg == "se" || a:sec_arg == "2" || a:sec_arg == "section"
		let curr_section_value = 2
	elseif a:sec_arg == "ss" || a:sec_arg == "3" || a:sec_arg == "subsection"
		let curr_section_value = 3
	elseif a:sec_arg == "s2" || a:sec_arg == "4" || a:sec_arg == "subsubsection"
		let curr_section_value = 4
	elseif a:sec_arg == "pr" || a:sec_arg == "5" || a:sec_arg == "paragraph"
		let curr_section_value = 5
	elseif a:sec_arg == "sp" || a:sec_arg == "6" || a:sec_arg == "subparagraph"
		let curr_section_value = 6
	endif
	return curr_section_value
endfunction "}}}
function! s:Tex_section_curr_rel_value(sec_arg, last_section_value) "{{{
	let last_section_value = a:last_section_value
	if a:sec_arg == "+" || a:sec_arg == "+1"
		let curr_section_value = last_section_value + 1
	elseif a:sec_arg == "++" || a:sec_arg == "+2"
		let curr_section_value = last_section_value + 2
	elseif a:sec_arg == "-" || a:sec_arg == "-1"
		let curr_section_value = last_section_value - 1
	elseif a:sec_arg == "--" || a:sec_arg == "-2"
		let curr_section_value = last_section_value - 2
	elseif a:sec_arg == "="
		let curr_section_value = last_section_value
	else
		exe "let curr_section_value = last_section_value".a:sec_arg
	endif
	if curr_section_value < 0
		let curr_section_value = 0
	elseif curr_section_value > 6
		let curr_section_value = 6
	endif
	return curr_section_value
endfunction "}}}
function! s:Tex_section_name(section_value) "{{{
	if a:section_value == 0
		let section_name = "part"
	elseif a:section_value == 1
		let section_name = "chapter"
	elseif a:section_value == 2
		let section_name = "section"
	elseif a:section_value == 3
		let section_name = "subsection"
	elseif a:section_value == 4
		let section_name = "subsubsection"
	elseif a:section_value == 5
		let section_name = "paragraph"
	elseif a:section_value == 6
		let section_name = "subparagraph"
	endif
	return section_name
endfunction "}}}
function! s:Tex_section_call(section_name) "{{{
	exe "normal! i\\".a:section_name."{<++>}<++>\<Esc>0\<C-j>"
"	let ret_section = "\\".a:section_name."{<++>}<++>"
"	exe "normal! i\<C-r>=IMAP_PutTextWithMovement(ret_section)\<CR>"
"	normal f}i
endfunction "}}}

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4
