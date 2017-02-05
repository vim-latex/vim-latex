" Vim indent file
"
" Options: {{{
"
" The options are mostly compatible with the indent/tex.vim distributed by
" vim.
" Here, we have one new option: g:tex_indent_ifelsefi
"
" To set the following options, add a line like
"   let g:tex_indent_items = 1
" to your ~/ftplugin/tex.vim.
"
"
" * g:tex_indent_brace = 1
"
"   If this variable is unset or non-zero, it will use smartindent-like style
"   for "{}", "[]" and "()".
"
"
" * g:tex_indent_items = 1
"
"   If this variable is set, item-environments are indented like Emacs does
"   it, i.e., continuation lines are indented with a shiftwidth.
"
"              set                                unset
"   ----------------------------------------------------------------
"       \begin{itemize}                      \begin{itemize}
"         \item blablabla                      \item blablabla
"           bla bla bla                        bla bla bla
"         \item blablabla                      \item blablabla
"           bla bla bla                        bla bla bla
"       \end{itemize}                        \end{itemize}
"
"
" * g:tex_items = '\\bibitem\|\\item'
"
"   A list of tokens to be considered as commands for the beginning of an item
"   command. The tokens should be separated with '\|'. The initial '\' should
"   be escaped.
"
"
" * g:tex_itemize_env = 'itemize\|description\|enumerate\|thebibliography'.
"
"   A list of environment names, separated with '\|', where the items (item
"   commands matching g:tex_items) may appear.
"
"
" * g:tex_noindent_env = 'document\|verbatim\|comment\|lstlisting'
"
"   A list of environment names. separated with '\|', where no indentation is
"   required.
"
"
" * g:tex_indent_ifelsefi = 1
"
"   If this is set to one, we try to indent something like
"   \ifnum...
"     bar
"   \else
"     foo
"   \fi
"   correctly. This is quite tough, since there are commands like
"   \ifthenelse{condition}{then}{else}, which uses braces instead of \else and
"   \fi. Our heuristic: only add indentation, if \if... is not followed by a
"   '{', (and only if \if,\else,\or,\fi occur at the beginning of the line).
"
" }}}

if exists('b:suppress_latex_suite') && b:suppress_latex_suite == 1
	finish
endif

if exists("b:did_indent")
	finish
endif
if v:version < 700
	echohl WarningMsg
	echo "Indentation of latex-suite requires vim version >= 700.\n"
				\ . "Fallback to default indentation."
	echohl None
	finish
endif
let b:did_indent = 1

" Check whether the options exist and assign default values
if !exists("g:tex_indent_brace")
	let g:tex_indent_brace = 1
endif
if !exists("g:tex_indent_items")
	let g:tex_indent_items = 1
endif
if !exists('g:tex_items')
	let g:tex_items = '\\bibitem\|\\item'
endif
if !exists("g:tex_itemize_env")
	let g:tex_itemize_env = 'itemize\|description\|enumerate\|thebibliography'
endif
if !exists("g:tex_noindent_env")
	let g:tex_noindent_env = 'document\|verbatim\|comment\|lstlisting'
endif
if !exists("g:tex_indent_ifelsefi")
	let g:tex_indent_ifelsefi = 1
endif

setlocal autoindent
setlocal nosmartindent
setlocal indentexpr=Tex_CalcIdent()
setlocal indentkeys+=},],.,)

" Cache {{{
" Internally, the indentation uses a cache for precompiled patterns
" and the last indented line. However, the cache cannot be used, if the
" options have changed.
"
" CacheOptions: puts options into a list {{{
function! s:CacheOptions()
	return [
				\ g:tex_indent_brace,
				\ g:tex_indent_items,
				\ g:tex_items,
				\ g:tex_itemize_env,
				\ g:tex_noindent_env,
				\ g:tex_indent_ifelsefi,
				\ ]
endfunction
" }}}
" SetCache: Remembers the options used to set up the cache. {{{
function! s:SetCache()
	let s:cache_options = s:CacheOptions()
endfunction
" }}}
" CanUseCache: Can we use the cache? {{{
function! s:CanUseCache()
	return s:cache_options == s:CacheOptions()
endfunction
" }}}
" Initialize the cache {{{
let s:cache_options = []
" }}}
" }}}

