" ==============================================================================
" History: This was originally part of auctex.vim by Carl Mueller.
"          Srinath Avadhanula incorporated it into latex-suite with
"          significant modifications.
"          Parts of this file may be copyrighted by others as noted.
" Description:
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
" . <M-i> inserts \item commands at the current cursor location depending on
"       the surrounding environment. For example, inside itemize, it will
"       insert a simple \item, but within a description, it will insert
"       \item[<+label+>] etc.
" 
" These functions make it extremeley easy to do all the \left \right stuff in
" latex.
" ============================================================================== 

" Avoid reinclusion.
if exists('b:did_brackets')
	finish
endif
let b:did_brackets = 1

" define the funtions only once.
if exists('*Tex_MathBF')
	finish
endif

" Tex_MathBB: encloses te previous letter/number in \mathbb{} {{{
" Description: 
function! Tex_MathBB()
	return "\<Left>\\mathbb{\<Right>}"
endfunction " }}}
" Tex_MathBF: encloses te previous letter/number in \mathbf{} {{{
" Description: 
function! Tex_MathBF()
	return "\<Left>\\mathbf{\<Right>}"
endfunction " }}}
" Tex_MathCal: enclose the previous letter/number in \mathcal {{{
" Description:
" 	if the last character is not a letter/number, then insert \cite{}
function! Tex_MathCal()
	let line = getline(line("."))
	let char = line[col(".")-2]

	if char =~ '[a-zA-Z0-9]'
		return "\<BS>".'\mathcal{'.toupper(char).'}'
	else
		return IMAP_PutTextWithMovement('\cite{<++>}<++>')
	endif
endfunction
" }}}
" Tex_MathDS: encloses the previous letter/number in \mathds{} {{{
" Description: 
function! Tex_MathDS()
	return "\<Left>\\mathds{\<Right>}"
endfunction " }}}
" Tex_LeftRight: maps <M-l> in insert mode. {{{
" Description:
" This is a polymorphic function, which maps the behaviour of <M-l> in the
" following way:
" If the character before typing <M-l> is one of '([{|<q', then do the
" following:
" 	1. (<M-l>		\left(<++>\right<++>
" 	    	similarly for [, |
" 	   {<M-l>		\left\{<++>\right\}<++>
" 	2. <<M-l>		\langle<++>\rangle<++>
" 	3. q<M-l>		\lefteqn{<++>}<++>
" otherwise insert  \label{<++>}<++>
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
		return "\<BS>".IMAP_PutTextWithMovement('\left'.add.char.'<++>\right'.add.rhs.'<++>')
	elseif char == '<'
		return "\<BS>".IMAP_PutTextWithMovement('\langle <++>\rangle<++>')
	elseif char == 'q'
		return "\<BS>".IMAP_PutTextWithMovement('\lefteqn{<++>}<++>')
	else
		return IMAP_PutTextWithMovement('\label{<++>}<++>')
	endif
endfunction " }}}
" Tex_PutLeftRight: maps <M-l> in normal mode {{{
" Description:
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

" PromptForEnvironment: prompts for a sizer {{{
" Description: 
function! PromptForSizer(ask)
	return Tex_ChooseFromPrompt(
		\ a:ask."\n" . 
		\ Tex_CreatePrompt(g:Tex_PromptedSizers, 2, ",") .
		\ "\nEnter name or number of sizers : ", 
		\ g:Tex_PromptedSizers, ",")
endfunction " }}}
"Tex_ReverseString: {{{
function! Tex_ReverseString(my_string)
	return join(reverse(split(a:my_string, '.\zs')), '')
endfunction" }}}
"Tex_ChangeSizing: maps <F4> {{{
function! Tex_ChangeSizing()
	let this_line = line(".")
	let this_col = col(".")
	let lhs = '\\bigl\|\\Bigl\|\\biggl\|\\Biggl'
	let lhs_reversed = 'lgib\\\|lgiB\\\|lggib\\\|lggiB\\'
	let rhs = '\\bigr\|\\Bigr\|\\biggr\|\\Biggr'
	let sizer_line = searchpair(lhs, '', rhs, "bncW")

	if sizer_line == 0
		echomsg "You are not inside any sizers."
		return 0
	endif

	if sizer_line == this_line
		let reverse_string = Tex_ReverseString(getline(sizer_line)[:this_col-1])
	else
		let reverse_string = Tex_ReverseString(getline(sizer_line))
	end
	let reverse_sizer_name = matchstr(reverse_string, lhs_reversed)
	let sizer_name = Tex_ReverseString(reverse_sizer_name)[1:-2]
	let length_sizer = len(sizer_name)

	exe 'echomsg "You are within a '.sizer_name.' sizer."'
	let change_sizer = PromptForSizer('What do you want to change it to?')
	let w = search('\\'.sizer_name.'l', "b")
	exe 'normal '.string(length_sizer+2).'x'
	exe 'normal i\'.change_sizer.'l'
	let counter = 1
	while counter > 0
		let w = search('\\'.sizer_name.'r\|\\'.sizer_name.'l')
		let colpos = col(".")
		let tempstr = matchstr(getline(line("."))[colpos-1:colpos+length_sizer], '\\'.sizer_name.'r\|\\'.sizer_name.'l')
		if tempstr =~ sizer_name.'r'
			let counter -= 1
		elseif tempstr =~ sizer_name.'l'
			let counter += 1
		else
			echomsg "Incomplete sizers."
			return ""
		endif
	endwhile
	exe 'normal '.string(length_sizer+2).'x'
	exe 'normal i\'.change_sizer.'r'
	cal cursor(this_line, this_col + len(change_sizer) - length_sizer)
