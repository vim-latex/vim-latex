" ============================================================================
" 	     File: texviewer.vim
"      Author: Mikolaj Machowski
"     Created: Sun Jan 26 06:00 PM 2003
" Description: make a viewer for various purposes: \cite{, \ref{
"     License: Vim Charityware License
"              Part of vim-latexSuite: http://vim-latex.sourceforge.net
"         CVS: $Id$
" ============================================================================

if exists("g:Tex_Completion")
	call Tex_SetTexViewerMaps()
	finish
endif
let g:Tex_Completion = 1

" Tex_SetTexViewerMaps: sets maps for this ftplugin {{{
function! Tex_SetTexViewerMaps()
	inoremap <silent> <Plug>Tex_Completion <Esc>:call Tex_completion("default","text")<CR>
	if !hasmapto('<Plug>Tex_Completion', 'i')
		if has('gui_running')
			imap <buffer> <silent> <F9> <Plug>Tex_Completion
		else
			imap <buffer> <F9> <Plug>Tex_Completion
		endif
	endif
endfunction

" call this function the first time
call Tex_SetTexViewerMaps()
" }}}

command -nargs=1 TLook call <SID>Tex_look(<q-args>)
command -nargs=1 TLookAll call <SID>Tex_lookall(<q-args>)
command -nargs=1 TLookBib call <SID>Tex_lookbib(<q-args>)

function! s:Tex_lookall(what)
	call Tex_completion(a:what, "all")
endfunction

function! s:Tex_lookbib(what)
	call Tex_completion(a:what, "bib")
endfunction

function! s:Tex_look(what)
	call Tex_completion(a:what, "tex")
endfunction

if getcwd() != expand("%:p:h")
	let s:search_directory = expand("%:p:h") . '/'
else
	let s:search_directory = ''
endif

" CompletionVars: similar variables can be set in package files {{{
let g:Tex_completion_bibliographystyle = 'abbr,alpha,plain,unsrt'
let g:Tex_completion_addtocontents = 'lof}{,lot}{,toc}{'
let g:Tex_completion_addcontentsline = 'lof}{figure}{,lot}{table}{,toc}{chapter}{,toc}{part}{,'.
									\ 'toc}{section}{,toc}{subsection}{,toc}{paragraph}{,'.
									\ 'toc}{subparagraph}{'
" }}}

