" LaTeX filetype
"	  Language: LaTeX (ft=tex)
"	Maintainer: Srinath Avadhanula
"		 Email: srinath@fastmail.fm
"		   URL: 
"  Last Change: sob maj 04 08:00  2002 U
"
" Help: 
" Changes: {{{
" Apr 26 2002: 1. Major reworking of files and such.
"                 Lots of changes are not documented here. see the cvs log for
"                 change information.
" Apr 04 2002: 1. changed yap to yap -1 (BNF)
"              2. changed g:smartBS to s:smartBS (BNF)
" Apr 04 2002: 1. (BNF) I changed SmartBS() so that it accepts an argument
" 				  instead of using a global variable.
" 			   2. I made some minor simplifications to
" 				  s:SetTeXOptions() .
" Mar 17 2002: 1. added errorformat and makeprg options for latex.
" Dec 09 2001: 1. took some stuff from auctex.vim
"				  such as smart quotes and dollar, etc.
" Dec 07 2001: 1. changed things so that most mappings emulate the operator
"				  pending mode. this greatly facilitates typing by not
"				  requiring the LHS to be typed quickly. one can infact type
"				  the LHS (without the <tab>), roam around in the file, come
"				  back to the end of the file, press <tab> and still have the
"				  LHS expand properly!
"			   2. planning a second release for this.
" }}}

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
let s:up_path = substitute(s:path, "latex-suite", "", "")
if filereadable(s:up_path.'tex/texrc')
	exe "so ".s:up_path.'tex/texrc'
else
" set up global defaults.
	exe "so ".s:path.'/texrc'
