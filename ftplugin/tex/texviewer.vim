" ============================================================================
" 	     File: texviewer.vim
"      Author: Mikolaj Machowski
"     Created: Sun Jan 26 06:00 PM 2003
" Description: make a viewer for various purposes: \cite{, \ref{
"     License: Vim Charityware License
"              Part of vim-latexSuite: http://vim-latex.sourceforge.net
" ============================================================================

if exists("g:Tex_Completion")
	finish
endif

inoremap <silent> <Plug>Tex_Completion <Esc>:call Tex_completion("default","text")<CR>

if !hasmapto('<Plug>Tex_Completion', 'i')
	imap <buffer> <silent> <F9> <Plug>Tex_Completion
endif

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
	let s:search_directory = expand("%:h") . '/'
else
	let s:search_directory = ''
endif

" Tex_viewer: main function {{{
" Description:
"
function! Tex_completion(what, where)

	" Get info about current window and position of cursor in file
	let s:winnum = winnr()
	let s:pos = line('.').' | normal! '.virtcol('.').'|'
	let s:col = col('.')

	if a:where == "text"
		" What to do after <F9> depending on context
		let s:curline = strpart(getline('.'), col('.') - 40, 40)
		let s:prefix = matchstr(s:curline, '{\zs.\{-}$')
		let s:type = matchstr(s:curline, '\\\zs.\{-}\ze{.\{-}$')

		if exists("s:type") && s:type =~ 'ref'
			exe 'silent! grep! "\\label{'.s:prefix.'" '.s:search_directory.'*.tex'
			call <SID>Tex_c_window_setup()

		elseif exists("s:type") && s:type =~ 'cite'
			exe 'silent! grep! "@.*{'.s:prefix.'" '.s:search_directory.'*.bib'
			exe 'silent! grepadd! "bibitem{'.s:prefix.'" '.s:search_directory.'*.bbl'
			exe 'silent! grepadd! "bibitem{'.s:prefix.'" %'
			call <SID>Tex_c_window_setup()

		elseif exists("s:type") && s:type =~ 'includegraphics'
			let s:storehidefiles = g:explHideFiles
			let g:explHideFiles = '^\.,\.tex$,\.bib$,\.bbl$,\.zip$,\.gz$$'
			let s:curfile = expand("%:p")
			exe 'silent! Sexplore '.s:search_directory.g:Tex_ImageDir
			call <SID>Tex_explore_window("includegraphics")
			
		elseif exists("s:type") && s:type =~ 'bibliography'
			let s:storehidefiles = g:explHideFiles
			let g:explHideFiles = '^\.,\.tex$,\.pdf$,\.eps$,\.zip$,\.gz$'
			let s:curfile = expand("%:p")
			exe 'silent! Sexplore '.s:search_directory
			call <SID>Tex_explore_window("bibliography")

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
			exe 'silent! grep! "\<' . s:word . '" '.s:search_directory.'*.tex'
			call <SID>Tex_c_window_setup()

		endif
		
	elseif a:where == 'tex'
		" Process :TLook command
		exe 'silent! grep! "'.a:what.'" '.s:search_directory.'*.tex'
		call <SID>Tex_c_window_setup()

	elseif a:where == 'bib'
		" Process :TLookBib command
		exe 'silent! grep! "'.a:what.'" '.s:search_directory.'*.bib'
		exe 'silent! grepadd! "'.a:what.'" '.s:search_directory.'*.bbl'
		call <SID>Tex_c_window_setup()

	elseif a:where == "all"
		" Process :TLookAll command
		exe 'silent! grep! "'.a:what.'" '.s:search_directory.'*'
		call <SID>Tex_c_window_setup()

	endif