" Tex_completion: main function {{{
" Description:
"
function! Tex_completion(what, where)

	" Get info about current window and position of cursor in file
	let s:winnum = winnr()
	let s:pos = line('.').' | normal! '.virtcol('.').'|'
	let s:col = col('.')

	if a:where == "text"
		" What to do after <F9> depending on context
		let s:curfile = expand("%:p")
		let s:curline = strpart(getline('.'), col('.') - 40, 40)
		let s:prefix = matchstr(s:curline, '.*{\zs.\{-}$')
		" a command is of the type
		" \psfig[option=value]{figure=}
		" Thus
		" 	s:curline = '\psfig[option=value]{figure='
		" (with possibly some junk before \includegraphics)
		" from which we need to extract
		" 	s:type = 'psfig'
		" 	s:typeoption = '[option=value]'
		let pattern = '.*\\\(\w\{-}\)\(\[.\{-}\]\)\?{\(\S\+\)\?$'
		if s:curline =~ pattern
			let s:type = substitute(s:curline, pattern, '\1', 'e')
			let s:typeoption = substitute(s:curline, pattern, '\2', 'e')
			call Tex_Debug('s:type = '.s:type.', typeoption = '.s:typeoption, 'view')
		else
			unlet! s:type
			unlet! s:typeoption
		endif

		if exists("s:type") && s:type =~ 'ref'
			call Tex_Debug("silent! grep! '".Tex_EscapeForGrep('\label{'.s:prefix)."' ".s:search_directory.'*.tex', 'view')
			exec "silent! grep! '".Tex_EscapeForGrep('\label{'.s:prefix)."' ".s:search_directory.'*.tex'
			redraw!
			call <SID>Tex_c_window_setup()

		elseif exists("s:type") && s:type =~ 'cite'
			" grep! nothing % 
			" does _not_ clear the search history contrary to what the
			" help-docs say. This was expected. So use something improbable.
			" TODO: Is there a way to clear the search-history w/o making a
			"       useless, inefficient search?
			let s:prefix = matchstr(s:prefix, '\([^,]\+,\)\+\zs\([^,]\+\)\ze$')
			silent! grep! ____HIGHLY_IMPROBABLE___ %
			if g:Tex_RememberCiteSearch && exists('s:citeSearchHistory')
				call <SID>Tex_c_window_setup(s:citeSearchHistory)
			else
				call Tex_Debug('calling Tex_GrepForBibItems', 'bib')
				call Tex_GrepForBibItems(s:prefix)
				redraw!
				call <SID>Tex_c_window_setup()
			endif
			if g:Tex_RememberCiteSearch && &ft == 'qf'
				let _a = @a
				silent! normal! ggVG"ay
				let s:citeSearchHistory = @a
				let @a = _a
			endif

		elseif exists("s:type") && (s:type =~ 'includegraphics' || s:type == 'psfig') 
			let s:storehidefiles = g:explHideFiles
			let g:explHideFiles = '^\.,\.tex$,\.bib$,\.bbl$,\.zip$,\.gz$'
			exe 'silent! Sexplore '.s:search_directory.g:Tex_ImageDir
			call <SID>Tex_explore_window("includegraphics")
			
		elseif exists("s:type") && s:type == 'bibliography'
			let s:storehidefiles = g:explHideFiles
			let g:explHideFiles = '^\.,\.[^b]..$'
			exe 'silent! Sexplore '.s:search_directory
			call <SID>Tex_explore_window("bibliography")

		elseif exists("s:type") && s:type =~ 'include\(only\)\='
			let s:storehidefiles = g:explHideFiles
			let g:explHideFiles = '^\.,\.[^t]..$'
			exe 'silent! Sexplore '.s:search_directory
			call <SID>Tex_explore_window("includefile")

		elseif exists("s:type") && s:type == 'input'
			exe 'silent! Sexplore '.s:search_directory
			call <SID>Tex_explore_window("input")

		elseif exists('s:type') && exists("g:Tex_completion_".s:type)
			call <SID>CompleteName('plugin_'.s:type)

		elseif exists("s:type") && g:Tex_completion_explorer =~ ','.s:type
			exe 'silent! Sexplore '.s:search_directory
			call <SID>Tex_explore_window("plugintype")

		else
			let s:word = matchstr(s:curline, '\zs\k\{-}$')
			if s:word == ''
				if col('.') == strlen(getline('.'))
					startinsert!
					return
				else
					normal! l
					startinsert
					return
				endif
			endif
			call Tex_Debug("silent! grep! '\\<".s:word."' ".s:search_directory.'*.tex', 'view')
			exe "silent! grep! '\\<".s:word."' ".s:search_directory.'*.tex'
			call <SID>Tex_c_window_setup()

		endif
		
	elseif a:where == 'tex'
		" Process :TLook command
		exe "silent! grep! '".a:what."' ".s:search_directory.'*.tex'
		call <SID>Tex_c_window_setup()

	elseif a:where == 'bib'
		" Process :TLookBib command
		exe "silent! grep! '".a:what."' ".s:search_directory.'*.bib'
		exe "silent! grepadd! '".a:what."' ".s:search_directory.'*.bbl'
		call <SID>Tex_c_window_setup()

	elseif a:where == 'all'
		" Process :TLookAll command
		exe "silent! grep! '".a:what."' ".s:search_directory.'*'
		call <SID>Tex_c_window_setup()

	endif
