"=============================================================================
" 	     File: templates.vim
"      Author: Gergely Kontra
"              (minor modifications by Srinath Avadhanula)
"              (plus other modifications by Mikolaj Machowski) 
" 	  Version: 1.0 
"     Created: Tue Apr 23 05:00 PM 2002 PST
"         CVS: $Id$ 
" 
"  Description: functions for handling templates in latex-suite/templates
"               directory.
"=============================================================================

let s:path = expand("<sfile>:p:h")

" SetTemplateMenu: sets up the menu for templates {{{
function! <SID>SetTemplateMenu()
	let flist = Tex_FindInRtp('', 'templates')
	let i = 1
	while 1
		let fname = Tex_Strntok(flist, ',', i)
		if fname == ''
			break
		endif
		exe "amenu ".g:Tex_TemplatesMenuLocation."&".i.":<Tab>".fname." ".
			\":call <SID>ReadTemplate('".fname."')<CR>".
			\":call <SID>ProcessTemplate()<CR>:0<CR>".
			\"i<C-r>=IMAP_Jumpfunc('', 1)<CR>"
		let i = i + 1
	endwhile
endfunction 

if g:Tex_Menus
	call <SID>SetTemplateMenu()
endif

" }}}
" ReadTemplate: reads in the template file from the template directory. {{{
function! <SID>ReadTemplate(...)
	if a:0 > 0
		let filename = a:1.'.*'
	else
		let filelist = Tex_FindInRtp('', 'templates')
		let filename = 
					\ Tex_ChooseFromPrompt("Choose a template file:\n" . 
					\ Tex_CreatePrompt(filelist, 2, ',') . 
					\ "\nEnter number or name of file :", 
					\ filelist, ',')
	endif

	let fname = Tex_FindInRtp(filename, 'templates')
	silent! exe "0read ".fname
	" The first line of the file contains the specifications of what the
	" placeholder characters and the other special characters are.
	let pattern = '\v(\S+)\t(\S+)\t(\S+)\t(\S+)'

	let s:phsTemp = substitute(getline(1), pattern, '\1', '')
	let s:pheTemp = substitute(getline(1), pattern, '\2', '')
	let s:exeTemp = substitute(getline(1), pattern, '\3', '')
	let s:comTemp = substitute(getline(1), pattern, '\4', '')

	call Tex_Debug('phs = '.s:phsTemp.', phe = '.s:pheTemp.', exe = '.s:exeTemp.', com = '.s:comTemp)

	" delete the first line into ze blackhole.
	0 d _

	call Tex_pack_updateall(1)
endfunction

" }}}
" ProcessTemplate: processes the special characters in template file. {{{
"                  This implementation follows from Gergely Kontra's
"                  mu-template.vim
"                  http://vim.sourceforge.net/scripts/script.php?script_id=222
function! <SID>ProcessTemplate()
	if exists('s:phsTemp') && s:phsTemp != ''

		exec 'silent! %s/^'.s:comTemp.'\(\_.\{-}\)'.s:comTemp.'$/\=<SID>Compute(submatch(1))/ge'
		exec 'silent! %s/'.s:exeTemp.'\(.\{-}\)'.s:exeTemp.'/\=<SID>Exec(submatch(1))/ge'
		exec 'silent! g/'.s:comTemp.s:comTemp.'/d'
		
		let phsUser = IMAP_GetPlaceHolderStart()
		let pheUser = IMAP_GetPlaceHolderEnd()

		exec 'silent! %s/'.s:phsTemp.'\(.\{-}\)'.s:pheTemp.'/'.phsUser.'\1'.pheUser.'/ge'

		" A function only puts one item into the search history...
		call Tex_CleanSearchHistory()
	endif
endfunction

function! <SID>Exec(what)
	exec 'return '.a:what
endfunction

" Back-Door to trojans !!!
function! <SID>Compute(what)
	exe a:what
	if exists('s:comTemp')
		return s:comTemp.s:comTemp
	else
		return ''
	endif
endfunction

" }}}
" Command definitions {{{
if v:version >= 602
	com! -complete=custom,Tex_CompleteTemplateName -nargs=? TTemplate :call <SID>ReadTemplate(<f-args>)
		\| :call <SID>ProcessTemplate()
		\| :0
		\| :exec "normal! i\<C-r>=IMAP_Jumpfunc('', 1)\<CR>"
		\| :startinsert

	" Tex_CompleteTemplateName: for completing names in TTemplate command {{{
	"	Description: get list of template names with Tex_FindInRtp(), remove full path
	"	and return list of names separated with newlines.
	"
	function! Tex_CompleteTemplateName(A,P,L)
		" Get name of macros from all runtimepath directories
		let tmplnames = Tex_FindInRtp('', 'templates')
		" Separate names with \n not ,
		let tmplnames = substitute(tmplnames,',','\n','g')
		return tmplnames
	endfunction
	" }}}
	
else
	com! -nargs=? TTemplate :call <SID>ReadTemplate(<f-args>)
		\| :call <SID>ProcessTemplate()
		\| :0
		\| :exec "normal! i\<C-r>=IMAP_Jumpfunc('', 1)\<CR>"
		\| :startinsert

endif

" }}}

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4
