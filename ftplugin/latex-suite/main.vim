" LaTeX filetype
"	  Language: LaTeX (ft=tex)
"	Maintainer: Srinath Avadhanula
"		 Email: srinath@fastmail.fm
"		   URL: 

" line continuation used here.
let s:save_cpo = &cpo
set cpo&vim

" avoiding re-inclusion {{{
" the avoiding re-inclusion statement is not provided here because the files
" which call this file should in the normal course of events handle the
" re-inclusion stuff.

" we definitely dont want to run through the entire file each and every time.
" only once to define the functions. for successive latex files, just set up
" the folding and mappings and quit.
if exists('s:doneFunctionDefinitions') && !exists('b:forceRedoLocalTex')
	call s:SetTeXOptions()
	finish
endif

let s:doneFunctionDefinitions = 1

" get the place where this plugin resides for setting cpt and dict options.
" these lines need to be outside the function.
let s:path = expand('<sfile>:p:h')
" set up personal defaults.
let s:up_path = expand('<sfile>:p:h:h')
if filereadable(s:up_path.'/tex/texrc')
	exe "so ".s:up_path.'/tex/texrc'
endif
" set up global defaults.
exe "so ".s:path.'/texrc'

" }}}

nmap <silent> <script> <plug> i
imap <silent> <script> <C-o><plug> <Nop>

" ==============================================================================
" mappings
" ==============================================================================
" {{{
" calculate the mapleader character.
let s:ml = exists('g:mapleader') ? g:mapleader : '\'