endfunction " }}}
" Tex_c_window_setup: set maps and local settings for cwindow {{{
" Description: Set local maps jkJKq<cr> for cwindow. Also size and basic
" settings
"
function! s:Tex_c_window_setup(...)
	call Tex_Debug('+Tex_c_window_setup', 'view')
	cclose
	exe 'copen '. g:Tex_ViewerCwindowHeight
	" If called with an argument, it means we want to re-use some search
	" history from last time. Therefore, just paste it here and proceed.
	if a:0 == 1
		set modifiable
		% d _
		silent! 0put!=a:1
		$ d _
	endif
	setlocal nonumber
	setlocal nowrap

	let s:scrollOffVal = &scrolloff
	call <SID>UpdateViewerWindow()

	" If everything went well, then we should be situated in the quickfix
	" window. If there were problems, (no matches etc), then we will not be.
	" Therefore return.
	if &ft != 'qf'
		call Tex_Debug('not in quickfix window, quitting', 'view')
		return
	endif

    nnoremap <buffer> <silent> j j:call <SID>UpdateViewerWindow()<CR>
    nnoremap <buffer> <silent> k k:call <SID>UpdateViewerWindow()<CR>
    nnoremap <buffer> <silent> <up> <up>:call <SID>UpdateViewerWindow()<CR>
    nnoremap <buffer> <silent> <down> <down>:call <SID>UpdateViewerWindow()<CR>

	" Change behaviour of <cr> only for 'ref' and 'cite' context. 
	if exists("s:type") && s:type =~ 'ref'
		exec 'nnoremap <buffer> <silent> <cr> :set scrolloff='.s:scrollOffVal.'<CR>:silent! call <SID>CompleteName("ref")<CR>'

	elseif exists("s:type") && s:type =~ 'cite'
		exec 'nnoremap <buffer> <silent> <cr> :set scrolloff='.s:scrollOffVal.'<CR>:silent! call <SID>CompleteName("cite")<CR>'

	else
		" In other contexts jump to place described in cwindow and close small
		" windows
		exec 'nnoremap <buffer> <silent> <cr> :set scrolloff='.s:scrollOffVal.'<CR>:call <SID>GoToLocation()<cr>'

	endif

	nnoremap <buffer> <silent> J :wincmd j<cr><c-e>:wincmd k<cr>
	nnoremap <buffer> <silent> K :wincmd j<cr><c-y>:wincmd k<cr>

	exe 'nnoremap <buffer> <silent> q :set scrolloff='.s:scrollOffVal.'<CR>:call Tex_CloseSmallWindows()<cr>'

endfunction " }}}
" Tex_CloseSmallWindows: {{{
" Description:
"
function! Tex_CloseSmallWindows()
	exe s:winnum.' wincmd w'
	pclose!
	cclose
	exe s:pos
endfunction " }}}
" Tex_explore_window: settings for completion of filenames {{{
" Description: 
"
function! s:Tex_explore_window(type) 

	exe g:Tex_ExplorerHeight.' wincmd _'

	if a:type =~ 'includegraphics\|bibliography\|includefile'
		nnoremap <silent> <buffer> <cr> :silent! call <SID>CompleteName("expl_noext")<CR>
	elseif a:type =~ 'input\|plugintype'
		nnoremap <silent> <buffer> <cr> :silent! call <SID>CompleteName("expl_ext")<CR>
	endif

	nnoremap <silent> <buffer> q :wincmd q<cr>

