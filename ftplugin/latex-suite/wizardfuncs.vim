"        File: texwizards.vim
"      Author: Mikolaj Machowski <mikmach@wp.pl>
" Last Change: Sun Oct 27 01:00 AM 2002 PST
" Description: 
" 
" Installation:
"      History: pluginized by Srinath Avadhanula
"               ( srinath@fastmail.fm)
"         TODO:
"=============================================================================

if exists('s:doneOnce')
	finish
endif
let s:doneOnce = 1

" Tex_MenuWizard: the king of the wizards {{{
"
function! Tex_MenuWizard(submenu, env)
    if (a:env=="figure" || a:env=="figure*" )
        return Tex_figure(a:env)
    elseif (a:env=="table" || a:env=="table*")
        return Tex_table(a:env)
    elseif (a:env=="tabular" || a:env=="tabular*" ||
           \a:env=="array" || a:env=="array*")
        return Tex_tabular(a:env)
    elseif (a:env=="eqnarray" || a:env=="equation*")
        return Tex_eqnarray(a:env)
    elseif (a:env=="list")
        return Tex_list(a:env)
    elseif (a:env=="itemize" || a:env=="theindex" ||
           \a:env=="trivlist" || a:env=="enumerate")
        return Tex_itemize(a:env)
    elseif (a:env=="description")
        return Tex_description(a:env)
    elseif (a:env=="document")
        return Tex_document(a:env)
    elseif (a:env=="minipage")
        return Tex_minipage(a:env)
    elseif (a:env=="thebibliography")
        return Tex_thebibliography(a:env)
    else
        return IMAP_PutTextWithMovement("\\begin{".a:env."}\<cr>«»\<cr>\\end{".a:env."}«»")
    endif
endfunction

" }}}

" ==============================================================================
" Specialized functions for various environments
" ============================================================================== 
" Tex_itemize: {{{
function! Tex_itemize(env)
	return "\\begin{".a:env."}\<cr>\\item \<cr>\\end{".a:env."}«»\<Up>"
endfunction

" }}} 
" Tex_description: {{{
function! Tex_description(env)
	let itlabel = input("(Optional) Item label? ")
	if (itlabel != "")
		let itlabel = '['.itlabel.']'
	endif
	return IMAP_PutTextWithMovement("\\begin{description}\<cr>\\item".itlabel." \<cr>\\end{description}«»\<Up>")
endfunction

" }}} 
" Tex_figure: {{{
function! Tex_figure(env)
    let flto = input("Float to (htbp)? ")
    let caption = input("Caption? ")
    let center = input("Center ([y]/n)? ")
    let label = input('Label (for use with \ref)? ')
    " additional to AUC Tex since my pics are usually external files
    let pic = input("Name of Pic-File? ")
    if (flto != "")
        let flto = "[".flto."]\<cr>"
    else
        let flto = "\<cr>"
    endif
    if (pic != "")
        let pic = "\\input{".pic."}\<cr>"
    else
        let pic = "ä\<cr>"
    endif
    if (caption != "")
        let caption = "\\caption{".caption."}\<cr>"
    endif
    if (label != "")
        let label = "\\label{fig:".label."}\<cr>"
    endif
    if (center == "y" || center == "")
      let centr = "\\begin{center}\<cr>"
      let centr = centr . pic 
      let centr = centr . caption
      let centr = centr . label
      let centr = centr . "\\end{center}\<cr>"
    else
      let centr = pic
      let centr = centr . caption
      let centr = centr . label
    endif
    let figure = "\\begin{".a:env."}".flto
    let figure = figure . centr
    let figure = figure . "\\end{".a:env."}«»"
    return IMAP_PutTextWithMovement(figure)
endfunction

" }}} 
" Tex_table: {{{
function! Tex_table(env)
    let flto = input("Float to (htbp)? ")
    let caption = input("Caption? ")
    let center = input("Center (y/n)? ")
    let label = input('Label (for use with \ref)? ')
    if (flto != "")
        let flto ="[".flto."]\<cr>"
    else
        let flto = ""
    endif
    let ret="\\begin{table}".flto
    if (center == "y")
        let ret=ret."\<cr>\\begin{center}"
    endif
    let foo = "\<cr>\\begin{tabular}"
    let pos = input("(Optional) Position (t b)? ")
    if (pos!="")
        let foo = foo.'['.pos.']'
    endif
    let format = input("Format  ( l r c p{width} | @{text} )? ")
	if format == ''
		let format = '«»'
	endif
    let ret = ret.foo.'{'.format."}\<cr>«»\<cr>\\end{tabular}«»\<cr>"
    if (center == "y")
        let ret=ret."\\end{center}\<cr>"
    endif
    if (caption != "")
        let ret=ret."\\caption{".caption."}\<cr>"
    endif
    if (label != "")
        let ret=ret."\\label{tab:".label."}\<cr>"
    endif
    let ret=ret."\\end{table}«»"
	return IMAP_PutTextWithMovement(ret)
