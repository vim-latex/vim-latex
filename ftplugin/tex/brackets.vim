" ==============================================================================
" Author: Carl Mueller
" 		  (incorporated into latex-suite by Srinath Avadhanula)
" Last Change: Fri Dec 06 05:00 PM 2002 PST
" Desciption:
" 	This ftplugin provides the following maps:
" . <M-b> encloses the previous character in \mathbf{}
" . <M-c> is polymorphic as follows:
"     Insert mode:
"     1. If the previous character is a letter or number, then capitalize it and
"        enclose it in \mathcal{}
"     2. otherwise insert \cite{}
"     Visual Mode:
"     1. Enclose selection in \mathcal{}
" . <M-l> is also polymorphic as follows:
"     If the character before typing <M-l> is one of '([{|<q', then do the
"     following:
"       1. (<M-l>       \left(\right
"               similarly for [, |
"          {<M-l>       \left\{\right\}
"       2. <<M-l>       \langle\rangle
"       3. q<M-l>       \lefteqn{}
"     otherwise insert  \label{}
" 
" These functions make it extremeley easy to do all the \left \right stuff in
" latex.
"
" NOTE: The insert mode maps are created only if maps are no maps already to
" the relevant functions Tex_MathBF, Tex_MathCal and Tex_LeftRight. This is to
" enable people who might need the alt keys for typing to use some other
" keypress to trigger the same behavior. In order to use some other key, (say
" <C-c>) to use Tex_MathCal(), do the following
"
" 	inoremap <buffer> <silent> <C-c> <C-r>=Tex_MathCal()<CR>
"
" ============================================================================== 

" ============================================================================== 
" Boldface: Mapping <M-b> to insert \mathbf{} {{{
" Insert Mode:
" Typing <M-b> after a character capitalizes it and encloses it in \mathbf{}
" Visual Mode:
" Encloses the selected portion in \mathbf{}

if !hasmapto('Tex_MathBF')
	inoremap <buffer> <silent> <M-b> <C-r>=Tex_MathBF()<CR>
endif

" Tex_MathBF: encloses te previous letter or number in \mathbf{} {{{
" Description: 
function! Tex_MathBF()
	return "\<Left>\\mathbf{\<Right>}\<Esc>hvUla"
endfunction " }}}

vnoremap <buffer> <silent> <M-b> <C-C>`>a}<Esc>`<i\mathbf{<Esc>
" }}}

" ============================================================================== 
" Tex_MathCal:  Mapping <M-c> to insert \mathcal{} or \cite{} {{{
" Insert Mode:
" 1. If the previous character is a letter or number, then capitalize it and
" 	 enclose it in \mathcal{}
" 2. otherwise insert \cite{«»}«»
" Visual Mode:
" 1. Enclose selection in \mathcal{}
if !hasmapto('Tex_MathCal') && mapcheck('<M-c>') == ''
	inoremap <buffer> <silent> <M-c> <C-R>=Tex_MathCal()<CR>
endif

if !exists('*Tex_MathCal')

	function! Tex_MathCal()
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
" ==============================================================================
" {{{
" 
if !hasmapto('Tex_LeftRight')
	inoremap <buffer> <silent> <M-l> <C-r>=Tex_LeftRight()<CR>
endif
if !hasmapto('Tex_PutLeftRight')
	nnoremap <buffer> <silent> <M-l> :call <SID>PutLeftRight()<CR>
endif

if !exists('*s:LeftRight')
	" Tex_LeftRight: maps <M-l> in insert mode. {{{
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
	function! Tex_LeftRight()
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
	" Tex_PutLeftRight: maps <M-l> in normal mode {{{
	" Put \left...\right in front of the matched brackets.
	function! Tex_PutLeftRight()
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

" vim:fdm=marker