if !exists('s:doneMappings')
	let s:doneMappings = 1
	" short forms for latex formatting and math elements. {{{
	" taken from auctex.vim or miktexmacros.vim
	call IMAP ('__', '_{<++>}<++>', "tex")
	call IMAP ('()', '(<++>)<++>', "tex")
	call IMAP ('[]', '[<++>]<++>', "tex")
	call IMAP ('{}', '{<++>}<++>', "tex")
	call IMAP ('^^', '^{<++>}<++>', "tex")
	call IMAP ('$$', '$<++>$<++>', "tex")
	call IMAP ('==', '&=& ', "tex")
	call IMAP ('~~', '&\approx& ', "tex")
	call IMAP ('=~', '\approx', "tex")
	call IMAP ('::', '\dots', "tex")
	call IMAP ('((', '\left( <++> \right)<++>', "tex")
	call IMAP ('[[', '\left[ <++> \right]<++>', "tex")
	call IMAP ('{{', '\left\{ <++> \right\}<++>', "tex")
	call IMAP (g:Tex_Leader.'^', '\hat{<++>}<++>', "tex")
	call IMAP (g:Tex_Leader.'_', '\bar{<++>}<++>', "tex")
	call IMAP (g:Tex_Leader.'6', '\partial', "tex")
	call IMAP (g:Tex_Leader.'8', '\infty', "tex")
	call IMAP (g:Tex_Leader.'/', '\frac{<++>}{<++>}<++>', "tex")
	call IMAP (g:Tex_Leader.'%', '\frac{<++>}{<++>}<++>', "tex")
	call IMAP (g:Tex_Leader.'@', '\circ', "tex")
	call IMAP (g:Tex_Leader.'0', '^\circ', "tex")
	call IMAP (g:Tex_Leader.'=', '\equiv', "tex")
	call IMAP (g:Tex_Leader."\\",'\setminus', "tex")
	call IMAP (g:Tex_Leader.'.', '\cdot', "tex")
	call IMAP (g:Tex_Leader.'*', '\times', "tex")
	call IMAP (g:Tex_Leader.'&', '\wedge', "tex")
	call IMAP (g:Tex_Leader.'-', '\bigcap', "tex")
	call IMAP (g:Tex_Leader.'+', '\bigcup', "tex")
	call IMAP (g:Tex_Leader.'M', '\sum_{<++>}^{<++>}<++>', 'tex')
	call IMAP (g:Tex_Leader.'(', '\subset', "tex")
	call IMAP (g:Tex_Leader.')', '\supset', "tex")
	call IMAP (g:Tex_Leader.'<', '\le', "tex")
	call IMAP (g:Tex_Leader.'>', '\ge', "tex")
	call IMAP (g:Tex_Leader.',', '\nonumber', "tex")
	call IMAP (g:Tex_Leader.'~', '\tilde{<++>}<++>', "tex")
	call IMAP (g:Tex_Leader.';', '\dot{<++>}<++>', "tex")
	call IMAP (g:Tex_Leader.':', '\ddot{<++>}<++>', "tex")
	call IMAP (g:Tex_Leader.'2', '\sqrt{<++>}<++>', "tex")
	call IMAP (g:Tex_Leader.'|', '\Big|', "tex")
	call IMAP (g:Tex_Leader.'I', "\\int_{<++>}^{<++>}<++>", 'tex')
	" }}}
	" Greek Letters {{{
	call IMAP('`a', '\alpha', 'tex') " {{{
	call IMAP('`b', '\beta', 'tex')
	call IMAP('`c', '\chi', 'tex')
	call IMAP('`d', '\delta', 'tex')
	call IMAP('`e', '\varepsilon', 'tex')
	call IMAP('`f', '\varphi', 'tex')
	call IMAP('`g', '\gamma', 'tex')
	call IMAP('`h', '\eta', 'tex')
	call IMAP('`k', '\kappa', 'tex')
	call IMAP('`l', '\lambda', 'tex')
	call IMAP('`m', '\mu', 'tex')
	call IMAP('`n', '\nu', 'tex')
	call IMAP('`p', '\pi', 'tex')
	call IMAP('`q', '\theta', 'tex')
	call IMAP('`r', '\rho', 'tex')
	call IMAP('`s', '\sigma', 'tex')
	call IMAP('`t', '\tau', 'tex')
	call IMAP('`u', '\upsilon', 'tex')
	call IMAP('`v', '\varsigma', 'tex')
	call IMAP('`w', '\omega', 'tex')
	call IMAP('`w', '\wedge', 'tex')  " AUCTEX style
	call IMAP('`x', '\xi', 'tex')
	call IMAP('`y', '\psi', 'tex')
	call IMAP('`z', '\zeta', 'tex')
	" not all capital greek letters exist in LaTeX!
	" reference: http://www.giss.nasa.gov/latex/ltx-405.html
	call IMAP('`D', '\Delta', 'tex')
	call IMAP('`F', '\Phi', 'tex')
	call IMAP('`G', '\Gamma', 'tex')
	call IMAP('`Q', '\Theta', 'tex')
	call IMAP('`L', '\Lambda', 'tex')
	call IMAP('`X', '\Xi', 'tex')
	call IMAP('`Y', '\Psi', 'tex')
	call IMAP('`S', '\Sigma', 'tex')
	call IMAP('`U', '\Upsilon', 'tex')
	call IMAP('`W', '\Omega', 'tex')
	" }}}
	" }}}
	" ProtectLetters: sets up indentity maps for things like ``a {{{
	" " Description: If we simply do
	" 		call IMAP('`a', '\alpha', 'tex')
	" then we will never be able to type 'a' after a tex-quotation. Since
	" IMAP() always uses the longest map ending in the letter, this problem
	" can be avoided by creating a fake map for ``a -> ``a.
	" This function sets up fake maps of the following forms:
	" 	``[aA]  -> ``[aA]    (for writing in quotations)
	" 	\`[aA]  -> \`[aA]    (for writing diacritics)
	function! s:ProtectLetters()
		let i = char2nr('a')
		while i <= char2nr('z')
			call IMAP('``'.nr2char(i), '``'.nr2char(i), 'tex')
			call IMAP('\`'.nr2char(i), '\`'.nr2char(i), 'tex')
			call IMAP('``'.nr2char(i-32), '``'.nr2char(i-32), 'tex')
			call IMAP('\`'.nr2char(i-32), '\`'.nr2char(i-32), 'tex')
			let i = i + 1
		endwhile
	endfunction 
	call s:ProtectLetters()
	" }}}
	" vmaps: enclose selected region in brackets, environments {{{ 
	" The action changes depending on whether the selection is character-wise
	" or line wise. for example, selecting linewise and pressing \v will
	" result in the region being enclosed in \begin{verbatim}, \end{verbatim},
	" whereas in characterise visual mode, the thingie is enclosed in \verb|
	" and |.
	exec 'vnoremap <silent> '.g:Tex_Leader."( \<C-\\>\<C-N>:call VEnclose('\\left( ', ' \\right)', '\\left(', '\\right)')\<CR>"
	exec 'vnoremap <silent> '.g:Tex_Leader."[ \<C-\\>\<C-N>:call VEnclose('\\left[ ', ' \\right]', '\\left[', '\\right]')\<CR>"
	exec 'vnoremap <silent> '.g:Tex_Leader."{ \<C-\\>\<C-N>:call VEnclose('\\left\\{ ', ' \\right\\}', '\\left\\{', '\\right\\}')\<CR>"
	exec 'vnoremap <silent> '.g:Tex_Leader."$ \<C-\\>\<C-N>:call VEnclose('$', '$', '\\[', '\\]')\<CR>"
	" }}}
