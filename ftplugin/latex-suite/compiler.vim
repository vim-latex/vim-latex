"=============================================================================
" 	     File: compiler.vim
"      Author: Srinath Avadhanula
"     Created: Tue Apr 23 05:00 PM 2002 PST
" Last Change: Tue Nov 26 10:00 PM 2002 PST
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
			let &l:makeprg = escape(g:Tex_CompileRule_{target}, g:Tex_EscapeChars)
		elseif a:type == 'View'
			exec 'let s:viewer = g:Tex_'.a:type.'Rule_'.target
		endif
		let s:target = target
	else
		let curd = getcwd()
		exe 'cd '.expand('%:p:h')
		if glob('makefile*') == '' && glob('Makefile*') == ''
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

	" close any preview windows left open.
	pclose!

	" if a makefile exists, just use the make utility
	if glob('makefile') != '' || glob('Makefile') != ''
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
		exec 'make '.mainfname
	else
		" otherwise just use this file.
		let mainfname = expand("%:t:r")
		exec 'make '.mainfname
	endif

	let winnum = winnr()

	" close the quickfix window before trying to open it again, otherwise
	" whether or not we end up in the quickfix window after the :cwindow
	" command is not fixed.
	cclose
	cwindow
	" if we moved to a different window, then it means we had some errors.
	if winnum != winnr() && glob(mainfname.'.log') != ''
		call UpdatePreviewWindow(mainfname)
		exe 'nnoremap <buffer> <silent> j j:call UpdatePreviewWindow("'.mainfname.'")<CR>'
		exe 'nnoremap <buffer> <silent> k k:call UpdatePreviewWindow("'.mainfname.'")<CR>'
		exe 'nnoremap <buffer> <silent> <up> <up>:call UpdatePreviewWindow("'.mainfname.'")<CR>'
		exe 'nnoremap <buffer> <silent> <down> <down>:call UpdatePreviewWindow("'.mainfname.'")<CR>'
		exe 'nnoremap <buffer> <silent> <enter> <enter>:call GotoErrorLocation("'.mainfname.'", '.winnum.')<CR>'

		setlocal nowrap

		" resize the window to just fit in with the number of lines.
		exec ( line('$') < 4 ? line('$') : 4 ).' wincmd _'
		call GotoErrorLocation(mainfname, winnum)
	endif

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
		exec '!start' s:viewer mainfname . '.' . s:target
	elseif has('macunix')
		if strlen(s:viewer)
			let s:viewer = '-a ' . s:viewer
		endif
		execute '!open' s:viewer mainfname . '.' . s:target
	else
		" taken from Dimitri Antoniou's tip on vim.sf.net (tip #225).
		" slight change to actually use the current servername instead of
		" hardcocing it as xdvi.
		" Using an option for specifying the editor in the command line
		" because that seems to not work on older bash'es.
		if s:target == 'dvi'
			if exists('g:Tex_UseEditorSettingInDVIViewer') &&
						\ g:Tex_UseEditorSettingInDVIViewer == 1
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
" PositionPreviewWindow: positions the preview window correctly. {{{
" Description: 
" 	The purpose of this function is to count the number of times an error
" 	occurs on the same line. or in other words, if the current line is
" 	something like |10 error|, then we want to count the number of
" 	lines in the quickfix window before this line which also contain lines
" 	like |10 error|. 
function! PositionPreviewWindow(filename)

	if getline('.') !~ '|\d\+ \(error\|warning\)|'
		if !search('|\d\+ \(error\|warning\)|')
			pclose!
			return
		endif
	endif

	" extract the error pattern (something like '|10 error|') on the current
	" line.
	let errpat = matchstr(getline('.'), '\zs|\d\+ \(error\|warning\)|\ze')
	" extract the line number from the error pattern.
	let linenum = matchstr(getline('.'), '|\zs\d\+\ze \(error\|warning\)|')

	" if we are on an error, then count the number of lines before this in the
	" quickfix window with an error on the same line.
	if errpat =~ 'error'
		" our location in the quick fix window.
		let errline = line('.')

		" goto the beginning of the quickfix window and begin counting the lines
		" which show an error on the same line.
		0
		let numrep = 0
		while 1
			" if we are on the same kind of error line, then means we have another
			" line containing the same error pattern.
			if getline('.') =~ errpat
				let numrep = numrep + 1
				normal! 0
			endif
			" if we have reached the original location in the quick fix window,
			" then break.
			if line('.') == errline
				break
			else
				" otherwise, search for the next line which contains the same
				" error pattern again.
				call search(errpat, 'W')
			endif
		endwhile
	endif

	if getline('.') =~ '|\d\+ warning|'
		let searchpat = escape(matchstr(getline('.'), '|\d\+ warning|\s*\zs.*'), '\ ')
	else
		let searchpat = 'l.'.linenum
	endif

	exec 'bot pedit +/'.searchpat.'/ '.a:filename.'.log'
	" TODO: This is not robust enough. Check that a wincmd j actually takes
	" us to the preview window. Moreover, the resizing should be done only the
	" first time around.
	wincmd j
	if searchpat =~ 'l.\d\+' && numrep > 1
		while numrep > 1
			call search(searchpat, 'W')
			normal! z.
			let numrep = numrep - 1
		endwhile
	endif

endfunction " }}}
" UpdatePreviewWindow: updates the view of the log file {{{
" Description: 
"       This function should be called when focus is in a quickfix window.
"       It opens the log file in a preview window and makes it display that
"       part of the log file which corresponds to the error which the user is
"       currently on in the quickfix window. Control returns to the quickfix
"       window when the function returns. 
"
function! UpdatePreviewWindow(filename)
	call PositionPreviewWindow(a:filename)
	6 wincmd _
	wincmd k
endfunction " }}}
" GotoErrorLocation: goes to the correct location of error in the tex file {{{
" Description: 
"   This function should be called when focus is in a quickfix window. This
"   function will first open the preview window of the log file (if it is not
"   already open), position the display of the preview to coincide with the
"   current error under the cursor and then take the user to the file in
"   which this error has occured. 
"
"   The position is both the correct line number and the column number.
"
" TODO: When there are multiple errors on the same line, this only takes you
"       to the very first error every time. 
function! GotoErrorLocation(filename, winnum)

	let linenum = matchstr(getline('.'), '|\zs\d\+\ze \(warning\|error\)|')
	call PositionPreviewWindow(a:filename)

	if getline('.') =~ 'l.\d\+'

		let brokenline = matchstr(getline('.'), 'l.'.linenum.' \zs.*\ze')
		" If the line is of the form
		" 	l.10 ...and then there was some error
		" it means (most probably) that only part of the erroneous line is
		" shown. In this case, finding the length of the broken line is not
		" correct.  Instead goto the beginning of the line and search forward
		" for the part which is displayed and then go to its end.
		if brokenline =~ '^\M...'
			let partline = matchstr(brokenline, '^\M...\m\zs.*')
			let normcmd = "0/\\V".escape(partline, "\\")."/e+1\<CR>"
		else
			let column = strlen(brokenline)
			let normcmd = column.'|'
		endif

	elseif getline('.') =~ 'LaTeX Warning: \(Citation\|Reference\) `.*'

		let ref = matchstr(getline('.'), "LaTeX Warning: \\(Citation\\|Reference\\) `\\zs[^']\\+\\ze'")
		let normcmd = '0/'.ref."\<CR>"

	else

		let normcmd = '0'

	endif

	exec a:winnum.' wincmd w'
	exec 'silent! '.linenum.' | normal! '.normcmd

endfunction " }}}

" vim:fdm=marker:ts=4:sw=4