endfunction

" }}} 
" Tex_tabular: {{{
function! Tex_tabular(env)
    let pos = input("(Optional) Position (t b)? ")
    if (pos!="")
      let pos = '['.pos.']'
    endif
    let format = input("Format  ( l r c p{width} | @{text} )? ")
    if format != ""
      let format = '{'.format.'}'
    endif
    return IMAP_PutTextWithMovement("\\begin{".a:env."}".pos.format."\<cr> \<cr>\\end{".a:env."}«»\<Up>\<Left>")
endfunction

" }}} 
" Tex_eqnarray: {{{
function! Tex_eqnarray(env)
    let label = input("Label (for use with \ref)? ")
    if (label != "")
        let arrlabel = "\\label{eqn:".label."}\<cr> "
      else
        let arrlabel = " "
    endif
    return IMAP_PutTextWithMovement("\\begin{".a:env."}\<cr>".arrlabel."\<cr>\\end{".a:env."}«»\<Up>\<Left>")
endfunction

" }}} 
" Tex_list: {{{
function! Tex_list(env)
	let label = input("Label (for \item)? ")
	if (label != "")
		let label = "{".label."}"
		let addcmd = input("Additional commands? ")
		if (addcmd != "")
			let label = label . "{".addcmd."}"
		endif
	else
		let label = ""
	endif
	return IMAP_PutTextWithMovement("\\begin{list}".label."\<cr>\\item \<cr>\\end{list}«»\<Up>")
endfunction

" }}} 
" Tex_document: {{{
function! Tex_document(env)
    let dstyle = input("Document style? ")
    let opts = input("(Optional) Options? ")
    let foo = '\documentclass'
    if (opts=="")
        let foo = foo.'{'.dstyle.'}'
    else
        let foo = foo.'['.opts.']'.'{'.dstyle.'}'
    endif
    return IMAP_PutTextWithMovement(foo . "\<cr>\<cr>\\begin{document}\<cr>\<cr>\\end{document}\<Up>")
endfunction

" }}} 
" Tex_minipage: {{{
function! Tex_minipage(env)
    let foo = '\begin{minipage}'
    let pos = input("(Optional) Position (t b)? ")
    let width = input("Width? ")
    if (pos=="")
        let foo = foo.'{'.width.'}'
    else
        let  foo = foo.'['.pos.']{'.width.'}'
    endif
    return IMAP_PutTextWithMovement(foo . "\<cr> \<cr>\\end{minipage}\<Up>\<Left>")
endfunction

" }}} 
" Tex_thebibliography: {{{
function! Tex_thebibliography()
    " AUC Tex: "Label for BibItem: 99"
    let indent = input("Indent for BibItem? ")
    let foo = "{".indent."}"
    let biblabel = input("(Optional) Bibitem label? ")
    let key = input("Add key? ")
    let bar = "\\bibitem"
    if (biblabel != "")
        let bar = bar.'['.biblabel.']'
    endif
    let bar = bar.'{'.key.'}'
    return IMAP_PutTextWithMovement("\\begin{thebibliography}".foo."\<cr>".bar." \<cr>\\end{thebibliography}\<Up>\<Left>")
endfunction

" }}} 
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
	exe IMAP_PutTextWithMovement("normal `>a}\<cr>\<esc>`<i".sstructure.toc.shorttitle."{")
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

" ==============================================================================
" Specialized functions for handling sections from command line
" ============================================================================== 

com! -nargs=? TSection call Tex_section(<f-args>)
com! -nargs=? TSectionAdvanced call Tex_section_adv(<f-args>)

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
	exe "normal! i\\".a:section_name."{«»}«»\<Esc>0\<C-j>"
"	let ret_section = "\\".a:section_name."{«»}«»"
"	exe "normal! i\<C-r>=IMAP_PutTextWithMovement(ret_section)\<CR>"
"	normal f}i
endfunction "}}}
" vim:fdm=marker