endif

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
	call IMAP ('__', '_{ä}«»', "tex")
	call IMAP ('()', '(ä)«»', "tex")
	call IMAP ('[]', '[ä]«»', "tex")
	call IMAP ('{}', '{ä}«»', "tex")
	call IMAP ('^^', '^{ä}«»', "tex")
	call IMAP ('$$', '$ä$«»', "tex")
	call IMAP ('==', '&=& ', "tex")
	call IMAP ('~~', '&\approx& ', "tex")
	call IMAP ('=~', '\approx', "tex")
	call IMAP ('::', '\dots', "tex")
	call IMAP ('((', '\left( ä \right)«»', "tex")
	call IMAP ('[[', '\left[ ä \right]«»', "tex")
	call IMAP ('{{', '\left\{ ä \right\}«»', "tex")
	call IMAP (g:Tex_Leader.'^', '\hat{ä}«»', "tex")
	call IMAP (g:Tex_Leader.'_', '\bar{ä}«»', "tex")
	call IMAP (g:Tex_Leader.'6', '\partial', "tex")
	call IMAP (g:Tex_Leader.'8', '\infty', "tex")
	call IMAP (g:Tex_Leader.'/', '\frac{ä}{«»}«»', "tex")
	call IMAP (g:Tex_Leader.'%', '\frac{ä}{«»}«»', "tex")
	call IMAP (g:Tex_Leader.'@', '\circ', "tex")
	call IMAP (g:Tex_Leader.'0', '^\circ', "tex")
	call IMAP (g:Tex_Leader.'=', '\equiv', "tex")
	call IMAP (g:Tex_Leader."\\",'\setminus', "tex")
	call IMAP (g:Tex_Leader.'.', '\cdot', "tex")
	call IMAP (g:Tex_Leader.'*', '\times', "tex")
	call IMAP (g:Tex_Leader.'&', '\wedge', "tex")
	call IMAP (g:Tex_Leader.'-', '\bigcap', "tex")
	call IMAP (g:Tex_Leader.'+', '\bigcup', "tex")
	call IMAP (g:Tex_Leader.'(', '\subset', "tex")
	call IMAP (g:Tex_Leader.')', '\supset', "tex")
	call IMAP (g:Tex_Leader.'<', '\le', "tex")
	call IMAP (g:Tex_Leader.'>', '\ge', "tex")
	call IMAP (g:Tex_Leader.',', '\nonumber', "tex")
	call IMAP (g:Tex_Leader.'~', '\tilde{ä}«»', "tex")
	call IMAP (g:Tex_Leader.';', '\dot{ä}«»', "tex")
	call IMAP (g:Tex_Leader.':', '\ddot{ä}«»', "tex")
	call IMAP (g:Tex_Leader.'2', '\sqrt{ä}«»', "tex")
	call IMAP (g:Tex_Leader.'|', '\Big|', "tex")
	call IMAP (g:Tex_Leader.'I', "\\int_{ä}^{«»}«»", 'tex')
	" }}}
	" other miscellaneous stuff taken from imaps.vim. {{{
	call IMAP ("vb".s:ml, "\\verb|ä|«»", "tex")
	call IMAP ("bf".s:ml, "{\\bf ä}«»", "tex")
	call IMAP ("em".s:ml, "{\\em ä}«»", "tex")
	call IMAP ("it".s:ml, "{\\it ä}«»", "tex")
	call IMAP ("mb".s:ml, "\\mbox{ä}«»", "tex")
	call IMAP ("frac".s:ml, "\\frac{ä}{«»}«»", "tex")
	call IMAP ("sq".s:ml, "\\sqrt{ä}«»", "tex")
	call IMAP ("eps".s:ml, "\\psfig{figure=ä.eps}«»", "tex")
	call IMAP ("sec".s:ml, "\\section{ä}«»", "tex")
	call IMAP ("ssec".s:ml, "\\subsection{ä}«»", "tex")
	call IMAP ("sssec".s:ml, "\\subsubsection{ä}«»", "tex")
	call IMAP ("sec2".s:ml, "\\subsection{ä}«»", "tex")
	call IMAP ("sec3".s:ml, "\\subsubsection{ä}«»", "tex")
	call IMAP ("sum".s:ml, "\\sum{ä}{«»}«»", "tex")
	call IMAP ("suml".s:ml, "\\sum\\limits_{ä}^{«»}«»", "tex")
	call IMAP ("int".s:ml, "\\int_{ä}^{«»}«»", "tex")
	call IMAP ("intl".s:ml, "\\int\\limits_{ä}^{«»}«»", "tex")
	call IMAP ("bbr".s:ml, "\\left( ä \\right)«»", "tex")
	call IMAP ("bbc".s:ml, "\\left\\{ ä \\right\\}«»", "tex")
	call IMAP ("bbs".s:ml, "\\left[ ä \\right]«»", "tex")
	call IMAP ("rr".s:ml, "\\right", "tex")
	call IMAP ("ll".s:ml, "\\left", "tex")
	call IMAP ("part".s:ml, "\\partial", "tex")
	call IMAP ("dot".s:ml, "\\dot{ä}«»", "tex")
	call IMAP ("ddot".s:ml, "\\ddot{ä}«»", "tex")
	" }}}
	" Greek Letters {{{
	let s:greek_a = "\\alpha" " {{{
	let s:greek_b = "\\beta"
	let s:greek_c = "\\chi"
	let s:greek_d = "\\delta"
	let s:greek_e = "\\varepsilon"
	let s:greek_f = "\\varphi"
	let s:greek_g = "\\gamma"
	let s:greek_h = "\\eta"
	let s:greek_k = "\\kappa"
	let s:greek_l = "\\lambda"
	let s:greek_m = "\\mu"
	let s:greek_n = "\\nu"
	let s:greek_p = "\\pi"
	let s:greek_q = "\\theta"
	let s:greek_r = "\\rho"
	let s:greek_s = "\\sigma"
	let s:greek_t = "\\tau"
	let s:greek_u = "\\upsilon"
	let s:greek_v = "\\varsigma"
	let s:greek_w = "\\omega"
	" let s:greek_w = "\\wedge"  " AUCTEX style
	let s:greek_x = "\\xi"
	let s:greek_y = "\\psi"
	let s:greek_z = "\\zeta"
	" not all capital greek letters exist in LaTeX!
	" reference: http://www.giss.nasa.gov/latex/ltx-405.html
	let s:greek_D = "\\Delta"
	let s:greek_F = "\\Phi"
	let s:greek_G = "\\Gamma"
	let s:greek_Q = "\\Theta"
	let s:greek_L = "\\Lambda"
	let s:greek_X = "\\Xi"
	let s:greek_Y = "\\Psi"
	let s:greek_S = "\\Sigma"
	let s:greek_U = "\\Upsilon"
	let s:greek_W = "\\Omega"
	" }}}
	" InsertGreekLetter: inserts greek letter {{{
	" Description: checks the text before the preceeding ` in order to account
	" for the start of a double quote, otherwise when we try to write
	" something like ``a (at the beginning of a quote), we immediately get 
	" `\alpha.
	function! TEX_InsertGreekLetter(char)
		if a:char =~ '[a-zA-Z]' && getline('.')[col('.')-2] != '`'
			exe 'return s:greek_'.a:char
		else
			return g:Tex_Leader.a:char
		end
	endfunction 
	" }}}
	" SetupGreekLetters: mappings for greek letters for expansion as `a {{{
	" Description: 
	function! <SID>SetupGreekLetters()
		let i = char2nr('a')
		while i <= char2nr('z')
			call IMAP(g:Tex_Leader.nr2char(i), "\<C-r>=TEX_InsertGreekLetter('".nr2char(i)."')\<CR>", 'tex')
			if exists('s:greek_'.nr2char(i-32))
				call IMAP(g:Tex_Leader.nr2char(i-32), "\<C-r>=TEX_InsertGreekLetter('".nr2char(i-32)."')\<CR>", 'tex')
			endif
			let i = i + 1
		endwhile
	endfunction 
	call s:SetupGreekLetters()
	" }}}
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
	let open = exists("s:TeX_open") ? s:TeX_open : "``"
	let close = exists("s:TeX_close") ? s:TeX_close : "''"
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
		if strlen(getline("."))
			if ( getline(".")[col(".")-1] == open[0] )
				let q = close
			endif
		endif
	endif
	" Return to line l, column c:
	execute restore_cursor
	return q
