" ============================================================================
" 	     File: texviewer.vim
"      Author: Mikolaj Machowski
"     Created: Sun Jan 26 06:00 PM 2003
" Description: make a viewer for various purposes: \cite{, \ref{
"     License: Vim Charityware License
"              Part of vim-latexSuite: http://vim-latex.sourceforge.net
" ============================================================================

if exists("g:Tex_Viewer")
	finish
endif

inoremap <silent> <Plug>Tex_Viewer <Esc>:call Tex_viewer("default","text")<CR>

if !hasmapto('<Plug>Tex_Viewer', 'i')
	imap <buffer> <silent> <buffer> <F9> <Plug>Tex_Viewer
endif

command -nargs=1 TLook call <SID>Tex_look(<q-args>)
command -nargs=1 TLookAll call <SID>Tex_lookall(<q-args>)
command -nargs=1 TLookBib call <SID>Tex_lookbib(<q-args>)

function! s:Tex_lookall(what)
	call Tex_viewer(a:what, "all")
endfunction

function! s:Tex_lookbib(what)
	call Tex_viewer(a:what, "bib")
endfunction

function! s:Tex_look(what)
	call Tex_viewer(a:what, "tex")
endfunction

if getcwd() != expand("%:p:h")
	let s:search_directory = expand("%:h") . '/'
else
	let s:search_directory = ''
endif

" Tex_viewer: main function {{{
" Description:
"
function! Tex_viewer(what, where)

	" Get info about current window and position of cursor in file
	let s:winnum = winnr()
	let s:pos = line('.').' | normal! '.virtcol('.').'|'
	let s:col = col('.')

	if a:where == "text"
		" What to do after <F9> depending on context
		let s:curline = strpart(getline('.'), col('.') - 20, 20)
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

		else
			let s:word = matchstr(s:curline, '\zs\k\{-}$')
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
	if exists("s:type") && s:type =~ 'ref\|cite'
		nnoremap <buffer> <silent> <cr> :call <SID>CompleteName()<CR>

	else
		" In other contexts jump to place described in cwindow and close small
		" windows
		nnoremap <buffer> <silent> <cr> :call <SID>GoToLocation()<cr>

	endif

	nnoremap <buffer> <silent> J :wincmd j<cr><c-e>:wincmd k<cr>
	nnoremap <buffer> <silent> K :wincmd j<cr><c-y>:wincmd k<cr>

	exe 'nnoremap <buffer> <silent> q :'.s:winnum.' wincmd w<cr>:pclose!<cr>:cclose<cr>'

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
function! s:CompleteName()

	if s:type =~ 'cite'
		if getline('.') =~ '\\bibitem{'
			let bibkey = matchstr(getline('.'), '\\bibitem{\zs.\{-}\ze}')
		else
			let bibkey = matchstr(getline('.'), '{\zs.\{-}\ze,')
		endif
		exe s:winnum.' wincmd w'
		pclose!
		cclose
		exe s:pos
		let bibkey2 = strpart(bibkey, strlen(s:prefix))
		exe 'normal! a'.bibkey2."}\<Esc>"

	elseif s:type =~ 'ref'
		let s:label = matchstr(getline('.'), '\\label{\zs.\{-}\ze}')
		exe s:winnum.' wincmd w'
		pclose!
		cclose
		exe s:pos
		let label2 = strpart(s:label, strlen(s:prefix))
		exe 'normal! a'.label2."}\<Esc>"
		
	endif

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

let g:Tex_Viewer = 1
" this statement has to be at the end.
let s:doneOnce = 1

" vim:fdm=marker:nowrap:noet:ff=unix