" Function DeepestNesting:   compute indentation of a line {{{
" This function computes the deepest/smallest nesting on the current line. We
" start with 0, each match of openregexp increases nesting and each match of
" closeregexp decreases nesting.
" The return value is the deepest indentation of the current line and the
" additional indentation which should be used for the next line.
" Parameters:
"   line              This string should be indented
"
" All the regexps should be able to be combined via \|, preferably single
" atoms (enclose them in '\%(', '\)'!)
function! s:DeepestNesting(line)
	let indent = 0
	let pos = 0

	let deepest = 0

	" Now, we look through the line for matching patterns
	while pos >= 0
		" Look for the next match of one of the patterns.

		" Do we have the function matchstrpos() (introduced in version 7.4.1684)?
		if exists('*matchstrpos')
			" Here, we explicitly use the 'count' option of 'matchstrpos' such that
			" '^' matches only at the beginning of the string (and not at 'pos')
			let strpos = matchstrpos( a:line, s:all, pos, 1 )
			let pos = strpos[2]
			let str = strpos[0]
		else
			" Here, we explicitly use the 'count' option of 'match'/'matchend' such that
			" '^' matches only at the beginning of the string (and not at 'pos')
			" Does not work with version < 7
			let start = match( a:line, s:all, pos, 1 )
			if start < 0
				" No more matches were found.
				break
			end
			let pos = matchend( a:line, s:all, start, 1 )
			let str = a:line[ start : pos-1 ]
		end

		if pos <= 0
			" No more matches were found.
			break
		endif

		" Check which pattern has matched
		if str =~ '^' . s:openextraregexp . '$'
			let indent += 2
		elseif str =~ '^' . s:closeextraregexp . '$'
			let indent -= 2
		elseif str =~ '^' . s:openregexp . '$'
			let indent += 1
		elseif str =~ '^' . s:closeregexp . '$'
			let indent -= 1
		else
			" For a hanging line, do not alter indent,
			" but possibly update the deepest indentation
			let deepest = min([deepest, indent - 1])
		endif

		" Update deepest indentation
		let deepest = min([deepest, indent])
	endwhile

	return [deepest, indent - deepest]
