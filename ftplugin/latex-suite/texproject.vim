"=============================================================================
" 	     File: texproject.vim
"      Author: Mikolaj Machowski
" 	  Version: 1.0 
"     Created: Wen Apr 16 05:00 PM 2003
" 
"  Description: Handling tex projects.
"  
"=============================================================================

let s:path = expand("<sfile>:p:h")

command! -nargs=0 TProjectEdit  :call <SID>Tex_ProjectEdit()
command! -nargs=0 TProjectWrite :call <SID>Tex_ProjectWrite()
command! -nargs=0 TProject      :call <SID>Tex_Project()

" Tex_ProjectEdit: Edit project file " {{{
" Description: If project file exists (*.latexmain) open it in window created
"              with ':split', if no create ':new' window and read there
"              project template
"
function! s:Tex_ProjectEdit()

	let file = expand("%:p")
	let mainfname = Tex_GetMainFileName()
	if glob(mainfname.'.latexmain') != ''
		exec 'split '.Tex_EscapeSpaces(mainfname.'.latexmain')
	else
		exec 'split '.Tex_EscapeSpaces(s:path.'/projecttemplate.vim')
		exec 'saveas '.Tex_EscapeSpaces(file.'.latexmain')
		let g:Tex_ProjectExists = 1
	endif

endfunction " }}}
" Tex_ProjectWrite: write project and source it to refresh changed vars {{{
" Description: 
"
function! s:Tex_ProjectWrite()

	if expand("%:e") =~ 'latexmain$'
		write!
		source %
		q
	else
		echoerr "Sorry, this is not project file"
		return
	endif

endfunction " }}}
" Tex_Project: open project view in explorer {{{
" Description:
"
function! s:Tex_Project()

	if g:Tex_ProjectExists == 1
		new
		let w:projView = 1
		:Explore
	else
		echoerr "Sorry, no project file exists"
		finish
	endif

endfunction " }}}

" Load project file if exists
if glob(Tex_GetMainFileName().'.latexmain') != ''
	exe 'source '.Tex_GetMainFileName().'.latexmain'
	let g:Tex_ProjectExists = 1
else
	let g:Tex_ProjectExists = 0
endif

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4