endfunction " }}}
" UpdateViewerWindow: update error and preview window {{{
" Description: Usually quickfix engine takes care about most of these things
" but we discard it for better control of events.
"
function! s:UpdateViewerWindow()
	 call Tex_Debug('+UpdateViewerWindow', 'view')

	let viewfile = matchstr(getline('.'), '^\f*\ze|\d')
	let viewline = matchstr(getline('.'), '|\zs\d\+\ze|')

	" Hilight current line in cwindow
	" Normally hightlighting is done with quickfix engine but we use something
	" different and have to do it separately
	syntax clear
	runtime syntax/qf.vim
	exe 'syn match vTodo /\%'. line('.') .'l.*/'
	hi link vTodo Todo

	" Close preview window and open it again in new place
    pclose
	exe 'silent! bot pedit +'.viewline.' '.viewfile

	" Vanilla 6.1 has bug. This additional setting of cwindow height prevents
	" resizing of this window
	exe g:Tex_ViewerCwindowHeight.' wincmd _'
	
	" Handle situation if there is no item beginning with s:prefix.
	" Unfortunately, because we know it late we have to close everything and
	" return as in complete process 
	if v:errmsg =~ 'E32\>'
		exe s:winnum.' wincmd w'
		pclose!
		cclose
		if exists("s:prefix")
			echomsg 'No bibkey, label or word beginning with "'.s:prefix.'"'
		endif
		if col('.') == strlen(getline('.'))
			startinsert!
		else
			normal! l
			startinsert
		endif
		let v:errmsg = ''
		call Tex_Debug('UpdateViewerWindow: got error E32, no matches found, quitting', 'view')
		return 0
	endif

	" Move to preview window. Really is it under cwindow?
	wincmd j

	" Settings of preview window
	exe g:Tex_ViewerPreviewHeight.' wincmd _'
	setlocal foldlevel=10

	if exists('s:type') && s:type =~ 'cite'
		" In cite context place bibkey at the top of preview window.
		setlocal scrolloff=0
		normal! zt
	else
		" In other contexts in the middle. Highlight this line?
		setlocal scrolloff=100
		normal! z.
	endif

	" Return to cwindow
	wincmd p

endfunction " }}}
" CompleteName: complete/insert name for current item {{{
" Description: handle completion of items depending on current context
"
function! s:CompleteName(type)

	if a:type =~ 'cite'
		if getline('.') =~ '\\bibitem{'
			let bibkey = matchstr(getline('.'), '\\bibitem{\zs.\{-}\ze}')
		else
			let bibkey = matchstr(getline('.'), '{\zs.\{-}\ze,')
		endif
		let completeword = strpart(bibkey, strlen(s:prefix))

	elseif a:type =~ 'ref'
		let label = matchstr(getline('.'), '\\label{\zs.\{-}\ze}')
		let completeword = strpart(label, strlen(s:prefix))

	elseif a:type =~ 'expl_ext\|expl_noext'
		let line = substitute(strpart(getline('.'),0,b:maxFileLen),'\s\+$','','')
		if isdirectory(b:completePath.line)
			call EditEntry("", "edit")
			exe 'nnoremap <silent> <buffer> <cr> :silent! call <SID>CompleteName("'.a:type.'")<CR>'
			nnoremap <silent> <buffer> q :wincmd q<cr>
			return

		else
			if a:type == 'expl_noext'
				let ifile = substitute(line, '\..\{-}$', '', '')
			else
				let ifile = line
			endif
			let filename = b:completePath.ifile
			
			if g:Tex_ImageDir != '' && s:type =~ 'includegraphics'
				let imagedir = s:curfile . g:Tex_ImageDir
				let completeword = <SID>Tex_RelPath(filename, imagedir)
			else
				let completeword = <SID>Tex_RelPath(filename, s:curfile)
			endif

			let g:explHideFiles = s:storehidefiles
		endif

	elseif a:type =~ '^plugin_'
		let type = substitute(a:type, '^plugin_', '', '')
		let completeword = <SID>Tex_DoCompletion(type)
		
	endif

	" Return to proper place in main window, close small windows
	if s:type =~ 'cite\|ref' 
		exe s:winnum.' wincmd w'
		pclose!
		cclose
	elseif a:type =~ 'expl_ext\|expl_noext'
		q
	endif

	exe s:pos


	" Complete word, check if add closing }
	exe 'normal! a'.completeword."\<Esc>"

	if getline('.')[col('.')-1] !~ '{' && getline('.')[col('.')] !~ '}'
		exe "normal! a}\<Esc>"
	endif

	" Return to Insert mode
	if col('.') == strlen(getline('.'))
		startinsert!

	else
		normal! l
		startinsert

	endif

endfunction " }}}
" GoToLocation: Go to chosen location {{{
" Description: Get number of current line and go to this number
"
function! s:GoToLocation()

	pclose!
	exe 'cc ' . line('.')
	cclose