endfunction
" }}}
" SmartBS: smart backspacing {{{
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
" }}}
" SmartDots: inserts \cdots instead of ... in math mode otherwise ... {{{
function! <SID>SmartDots()
	if synIDattr(synID(line('.'),col('.')-1,0),"name") =~ '^texMath'
		\&& strpart(getline('.'), col('.')-3, 2) == '..' 
		return "\<bs>\<bs>\\cdots"
	else
		return '.'
	endif
endfunction " }}}

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
function! Tex_GetMainFileName()
	let curd = getcwd()
	exe 'cd '.expand('%:p:h')
	let lheadfile = glob('*.latexmain')
	if lheadfile != ''
		let lheadfile = fnamemodify(lheadfile, ':p:r:r')
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
	let num = input('Enter Choice :')
	if num == ''
		let num = 1
	endif
	let retval = Tex_Strntok(files, "\n", num)
	if retval == ''
		let ret = Tex_Strntok(files, "\n", 1)
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

" source all the relevant files.
exe 'source '.s:path.'/texmenuconf.vim'
exe 'source '.s:path.'/envmacros.vim'
exe 'source '.s:path.'/elementmacros.vim'
exe 'source '.s:path.'/mathmacros.vim'
exe 'source '.s:path.'/compiler.vim'
exe 'source '.s:path.'/folding.vim'
exe 'source '.s:path.'/packages.vim'
exe 'source '.s:path.'/templates.vim'
exe 'source '.s:path.'/custommacros.vim'
exe 'source '.s:path.'/bibtex.vim'
exe 'source '.s:path.'/diacritics.vim'

" ==============================================================================
" Finally set up the folding, options, mappings and quit.
" ============================================================================== 
" SetTeXOptions: sets options/mappings for this file. {{{
function! <SID>SetTeXOptions()
	" ':' is included because  most labels are of the form,
	"  fig:label, etc.
	setlocal isk+=:
	exe 'setlocal dict+='.s:path.'/dictionaries/dictionary'
	setlocal sw=2
	setlocal ts=2
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
	inoremap <buffer> <silent> " "<Left><C-R>=<SID>TexQuotes()<CR><Del>
	inoremap <buffer> <silent> <BS> <C-R>=<SID>SmartBS(<SID>SmartBS_pat())<CR>
	inoremap <buffer> <silent> . <C-R>=<SID>SmartDots()<CR>
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
	exe 'TCTarget '.g:Tex_DefaultTargetFormat
	exe 'TVTarget '.g:Tex_DefaultTargetFormat
	" compiler. if the user has put another compiler before ours, then we dont
	" get into our compiler/tex.vim.
	runtime compiler/tex.vim
endfunction

call <SID>SetTeXOptions()

" }}}

let &cpo = s:save_cpo

" vim:fdm=marker:nowrap:noet:ts=4:sw=4