end

" }}}

" ==============================================================================
" Smart key-mappings
" ============================================================================== 
" TexQuotes: inserts `` or '' instead of " {{{
if g:Tex_SmartKeyQuote

	" TexQuotes: inserts `` or '' instead of
	" Taken from texmacro.vim by Benji Fisher <benji@e-math.AMS.org>
	" TODO:  Deal with nested quotes.
	function! s:TexQuotes()
		let l = line(".")
		let c = col(".")
		let restore_cursor = l . "G" . virtcol(".") . "|"
		normal! H
		let restore_cursor = "normal!" . line(".") . "Gzt" . restore_cursor
		execute restore_cursor
		if synIDattr(synID(l, c, 1), "name") =~ "^texMath"
			\ || (c > 1 && getline(l)[c-2] == '\')
			return '"'
		endif
		let open = exists("g:Tex_SmartQuoteOpen") ? g:Tex_SmartQuoteOpen : "``"
		let close = exists("g:Tex_SmartQuoteClose") ? g:Tex_SmartQuoteClose : "''"
		let boundary = '\|'
		if exists("s:TeX_strictquote")
			if( s:TeX_strictquote == "open" || s:TeX_strictquote == "both" )
				let boundary = '\<' . boundary
			endif
			if( s:TeX_strictquote == "close" || s:TeX_strictquote == "both" )
				let boundary = boundary . '\>'
			endif
		endif
		let q = open
		while 1	" Look for preceding quote (open or close), ignoring
			" math mode and '\"' .
			" execute 'normal ?^$\|"\|' . open . boundary . close . "\r"
			call search(open . boundary . close . '\|^$\|"', "bw")
			if synIDattr(synID(line("."), col("."), 1), "name") !~ "^texMath"
				\ && (col(".") == 1 || getline(".")[col(".")-2] != '\')
				break
			endif
		endwhile
		" Now, test whether we actually found a _preceding_ quote; if so, is it
		" and open quote?
		if ( line(".") < l || line(".") == l && col(".") < c )
			if strlen(getline(".")) && (getline(".")[col(".")-1] == open[0])
				if line(".") == l && col(".") + strlen(open) == c
					" Insert "<++>''<++>" instead of just "''".
					let q = IMAP_PutTextWithMovement("<++>".close."<++>")
				else
					let q = close
				endif
			endif
		endif
		" Return to line l, column c:
		execute restore_cursor
		" Start with <Del> to remove the " put in by the :imap .
		return "\<Del>" . q
	endfunction

endif
" }}}
" SmartBS: smart backspacing {{{
if g:Tex_SmartKeyBS 

	" SmartBS: smart backspacing
	" SmartBS lets you treat diacritic characters (those \'{a} thingies) as a
	" single character. This is useful for example in the following situation:
	"
	" \v{s}\v{t}astn\'{y}    ('happy' in Slovak language :-) )
	" If you will delete this normally (without using smartBS() function), you
	" must press <BS> about 19x. With function smartBS() you must press <BS> only
	" 7x. Strings like "\v{s}", "\'{y}" are considered like one character and are
	" deleted with one <BS>.
	"
	let s:smartBS_pat = '\(' .
		\ "\\\\[\"^'=v]{\\S}"      . '\|' .
		\ "\\\\[\"^'=]\\S"         . '\|' .
		\ '\\v \S'                 . '\|' .
		\ "\\\\[\"^'=v]{\\\\[iI]}" . '\|' .
		\ '\\v \\[iI]'             . '\|' .
		\ '\\q \S'                 . '\|' .
		\ '\\-'                    .
		\ '\)' . "$"
	fun! s:SmartBS_pat()
		return s:smartBS_pat
	endfun

	" This function comes from Benji Fisher <benji@e-math.AMS.org>
	" http://vim.sourceforge.net/scripts/download.php?src_id=409 
	" (modified/patched by Lubomir Host 'rajo' <host8 AT keplerDOTfmphDOTuniba.sk>)
	function! s:SmartBS(pat)
		let init = strpart(getline("."), 0, col(".")-1)
		let matchtxt = matchstr(init, a:pat)
		if matchtxt != ''
			let bstxt = substitute(matchtxt, '.', "\<bs>", 'g')
			return bstxt
		else
			return "\<bs>"
		endif
	endfun
	
endif " }}}
" SmartDots: inserts \cdots instead of ... in math mode otherwise \ldots {{{
if g:Tex_SmartKeyDot

	function! <SID>SmartDots()
		if synIDattr(synID(line('.'),col('.')-1,0),"name") =~ '^texMath'
			\&& strpart(getline('.'), col('.')-3, 2) == '..' 
			return "\<bs>\<bs>\\cdots"
		elseif strpart(getline('.'), col('.')-3, 2) == '..' 
			return "\<bs>\<bs>\\ldots"
		else
			return '.'
		endif
	endfunction 

endif
" }}}

" ==============================================================================
" Helper Functions
" ============================================================================== 
" Tex_ShowVariableValue: debugging help {{{
" provides a way to examine script local variables from outside the script.
" very handy for debugging.
function! Tex_ShowVariableValue(...)
	let i = 1
	while i <= a:0
		exe 'let arg = a:'.i
		if exists('s:'.arg) ||
		\  exists('*s:'.arg)
			exe 'let val = s:'.arg
			echomsg 's:'.arg.' = '.val
		end
		let i = i + 1
	endwhile
endfunction

" }}}
" Tex_Strntok: extract the n^th token from a list {{{
" example: Strntok('1,23,3', ',', 2) = 23
fun! Tex_Strntok(s, tok, n)
	return matchstr( a:s.a:tok[0], '\v(\zs([^'.a:tok.']*)\ze['.a:tok.']){'.a:n.'}')
endfun

" }}}
" Tex_CleanSearchHistory: removes last search item from search history {{{
" Description: This function needs to be globally visible because its
"              called from outside the script during expansion.
function! Tex_CleanSearchHistory()
  call histdel("/", -1)
  let @/ = histget("/", -1)
endfunction
nmap <silent> <script> <plug>cleanHistory :call Tex_CleanSearchHistory()<CR>

" }}}
" Tex_GetMainFileName: gets the name (without extension) of the main file being compiled. {{{
" Description:  returns '' if .latexmain doesnt exist.
"               i.e if main.tex.latexmain exists, then returns:
"                   d:/path/to/main
function! Tex_GetMainFileName(...)
	if a:0 > 0
		let modifier = a:1
	else
		let modifier = ':p:r:r'
	endif
	let curd = getcwd()
	exe 'cd '.expand('%:p:h')
	let lheadfile = glob('*.latexmain')
	if lheadfile != ''
		let lheadfile = fnamemodify(lheadfile, modifier)
	endif
	exe 'cd '.curd
	return lheadfile
endfunction 

" }}}
" Tex_ChooseFile: produces a file list and prompts for choice {{{
" Description: 
function! Tex_ChooseFile(dialog)
	let files = glob('*')
	if files == ''
		return ''
	endif
	let s:incnum = 0
	echo a:dialog
	let filenames = substitute(files, "\\v(^|\n)", "\\=submatch(0).Tex_IncrementNumber(1).' : '", 'g')
	echo filenames
	let choice = input('Enter Choice : ')
	let g:choice = choice
	if choice == ''
		return ''
	endif
	if choice =~ '^\s*\d\+\s*$'
		let retval = Tex_Strntok(files, "\n", choice)
	else
		let filescomma = substitute(files, "\n", ",", "g")
		let retval = GetListMatchItem(filescomma, choice)
	endif
	if retval == ''
		return ''
	endif
	return retval
endfunction 

" }}}
" Tex_IncrementNumber: returns an incremented number each time {{{
" Description: 
let s:incnum = 0
function! Tex_IncrementNumber(increm)
	let s:incnum = s:incnum + a:increm
	return s:incnum
endfunction 

" }}}
" Tex_ResetIncrementNumber: increments s:incnum to zero {{{
" Description: 
function! Tex_ResetIncrementNumber(val)
	let s:incnum = a:val
endfunction " }}}
" Functions for debugging {{{
" Tex_Debug: appends the argument into s:debugString {{{
" Description: 
" 
" Do not want a memory leak! Set this to zero so that latex-suite always
" starts out in a non-debugging mode.
if !exists('g:Tex_Debug')
	let g:Tex_Debug = 0
endif
function! Tex_Debug(str, ...)
	if !g:Tex_Debug
		return
	endif
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = ''
	endif
	if !exists('s:debugString_'.pattern)
		let s:debugString_{pattern} = ''
	endif
	let s:debugString_{pattern} = s:debugString_{pattern}.a:str."\n"
endfunction " }}}
" Tex_PrintDebug: prings s:debugString {{{
" Description: 
" 
function! Tex_PrintDebug(...)
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = ''
	endif
	if exists('s:debugString_'.pattern)
		echo s:debugString_{pattern}
	endif
endfunction " }}}
" Tex_ClearDebug: clears the s:debugString string {{{
" Description: 
" 
function! Tex_ClearDebug(...)
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = ''
	endif
	if exists('s:debugString_'.pattern)
		let s:debugString_{pattern} = ''
	endif
endfunction " }}}
" }}}

" source all the relevant files.
exe 'source '.s:path.'/texmenuconf.vim'
exe 'source '.s:path.'/envmacros.vim'
exe 'source '.s:path.'/elementmacros.vim'
exe 'source '.s:path.'/mathmacros.vim'
exe 'source '.s:path.'/compiler.vim'
exe 'source '.s:path.'/folding.vim'
exe 'source '.s:path.'/templates.vim'
exe 'source '.s:path.'/custommacros.vim'
exe 'source '.s:path.'/bibtex.vim'
exe 'source '.s:path.'/diacritics.vim'

" ==============================================================================
" Finally set up the folding, options, mappings and quit.
" ============================================================================== 
" SetTeXOptions: sets options/mappings for this file. {{{
function! <SID>SetTeXOptions()
	exe 'setlocal dict+='.s:path.'/dictionaries/dictionary'
	setlocal foldtext=TexFoldTextFunction()

	" fold up things. and mappings for refreshing folds.
	if g:Tex_Folding && g:Tex_AutoFolding
		call MakeTexFolds(0)
	endif
	if g:Tex_Folding
		if mapcheck('<F6>') == ""
			nnoremap <buffer> <F6> :call MakeTexFolds(1)<cr>
		endif
		nnoremap <buffer> <leader>rf :call MakeTexFolds(1)<cr>
	endif

	" smart functions
	if g:Tex_SmartKeyQuote 
		inoremap <buffer> <silent> " "<Left><C-R>=<SID>TexQuotes()<CR>
	endif
	if g:Tex_SmartKeyBS
		inoremap <buffer> <silent> <BS> <C-R>=<SID>SmartBS(<SID>SmartBS_pat())<CR>
	endif
	if g:Tex_SmartKeyDot
		inoremap <buffer> <silent> . <C-R>=<SID>SmartDots()<CR>
	endif
	if g:Tex_PromptedEnvironments != '' || g:Tex_HotKeyMappings != ''
		call Tex_SetFastEnvironmentMaps()
	endif

	" viewing/searching
	if !hasmapto('RunLaTeX')
		if has("gui")
			nnoremap <buffer> <Leader>ll :silent! call RunLaTeX()<cr>
			nnoremap <buffer> <Leader>lv :silent! call ViewLaTeX()<cr>
			nnoremap <buffer> <Leader>ls :silent! call ForwardSearchLaTeX()<cr>
		else
			nnoremap <buffer> <Leader>ll :call RunLaTeX()<cr>
			nnoremap <buffer> <Leader>lv :call ViewLaTeX()<cr>
			nnoremap <buffer> <Leader>ls :call ForwardSearchLaTeX()<cr>
		end
	end
	" This line seems to be necessary to source our compiler/tex.vim file.
	" The docs are unclear why this needs to be done even though this file is
	" the first compiler plugin in 'runtimepath'.
	runtime compiler/tex.vim
endfunction

call <SID>SetTeXOptions()

" }}}

" Mappings defined in package files will overwrite all other
exe 'source '.s:path.'/packages.vim'

let &cpo = s:save_cpo

" vim:fdm=marker:nowrap:noet:ts=4:sw=4