endfunction " }}}
" Tex_c_window_setup: set maps and local settings for cwindow {{{
" Description: Set local maps jkJKq<cr> for cwindow. Also size and basic
" settings
"
function! s:Tex_c_window_setup()

	cclose
	exe 'copen '. g:Tex_ViewerCwindowHeight
	setlocal nonumber
	setlocal nowrap

	call <SID>UpdateViewerWindow()

    nnoremap <buffer> <silent> j j:call <SID>UpdateViewerWindow()<CR>
    nnoremap <buffer> <silent> k k:call <SID>UpdateViewerWindow()<CR>
    nnoremap <buffer> <silent> <up> <up>:call <SID>UpdateViewerWindow()<CR>
    nnoremap <buffer> <silent> <down> <down>:call <SID>UpdateViewerWindow()<CR>

	" Change behaviour of <cr> only for 'ref' and 'cite' context. 
	if exists("s:type") && s:type =~ 'ref'
		nnoremap <buffer> <silent> <cr> :silent! call <SID>CompleteName("ref")<CR>

	elseif exists("s:type") && s:type =~ 'cite'
		nnoremap <buffer> <silent> <cr> :silent! call <SID>CompleteName("cite")<CR>

	else
		" In other contexts jump to place described in cwindow and close small
		" windows
		nnoremap <buffer> <silent> <cr> :call <SID>GoToLocation()<cr>

	endif

	nnoremap <buffer> <silent> J :wincmd j<cr><c-e>:wincmd k<cr>
	nnoremap <buffer> <silent> K :wincmd j<cr><c-y>:wincmd k<cr>

	exe 'nnoremap <buffer> <silent> q :'.s:winnum.' wincmd w<cr>:pclose!<cr>:cclose<cr>'

endfunction " }}}
" Tex_explore_window: settings for completion of filenames {{{
" Description: 
"
function! s:Tex_explore_window(type) 

	exe g:Tex_ExplorerHeight.' wincmd _'
	if a:type == 'includegraphics'
		nnoremap <silent> <buffer> <cr> :silent! call <SID>CompleteName("includegraphics")<CR>
	elseif a:type == 'bibliography'
		nnoremap <silent> <buffer> <cr> :silent! call <SID>CompleteName("bibliography")<CR>
	endif

endfunction " }}}
" UpdateViewerWindow: update error and preview window {{{
" Description: Usually quickfix engine takes care about most of these things
" but we discard it for better control of events.
"
function! s:UpdateViewerWindow()

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
		return 0
	endif

	" Move to preview window. Really is it under cwindow?
	wincmd j

	" Settings of preview window
	exe g:Tex_ViewerPreviewHeight.' wincmd _'
	setlocal foldlevel=10

	if s:type =~ 'cite'
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

	elseif a:type =~ 'includegraphics\|bibliography'
		let line = substitute(strpart(getline('.'),0,b:maxFileLen),'\s\+$','','')
		if isdirectory(b:completePath.line)
			call EditEntry("", "edit")
			exe 'nnoremap <silent> <buffer> <cr> :silent! call <SID>CompleteName("'.a:type.'")<CR>'
			let g:explHideFiles = s:storehidefiles
			return

		else
			let ifile = substitute(line, '\..\{-}$', '', '')
			let filename = b:completePath.ifile
			
			if g:Tex_ImageDir != '' && a:type =~ 'includegraphics'
				let imagedir = s:curfile . g:Tex_ImageDir
				let completeword = <SID>Tex_RelPath(filename, imagedir)
			else
				let completeword = <SID>Tex_RelPath(filename, s:curfile)
			endif

			let g:explHideFiles = s:storehidefiles
		endif
		
	endif

	" Return to proper place in main window, close small windows
	if s:type =~ 'cite\|ref' 
		exe s:winnum.' wincmd w'
		pclose!
		cclose
		exe s:pos
	elseif s:type =~ 'includegraphics\|bibliography'
		wincmd q
		exe s:pos
	endif

	" Complete word, check if add closing }
	exe 'normal! a'.completeword."\<Esc>"

	if getline('.')[col('.')] != '}'
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

	exe 'cc ' . line('.')
	pclose!
	cclose

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
	if has("win32")
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
	return relpath
endfunction " }}}

let g:Tex_Completion = 1
" this statement has to be at the end.
let s:doneOnce = 1

" vim:fdm=marker:nowrap:noet:ff=unix
