" ==============================================================================
" Author: Carl Mueller
" 		  (incorporated into latex-suite by Srinath Avadhanula)
" Last Change: Sat Nov 16 06:00 PM 2002 PST
" Desciption:
" ============================================================================== 

" ============================================================================== 
" Boldface: Mapping <M-b> to insert \mathbf{} {{{
" Insert Mode:
" Typing <M-b> after a character capitalizes it and encloses it in \mathbf{}
" Visual Mode:
" Encloses the selected portion in \mathbf{}
inoremap <buffer> <silent> <M-b> <Left>\mathbf{<Right>}<Esc>hvUla
vnoremap <buffer> <silent> <M-b> <C-C>`>a}<Esc>`<i\mathbf{<Esc>
" }}}
" ============================================================================== 
" MathCal:  Mapping <M-c> to insert \mathcal{} or \cite{} {{{
" Insert Mode:
" 1. If the previous character is a letter or number, then capitalize it and
" 	 enclose it in \mathcal{}
" 2. otherwise insert \cite{«»}«»
" Visual Mode:
" 1. Enclose selection in \mathcal{}
inoremap <buffer> <silent> <M-c> <C-R>=<SID>MathCal()<CR>

if !exists('*s:MathCal')
	function! s:MathCal()
		let line = getline(line("."))
		let char = line[col(".")-2]

		if char =~ '[a-zA-Z0-9]'
			return "\<BS>".'\mathcal{'.toupper(char).'}'
		else
			return IMAP_PutTextWithMovement('\cite{«»}«»')
		endif
	endfunction
endif

vnoremap <buffer> <silent> <M-c> <C-C>`>a}<Esc>`<i\mathcal{<Esc>

" }}}
" ==============================================================================
" LeftRight: Function for inserting \left and \right in front of bracket chars
" in various ways using <M-l>. If not possible, insert \label{«»}«»
" {{{
" 
inoremap <buffer> <silent> <M-l> <C-r>=<SID>LeftRight()<CR>
nnoremap <buffer> <silent> <M-l> :call <SID>PutLeftRight()<CR>

if !exists('*s:LeftRight')
	" LeftRight: maps <M-l> in insert mode. {{{
	" This is a polymorphic function, which maps the behaviour of <M-l> in the
	" following way:
	" If the character before typing <M-l> is one of '([{|<q', then do the
	" following:
	" 	1. (<M-l>		\left(«»\right«»
	" 	    	similarly for [, |
	" 	   {<M-l>		\left\{«»\right\}«»
	" 	2. <<M-l>		\langle«»\rangle«»
	" 	3. q<M-l>		\lefteqn{«»}«»
	" otherwise insert  \label{«»}«»
	function! s:LeftRight()
		let line = getline(line("."))
		let char = line[col(".")-2]
		let previous = line[col(".")-3]

		let matchedbrackets = '()[]{}||'
		if char =~ '(\|\[\|{\||'
			let add = ''
			if char =~ '{'
				let add = "\\"
			endif
			let rhs = matchstr(matchedbrackets, char.'\zs.\ze')
			return "\<BS>".IMAP_PutTextWithMovement('\left'.add.char.'«»\right'.add.rhs.'«»')
		elseif char == '<'
			return "\<BS>".IMAP_PutTextWithMovement('langle«»\rangle«»')
		elseif char == 'q'
			return "\<BS>".IMAP_PutTextWithMovement('\lefteqn{«»}«»')
		else
			return '\label{«»}«»'
		endif
	endfunction " }}}
	" PutLeftRight: maps <M-l> in normal mode {{{
	" Put \left...\right in front of the matched brackets.
	function! s:PutLeftRight()
		let previous = getline(line("."))[col(".") - 2]
		let char = getline(line("."))[col(".") - 1]
		if previous == '\'
			if char == '{'
				exe "normal ileft\\\<Esc>l%iright\\\<Esc>l%"
			elseif char == '}'
				exe "normal iright\\\<Esc>l%ileft\\\<Esc>l%"
			endif
		elseif char =~ '\[\|('
			exe "normal i\\left\<Esc>l%i\\right\<Esc>l%"
		elseif char =~ '\]\|)'
			exe "normal i\\right\<Esc>l%i\\left\<Esc>l%"
		endif
	endfunction " }}}
endif

" }}}
" ==============================================================================

" vim:fdm=marker