endfunction " }}}
"Tex_ChangeSizingVisual: maps <F4> when in visual mode {{{
function! Tex_ChangeSizingVisual()
	let sizer = PromptForSizer('What sizer do you want?')
	let brackets = PromptForBrackets('What brackets does the sir want?')
	let spaceIndex = match(brackets, ' ')
	let lbracket = brackets[0:spaceIndex-1]
	let rbracket = brackets[spaceIndex+1:-1]
	exe 'normal `<i\'.sizer.'l'.lbracket.' '
	exe 'normal `>'.(len(sizer)+len(lbracket)+3).'la \'.sizer.'r'.rbracket
endfunction " }}}
" PromptForEnvironment: prompts for brackets {{{
" Description: 
function! PromptForBrackets(ask)
	return Tex_ChooseFromPrompt(
		\ a:ask."\n" . 
		\ Tex_CreatePrompt(g:Tex_PromptedBrackets, 2, ",") .
		\ "\nEnter number of the brackets : ", 
		\ g:Tex_PromptedBrackets, ",")
endfunction " }}}

" Provide <plug>'d mapping for easy user customization. {{{
inoremap <silent> <Plug>Tex_MathBB      	<C-r>=Tex_MathBB()<CR>
inoremap <silent> <Plug>Tex_MathBF     		<C-r>=Tex_MathBF()<CR>
inoremap <silent> <Plug>Tex_MathCal     	<C-r>=Tex_MathCal()<CR>
inoremap <silent> <Plug>Tex_MathDS	     	<C-r>=Tex_MathDS()<CR>
inoremap <silent> <Plug>Tex_LeftRight   	<C-r>=Tex_LeftRight()<CR>
inoremap <silent> <Plug>Tex_ChangeSizing	<C-r>=Tex_ChangeSizing()<CR>
vnoremap <silent> <Plug>Tex_MathBB			<C-C>`>a}<Esc>`<i\mathbb{<Esc>
vnoremap <silent> <Plug>Tex_MathBF			<C-C>`>a}<Esc>`<i\mathbf{<Esc>
vnoremap <silent> <Plug>Tex_MathCal			<C-C>`>a}<Esc>`<i\mathcal{<Esc>
vnoremap <silent> <Plug>Tex_MathDS			<C-C>`>a}<Esc>`<i\mathds{<Esc>
vnoremap <silent> <Plug>Tex_ChangeSizing	<C-C>:call Tex_ChangeSizingVisual()<CR>
nnoremap <silent> <Plug>Tex_LeftRight		:call Tex_PutLeftRight()<CR>
nnoremap <silent> <Plug>Tex_ChangeSizing	:call Tex_ChangeSizing()<CR>
" }}}
" Tex_SetBracketingMaps: create mappings for the current buffer {{{
function! <SID>Tex_SetBracketingMaps()
	if g:Tex_AdvancedMath == 1
		call Tex_MakeMap('<M-b>', '<Plug>Tex_MathBB', 'i', '<buffer> <silent>')
		call Tex_MakeMap('<M-f>', '<Plug>Tex_MathBF', 'i', '<buffer> <silent>')
		call Tex_MakeMap('<M-c>', '<Plug>Tex_MathCal', 'i', '<buffer> <silent>')
		call Tex_MakeMap('<M-d>', '<Plug>Tex_MathDS', 'i', '<buffer> <silent>')
		call Tex_MakeMap('<M-l>', '<Plug>Tex_LeftRight', 'i', '<buffer> <silent>')
		call Tex_MakeMap('<F4>', '<Plug>Tex_ChangeSizing', 'i', '<buffer> <silent>')
		call Tex_MakeMap('<M-b>', '<Plug>Tex_MathBB', 'v', '<buffer> <silent>')
		call Tex_MakeMap('<M-f>', '<Plug>Tex_MathBF', 'v', '<buffer> <silent>')
		call Tex_MakeMap('<M-c>', '<Plug>Tex_MathCal', 'v', '<buffer> <silent>')
		call Tex_MakeMap('<M-d>', '<Plug>Tex_MathDS', 'v', '<buffer> <silent>')
		call Tex_MakeMap('<F4>', '<Plug>Tex_ChangeSizing', 'v', '<buffer> <silent>')
		call Tex_MakeMap('<M-l>', '<Plug>Tex_LeftRight', 'n', '<buffer> <silent>')
		call Tex_MakeMap('<F4>', '<Plug>Tex_ChangeSizing', 'n', '<buffer> <silent>')
	endif
endfunction
" }}}

augroup LatexSuite
	au LatexSuite User LatexSuiteFileType 
		\ call Tex_Debug('brackets.vim: Catching LatexSuiteFileType event', 'brak') | 
		\ call <SID>Tex_SetBracketingMaps()
augroup END

" vim:fdm=marker