endfunction
" }}}
" Function AssemblePatterns: pre-compute patterns{{{
" This function uses the options to assemble various patterns. These patterns
" do not depend on the line which is indented and can be pre-computed.
" This function also sets option-dependent indentkeys
" Description Of Patterns:
"   openregexp        Causes 1 indentation more
"   closeregexp       Causes 1 indentation less
"   openextraregexp   Causes 2 indentations more
"   closeextraregexp  Causes 2 indentations less
"   hangingregexp     Only this line has 1 indentation less
function! s:AssemblePatterns()
	" Add a 'shiftwidth' after beginning
	" and subtract a 'shiftwidth' after the end of environments.
	" Don't add it for \begin{document} and \begin{verbatim}, see
	" g:tex_noindent_env
	let open = '\\begin\s*{\%('.g:tex_noindent_env.'\)\@!.\{-\}}'
	let close = '\\end\s*{\%('.g:tex_noindent_env.'\)\@!.\{-\}}'

	if g:tex_indent_brace
		let open  = open  . '\|[[{(]\|\\left\.'
		let close = close . '\|[]})]\|\\right\.'
	endif

	if g:tex_indent_items
		" For itemize-like environments: add or subtract two 'shiftwidth'
		let s:openextraregexp  = '\\begin\s*{\%('.g:tex_itemize_env.'\)\*\?}'
		let s:closeextraregexp = '\\end\s*{\%('.g:tex_itemize_env.'\)\*\?}'

		" Special treatment for items, they will hang
		let hanging = g:tex_items
	else
		" Extra environment indentation
		let s:openextraregexp  = ''
		let s:closeextraregexp = ''

		" No hanging expression
		let hanging = ''
	endif

	if g:tex_indent_ifelsefi
		" Do match '\if..' only if it is not followed by '{'
		" Require \fi, and \if... only at beginning of line,
		" otherwise,
		"     \newif\ifbarfoo
		" would be indented.
		" Expection: If a line starts with '\if...' and
		" contains an '\fi', it is not indented, e.g.:
		"     \ifbarfoo\foobaz\fi
		" Exception: '\expandafter\ifx\csname barfoo \endcsname'
		" is quite common and indented.
		let open .= '\|^\s*\%(\\expandafter\)\?\\if\a*\>{\@!\%(.*\\fi\)\@!'
		let close .= '\|^\s*\\fi\>'
		let elseor = '\\else\>\|\\or\>'
		if hanging != ''
			let hanging = elseor . '\|' . hanging
		else
			let hanging = elseor
		end
	end

	" Wrap open and close in parentheses
	let s:openregexp  = '\%(' . open  . '\)'
	let s:closeregexp = '\%(' . close . '\)'

	" Wrap hanging in parentheses, match only at beginning of line
	let s:hangingregexp = '^\s*\%(' . hanging . '\)'

	" Accumulate all patterns.
	let s:all = ''
	if s:openregexp != ''
		let s:all .= '\|' . s:openregexp
	endif
	if s:closeregexp != ''
		let s:all .= '\|' . s:closeregexp
	endif
	if s:openextraregexp != ''
		let s:all .= '\|' . s:openextraregexp
	endif
	if s:closeextraregexp != ''
		let s:all .= '\|' . s:closeextraregexp
	endif
	if s:hangingregexp != ''
		let s:all .= '\|' . s:hangingregexp
	endif
	if s:all == ''
		" No expressions given. Replace by a regexp which matches nowhere
		let s:all = '\_$.'
	else
		" Strip the first '\|'
		let s:all = s:all[2:]
	end


	" Add indentkeys depending on options
	let items_keys = substitute(g:tex_items, '^\|\(\\|\)', ',0=', 'g')
	if g:tex_indent_items
		exec 'setlocal indentkeys+=' . items_keys
	else
		exec 'setlocal indentkeys-=' . items_keys
	endif

	let ifelsefi_keys = '0=\\else,0=\\or,0=\\fi'
	if g:tex_indent_ifelsefi
		exec 'setlocal indentkeys+=' . ifelsefi_keys
	else
		exec 'setlocal indentkeys-=' . ifelsefi_keys
	endif
endfunction
" }}}
" Function Tex_CalcIndent:   to be used as indentexpr {{{
" This function can be used as indentexpr.
function! Tex_CalcIdent()
	" Check whether we can use the cache
	let can_use_cache = s:CanUseCache()
	call s:SetCache()

	if !can_use_cache
		call s:AssemblePatterns()
	endif

	" Current line number
	let clnum = v:lnum

	" Code for comment: If current line is a comment, do not alter the
	" indentation
	let cline = getline(clnum) " Content of current line
	if cline =~ '^\s*%'
		return indent(clnum)
	endif

	" Strip comments
	let cline = substitute(cline, '\\\@<!\(\\\\\)*\zs%.*', '', '')
	" Strip leading whitespace
	let cline = substitute(cline, '^\s*', '', '')

	" Find a non-blank line above the current line, which is more than a comment.
	let plnum = prevnonblank(clnum - 1)
	while plnum != 0
		if getline(plnum) !~ '^\s*%'
			break
		endif
		let plnum = prevnonblank(plnum - 1)
	endwhile

	" At the start of the file use zero indent.
	if plnum == 0
		return 0
	endif

	" Current indentation of previous line
	let pind = indent(plnum)
	" Content of previous line
	let pline = getline(plnum)
	" Strip comments
	let pline = substitute(pline, '\\\@<!\(\\\\\)*\zs%.*', '', '')
	" Strip leading whitespace
	let pline = substitute(pline, '^\s*', '', '')

	" Compute the deepest indentation on the current line
	let cindent = s:DeepestNesting( cline )

	" Compute the offset to the deepest indentation from the previous line
	if can_use_cache && s:cache_lnum == plnum && s:cache_line ==# pline
		let pindent = s:cache_indent
	else
		let pindent = s:DeepestNesting( pline )
	endif

	" Cache the result of the current line
	let s:cache_lnum   = clnum
	let s:cache_indent = cindent
	let s:cache_line   = cline

	" Add one shiftwidth per indentation level
	let ind = pind + &shiftwidth * ( cindent[0] + pindent[1] )

	return ind
endfunction
" }}}