endfunction " }}}

" Bibliography specific functions
" Tex_GrepForBibItems: grep main filename for bib items {{{
" Description: 
function! Tex_GrepForBibItems(prefix)
	let mainfname = Tex_GetMainFileName(':p:r')

	let toquit = 0
	if bufnr('%') != bufnr(mainfname)
		exec 'split '.mainfname
		let toquit = 1
	endif

	let _path = &path
	let _suffixesadd = &suffixesadd

	let &path = '.,'.g:Tex_BIBINPUTS
	let &suffixesadd = '.tex'

	let pos = line('.').'| normal! '.virtcol('.').'|'
	let foundCiteFile = Tex_ScanFileForCite(a:prefix)
	exec pos

	let &path = _path
	let &suffixesadd = _suffixesadd

	if foundCiteFile
		if toquit
			q
		endif
		return
	endif
endfunction " }}}
" Tex_ScanFileForCite: search for \bibitem's in .bib or .bbl or tex files {{{
" Description: 
" Search for bibliographic entries in the presently edited file in the
" following manner:
" 1. First see if the file has a \bibliography command.
"    If YES:
"    	1. If a .bib file corresponding to the \bibliography command can be
"    	   found, then search for '@.*'.a:prefix inside it.
"    	2. Otherwise, if a .bbl file corresponding to the \bibliography command
"    	   can be found, then search for '\bibitem'.a:prefix inside it.
" 2. Next see if the file has a \thebibliography environment
"    If YES:
"    	1. Search for '\bibitem'.a:prefix in this file.
"
" If neither a \bibliography or \begin{thebibliography} are found, then repeat
" steps 1 and 2 for every file \input'ed into this file. Abort any searching
" as soon as the first \bibliography or \begin{thebibliography} is found.
function! Tex_ScanFileForCite(prefix)
	call Tex_Debug('searching for bibkeys in '.bufname('%').' (buffer #'.bufnr('%').')', 'bib')
	let presBufNum = bufnr('%')

	let foundCiteFile = 0
	" First find out if this file has a \bibliography command in it. If so,
	" assume that this is the only file in the project which defines a
	" bibliography.
	if search('\\bibliography{', 'w')
		call Tex_Debug('found bibliography command in '.bufname('%'), 'bib')
		" convey that we have found a bibliography command. we do not need to
		" proceed any further.
		let foundCiteFile = 1

		" extract the bibliography filenames from the command.
		let bibnames = matchstr(getline('.'), '\\bibliography{\zs.\{-}\ze}')
		let bibnames = substitute(bibnames, '\s', '', 'g')

		call Tex_Debug('trying to search through ['.bibnames.']', 'bib')
		
		let i = 1
		while Tex_Strntok(bibnames, ',', i) != ''
			" first try to find if a .bib file exists. If so do not search in
			" the corresponding .bbl file. (because the .bbl file will most
			" probly be generated automatically from the .bib file with
			" bibtex).
			
			" split a new window so we do not screw with the current buffer.
			split
			let thisbufnum = bufnr('%')
			call Tex_Debug('silent! find '.Tex_Strntok(bibnames, ',', i).'.bib', 'bib')
			exec 'silent! find '.Tex_Strntok(bibnames, ',', i).'.bib'
			if bufnr('%') != thisbufnum
				call Tex_Debug('finding .bib file ['.bufname('%').']', 'bib')
				lcd %:p:h
				" use the appropriate syntax for the .bib file.
				exec "silent! grepadd '".Tex_EscapeForGrep('@.*{'.a:prefix)."' %"
			else
				let thisbufnum = bufnr('%')
				exec 'silent! find '.Tex_Strntok(bibnames, ',', i).'.bbl'
				call Tex_Debug('now in bufnum#'.bufnr('%'), 'bib')
				if bufnr('%') != thisbufnum
					call Tex_Debug('finding .bbl file ['.bufname('.').']', 'bib')
					lcd %:p:h
					exec "silent! grepadd '".Tex_EscapeForGrep('\bibitem{'.a:prefix)."' %"
				endif
			endif
			" close the newly opened window
			q

			let i = i + 1
		endwhile

		if foundCiteFile
			return 1
		endif
	endif

	" If we have a thebibliography environment, then again assume that this is
	" the only file which defines the bib-keys. Aand convey this information
	" upwards by returning 1.
	if search('^\s*\\begin{thebibliography}', 'w')
		call Tex_Debug('got a thebibliography environment in '.bufname('%'), 'bib')
		
		let foundCiteFile = 1

		split
		lcd %:p:h
		exec "silent! grepadd ".Tex_EscapeForGrep('\bibitem{'.a:prefix)."' %")
		q
		
		return 1
	endif

	" If we have not found any \bibliography or \thebibliography environment
	" in this file, search for these environments in all the files which this
	" file includes.
	exec 0
	let wrap = 'w'
	while search('^\s*\\\(input\|include\)', wrap)
		let wrap = 'W'

		let filename = matchstr(getline('.'), '\\\(input\|include\){\zs.\{-}\ze}')

		split
		let thisbufnum = bufnr('%')

		exec 'silent! find '.filename
		if bufnr('%') != thisbufnum
			" DANGER! recursive call.
			call Tex_Debug('scanning recursively in ['.bufname('%').']', 'bib')
			let foundCiteFile = Tex_ScanFileForCite(a:prefix)
		endif
		q

		if foundCiteFile
			return 1
		endif
	endwhile

	return 0
