"        File: texwizards.vim
"      Author: Mikolaj Machowski <mikmach@wp.pl>
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
        return "\\begin{".a:env."}\<cr> \<cr>\\end{".a:env."}«»\<Up>\<Left>"
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
	return "\\begin{description}\<cr>\\item".itlabel." \<cr>\\end{description}«»\<Up>"
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
    return "\\begin{".a:env."}".pos.format."\<cr> \<cr>\\end{".a:env."}«»\<Up>\<Left>"
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
    return "\\begin{".a:env."}\<cr>".arrlabel."\<cr>\\end{".a:env."}«»\<Up>\<Left>"
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
	return "\\begin{list}".label."\<cr>\\item \<cr>\\end{list}«»\<Up>"
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
    return foo . "\<cr>\<cr>\\begin{document}\<cr>\<cr>\\end{document}\<Up>"
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
    return foo . "\<cr> \<cr>\\end{minipage}\<Up>\<Left>"
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
    return "\\begin{thebibliography}".foo."\<cr>".bar." \<cr>\\end{thebibliography}\<Up>\<Left>"
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

" vim:fdm=marker
