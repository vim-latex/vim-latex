"=============================================================================
" 	     File: compiler.vim
"      Author: Srinath Avadhanula
" 	  Version: 1.0 
"     Created: Tue Apr 23 05:00 PM 2002 PST
" Last Change: Sun Oct 27 10:00 PM 2002 PST
" 
"  Description: functions for compiling/viewing/searching latex documents
"=============================================================================

" SetTeXCompilerTarget: sets the 'target' for the next call to RunLaTeX() {{{
function! SetTeXCompilerTarget(type, target)
	if a:target == ''
		let target = input('Enter the target ([dvi]/ps/pdf/...) for '.a:type.'r:')
	else
		let target = a:target
	endif
	if target == ''
		let target = 'dvi'
	endif
	if exists('g:Tex_'.a:type.'Rule_'.target)
		if a:type == 'Compile'
			exec 'let &l:makeprg = g:Tex_CompileRule_'.target
		elseif a:type == 'View'
			exec 'let s:viewer = g:Tex_'.a:type.'Rule_'.target
		endif
		let s:target = target
	else
		let curd = getcwd()
		exe 'cd '.expand('%:p:h')
		if glob('makefile*') == ''
			if has('gui_running')
				call confirm(
					\'No '.a:type.' rule defined for target '.target."\n".
					\'Please specify a rule in texrc.vim'."\n".
					\'     :help latex-compiler-target'."\n".
					\'for more information',
					\"&ok", 1, 'Warning')
			else
				call input( 
					\'No compilation rule defined for target '.target."\n".
					\'Please specify a rule in texrc.vim'."\n".
					\'     :help latex-compiler-target'."\n".
					\'for more information'
					\)
			endif
		else
			echomsg 'assuming target is for makefile'
			let s:target = target
		endif
		exe 'cd '.curd
	endif
endfunction 

function! SetTeXTarget(...)
	if a:0 < 1
		let target = input('Enter target for compiler and viewer ([dvi]/ps/pdf/...) :')
	else
		let target = a:1
	endif
	if target == ''
		let target = 'dvi'
	endif
	call SetTeXCompilerTarget('Compile', target)
	call SetTeXCompilerTarget('View', target)
endfunction

com! -nargs=1 TCTarget :call SetTeXCompilerTarget('Compile', <f-args>)
com! -nargs=1 TVTarget :call SetTeXCompilerTarget('View', <f-args>)
com! -nargs=1 TTarget :call SetTeXTarget(<f-args>)

" }}}
" RunLaTeX: compilation function {{{
" this function runs the latex command on the currently open file. often times
" the file being currently edited is only a fragment being \input'ed into some
" master tex file. in this case, make a file called mainfile.latexmain in the
" directory containig the file. in other words, if the current file is
" ~/thesis/chapter.tex
" so that doing "latex chapter.tex" doesnt make sense, then make a file called 
" main.tex.latexmain 
" in the ~/thesis directory. this will then run "latex main.tex" when
" RunLaTeX() is called.
function! RunLaTeX()
	if &ft != 'tex'
		echo "calling RunLaTeX from a non-tex file"
		return
	end
	let dir = expand("%:p:h").'/'
	let curd = getcwd()
	exec 'cd '.expand("%:p:h")

	" if a makefile exists, just use the make utility
	if glob('makefile') || glob('Makefile')
		let _makeprg = &l:makeprg
		let &l:makeprg = 'make $*'
		if exists('s:target')
			exec 'make '.s:target
		else
			exec 'make'
		endif
		let &l:makeprg = _makeprg
	" otherwise if a *.latexmain file is found, then use that file to
	" construct a main file.
	elseif Tex_GetMainFileName() != ''
		let mainfname = Tex_GetMainFileName()
	else
		" otherwise just use this file.
		let mainfname = expand("%:t:r")
	endif

	exec 'make '.mainfname

	cwindow
	exec 'cd '.curd
endfunction

" }}}
" ViewLaTeX: opens viewer {{{
" Description: opens the DVI viewer for the file being currently edited.
" Again, if the current file is a \input in a master file, see text above
" RunLaTeX() to see how to set this information.
function! ViewLaTeX()
	if &ft != 'tex'
		echo "calling ViewLaTeX from a non-tex file"
		return
	end
	
	let dir = expand("%:p:h").'/'
	let curd = getcwd()
	exec 'cd '.expand("%:p:h")
	
	if Tex_GetMainFileName() != ''
		let mainfname = Tex_GetMainFileName()
	else
		let mainfname = expand("%:p:t:r")
	endif

	if has('win32')
		" unfortunately, yap does not allow the specification of an external
		" editor from the command line. that would have really helped ensure
		" that this particular vim and yap are connected.
		exec '!start '.s:viewer.' '.mainfname.'.'.s:target
	else
		" taken from Dimitri Antoniou's tip on vim.sf.net (tip #225).
		" slight change to actually use the current servername instead of
		" hardcocing it as xdvi.
		" Using an option for specifying the editor in the command line
		" because that seems to not work on older bash'es.
		if s:target == 'dvi'
			if exists('g:Tex_UseEditorSettingInDVIViewer') && \
				g:Tex_UseEditorSettingInDVIViewer == 1
				exec '!'.s:viewer.' -editor "gvim --servername '.v:servername.' --remote-silent +%l %f" '.mainfname.'.dvi &'
			else
				exec '!'.s:viewer.' '.mainfname.'.dvi &'
			endif
		else
			exec '!'.s:viewer.' '.mainfname.'.'.s:target.' &'
		endif
	end

	exec 'cd '.curd
endfunction

" }}}
" ForwardSearchLaTeX: searches for current location in dvi file. {{{
" Description: if the DVI viewr is compatible, then take the viewer to that
"              position in the dvi file. see docs for RunLaTeX() to set a
"              master file if this is an \input'ed file. 
" Tip: With YAP on Windows, it is possible to do forward and inverse searches
"      on DVI files. to do forward search, you'll have to compile the file
"      with the --src-specials option. then set the following as the command
"      line in the 'view/options/inverse search' dialog box:
"           gvim --servername LATEX --remote-silent +%l "%f"
"      For inverse search, if you are reading this, then just pressing \ls
"      will work.
function! ForwardSearchLaTeX()
	if &ft != 'tex'
		echo "calling ViewLaTeX from a non-tex file"
		return
	end
	" only know how to do forward search for yap on windows and xdvik (and
	" some newer versions of xdvi) on unices.
	if !exists('g:Tex_ViewRule_dvi')
		return
	endif
	let viewer = g:Tex_ViewRule_dvi
	
	let dir = expand("%:p:h").'/'
	let curd = getcwd()
	exec 'cd '.expand("%:p:h")

	if Tex_GetMainFileName() != ''
		let mainfname = Tex_GetMainFileName()
	else
		let mainfname = expand("%:p:t:r")
	endif
	
	" inverse search tips taken from Dimitri Antoniou's tip and Benji Fisher's
	" tips on vim.sf.net (vim.sf.net tip #225)
	if has('win32')
		exec '!start '.viewer.' -s '.line('.').expand('%:p:t').' '.mainfname
	else
		exec '!'.viewer.' -name xdvi -sourceposition '.line('.').expand('%').' '.mainfname.'.dvi'
	end

	exec 'cd '.curd
endfunction

" }}}

" vim:fdm=marker:ts=4:sw=4