endfunction " }}}

" PromptForCompletion: prompts for a completion {{{
" Description: 
function! s:PromptForCompletion(texcommand,ask)

	let common_completion_prompt = 
				\ Tex_CreatePrompt(g:Tex_completion_{a:texcommand}, 2, ',') . "\n" .
				\ 'Enter number or completion: '

	let inp = input(a:ask."\n".common_completion_prompt)
	if inp =~ '^[0-9]\+$'
		let completion = Tex_Strntok(g:Tex_completion_{a:texcommand}, ',', inp)
	else
		let completion = inp
	endif

	return completion
endfunction " }}}
" Tex_DoCompletion: fast insertion of completion {{{
" Description:
"
function! s:Tex_DoCompletion(texcommand)
	let completion = <SID>PromptForCompletion(a:texcommand,'Choose a completion to insert: ')
	if completion != ''
		return completion
	else
		return ''
	endif
endfunction " }}}

" Tex_Common: common part of strings {{{
function! s:Tex_Common(path1, path2)
	" Assume the caller handles 'ignorecase'
	if a:path1 == a:path2
		return a:path1
	endif
	let n = 0
	while a:path1[n] == a:path2[n]
		let n = n+1
	endwhile
	return strpart(a:path1, 0, n)
endfunction " }}}
" Tex_RelPath: ultimate file name {{{
function! s:Tex_RelPath(explfilename,texfilename)
	let path1 = a:explfilename
	let path2 = a:texfilename
	if has("win32") || has("win16") || has("dos32") || has("dos16")
		let path1 = substitute(path1, '\\', '/', 'ge')
		let path2 = substitute(path2, '\\', '/', 'ge')
	endif
	let n = matchend(<SID>Tex_Common(path1, path2), '.*/')
	let path1 = strpart(path1, n)
	let path2 = strpart(path2, n)
	if path2 !~ '/'
		let subrelpath = ''
	else
		let subrelpath = substitute(path2, '[^/]\{-}/', '../', 'ge')
		let subrelpath = substitute(subrelpath, '[^/]*$', '', 'ge')
	endif
	let relpath = subrelpath.path1
	if has("win32") || has("win16") || has("dos32") || has("dos16")
		let relpath = substitute(relpath, '/', "\\", 'ge')
	endif
	return relpath
endfunction " }}}

com! -nargs=0 TClearCiteHist unlet! s:citeSearchHistory

" this statement has to be at the end.
let s:doneOnce = 1

" vim:fdm=marker:nowrap:noet:ff=unix:ts=4:sw=4
