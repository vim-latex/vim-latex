"=============================================================================
" 	     File: templates.vim
"      Author: Gergely Kontra
"              (minor modifications by Srinath Avadhanula)
" 	  Version: 1.0 
"     Created: Tue Apr 23 05:00 PM 2002 PST
" Last Change: ¶ro maj 08 12:00  2002 U
" 
"  Description: functions for handling templates in latex-suite/templates
"               directory.
"=============================================================================

let s:path = expand("<sfile>:p:h")

" SetTemplateMenu: sets up the menu for templates {{{
function! <SID>SetTemplateMenu()
	let flist = glob(s:path."/templates/*")
	let i = 1
	while 1
		let fname = Tex_Strntok(flist, "\n", i)
		if fname == ''
			break
		endif
		let fnameshort = fnamemodify(fname, ':p:t:r')
		if fnameshort == ''
			let i = i + 1
			continue
		endif
		exe "amenu ".g:Tex_TemplatesMenuLocation."&".i.":<Tab>".fnameshort." ".
			\":call <SID>ReadTemplate('".fnameshort."')<CR>".
			\":call <SID>ProcessTemplate()<CR>:0<CR>".
			\"i<C-r>=IMAP_Jumpfunc()<CR>"
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
		let filename = a:1
	else
		let pwd = getcwd()
		exe 'cd '.s:path.'/templates'
		let filename = Tex_ChooseFile('Choose a template file:')
		exe 'cd '.pwd
	endif

	let fname = glob(s:path."/templates/".filename.'.*')
	exe "0read ".fname
	call TeX_pack_all()
endfunction

" }}}
" ProcessTemplate: processes the special characters in template file. {{{
"                  This implementation follows from Gergely Kontra's
"                  mu-template.vim
"                  http://vim.sourceforge.net/scripts/script.php?script_id=222
function! <SID>ProcessTemplate()
    silent! %s/^¿\(\_.[^¿]*\)¿$/\=<SID>Compute(submatch(1))/ge
    silent! %s/¡\([^¡]*\)¡/\=<SID>Exec(submatch(1))/ge
	silent! g/¿¿/d

	call Tex_CleanSearchHistory()
	call Tex_CleanSearchHistory()
	call Tex_CleanSearchHistory()
endfunction

function! <SID>Exec(what)
  exec 'return '.a:what
endfunction

" Back-Door to trojans !!!
function! <SID>Compute(what)
  exe a:what
  return "¿¿"
endfunction

" }}}

com! -nargs=? TTemplate :call <SID>ReadTemplate(<f-args>)
					   \| :call <SID>ProcessTemplate()
					   \| :0
					   \| :exec "normal! i\<C-r>=IMAP_Jumpfunc()\<CR>"
					   \| :startinsert

" vim:fdm=marker:ts=4:sw=4:noet
