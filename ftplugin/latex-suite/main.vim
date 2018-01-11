" LaTeX filetype
"	  Language: LaTeX (ft=tex)
"	Maintainer: Srinath Avadhanula
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
runtime ftplugin/tex/texrc
" set up global defaults.
exe "so ".fnameescape(s:path.'/texrc')

" }}}

nmap <silent> <script> <plug> i
imap <silent> <script> <C-o><plug> <Nop>

" ==============================================================================
" mappings
" ==============================================================================
" {{{
" calculate the mapleader character.
let s:ml = '<Leader>'

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
	call IMAP ('==', '&= ', "tex")
	call IMAP ('~~', '&\approx ', "tex")
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
	if !g:Tex_SmartKeyDot
		call IMAP (g:Tex_Leader.'.', '\cdot', "tex")
	end
	call IMAP (g:Tex_Leader.'*', '\times', "tex")
	call IMAP (g:Tex_Leader.'&', '\wedge', "tex")
	call IMAP (g:Tex_Leader.'-', '\bigcap', "tex")
	call IMAP (g:Tex_Leader.'+', '\bigcup', "tex")
	call IMAP (g:Tex_Leader.'M', '\sum_{<++>}^{<++>}<++>', 'tex')
	call IMAP (g:Tex_Leader.'S', '\sum_{<++>}^{<++>}<++>', 'tex')
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
	call IMAP(g:Tex_Leader.'a', '\alpha', 'tex')
	call IMAP(g:Tex_Leader.'b', '\beta', 'tex')
	call IMAP(g:Tex_Leader.'c', '\chi', 'tex')
	call IMAP(g:Tex_Leader.'d', '\delta', 'tex')
	call IMAP(g:Tex_Leader.'e', '\varepsilon', 'tex')
	call IMAP(g:Tex_Leader.'f', '\varphi', 'tex')
	call IMAP(g:Tex_Leader.'g', '\gamma', 'tex')
	call IMAP(g:Tex_Leader.'h', '\eta', 'tex')
	call IMAP(g:Tex_Leader.'i', '\iota', 'tex')
	call IMAP(g:Tex_Leader.'k', '\kappa', 'tex')
	call IMAP(g:Tex_Leader.'l', '\lambda', 'tex')
	call IMAP(g:Tex_Leader.'m', '\mu', 'tex')
	call IMAP(g:Tex_Leader.'n', '\nu', 'tex')
	call IMAP(g:Tex_Leader.'p', '\pi', 'tex')
	call IMAP(g:Tex_Leader.'q', '\theta', 'tex')
	call IMAP(g:Tex_Leader.'r', '\rho', 'tex')
	call IMAP(g:Tex_Leader.'s', '\sigma', 'tex')
	call IMAP(g:Tex_Leader.'t', '\tau', 'tex')
	call IMAP(g:Tex_Leader.'u', '\upsilon', 'tex')
	call IMAP(g:Tex_Leader.'v', '\varsigma', 'tex')
	call IMAP(g:Tex_Leader.'w', '\omega', 'tex')
	call IMAP(g:Tex_Leader.'w', '\wedge', 'tex')  " AUCTEX style
	call IMAP(g:Tex_Leader.'x', '\xi', 'tex')
	call IMAP(g:Tex_Leader.'y', '\psi', 'tex')
	call IMAP(g:Tex_Leader.'z', '\zeta', 'tex')
	" not all capital greek letters exist in LaTeX!
	" reference: http://www.giss.nasa.gov/latex/ltx-405.html
	call IMAP(g:Tex_Leader.'D', '\Delta', 'tex')
	call IMAP(g:Tex_Leader.'F', '\Phi', 'tex')
	call IMAP(g:Tex_Leader.'G', '\Gamma', 'tex')
	call IMAP(g:Tex_Leader.'Q', '\Theta', 'tex')
	call IMAP(g:Tex_Leader.'L', '\Lambda', 'tex')
	call IMAP(g:Tex_Leader.'X', '\Xi', 'tex')
	call IMAP(g:Tex_Leader.'Y', '\Psi', 'tex')
	call IMAP(g:Tex_Leader.'S', '\Sigma', 'tex')
	call IMAP(g:Tex_Leader.'U', '\Upsilon', 'tex')
	call IMAP(g:Tex_Leader.'W', '\Omega', 'tex')
	" }}}
	" ProtectLetters: sets up identity maps for things like ``a {{{
	" " Description: If we simply do
	" 		call IMAP('`a', '\alpha', 'tex')
	" then we will never be able to type 'a' after a tex-quotation. Since
	" IMAP() always uses the longest map ending in the letter, this problem
	" can be avoided by creating a fake map for ``a -> ``a.
	" This function sets up fake maps of the following forms:
	" 	``[aA]  -> ``[aA]    (for writing in quotations)
	" 	\`[aA]  -> \`[aA]    (for writing diacritics)
	" 	"`[aA]  -> "`[aA]    (for writing german quotations)
	" It does this for all printable lower ascii characters just to make sure
	" we dont let anything slip by.
	function! s:ProtectLetters(first, last)
		for i in range(a:first, a:last)
			if nr2char(i) =~ '[[:print:]]'
				if ( g:Tex_SmartKeyDot && nr2char(i) == '.' )
							\ || ( g:Tex_SmartKeyQuote && nr2char(i) == '"' )
					continue
				endif
				call IMAP('``'.nr2char(i), '``'.nr2char(i), 'tex')
				call IMAP('\`'.nr2char(i), '\`'.nr2char(i), 'tex')
				call IMAP('"`'.nr2char(i), '"`'.nr2char(i), 'tex')
			endif
		endfor
	endfunction 
	call s:ProtectLetters(32, 127)
	" }}}
	" vmaps: enclose selected region in brackets, environments {{{ 
	" The action changes depending on whether the selection is character-wise
	" or line wise. for example, selecting linewise and pressing \v will
	" result in the region being enclosed in \begin{verbatim}, \end{verbatim},
	" whereas in characterise visual mode, the thingie is enclosed in \verb|
	" and |.
	exec 'xnoremap <silent> '.g:Tex_Leader."( \<C-\\>\<C-N>:call VEnclose('\\left( ', ' \\right)', '\\left(', '\\right)')\<CR>"
	exec 'xnoremap <silent> '.g:Tex_Leader."[ \<C-\\>\<C-N>:call VEnclose('\\left[ ', ' \\right]', '\\left[', '\\right]')\<CR>"
	exec 'xnoremap <silent> '.g:Tex_Leader."{ \<C-\\>\<C-N>:call VEnclose('\\left\\{ ', ' \\right\\}', '\\left\\{', '\\right\\}')\<CR>"
	exec 'xnoremap <silent> '.g:Tex_Leader."$ \<C-\\>\<C-N>:call VEnclose('$', '$', '\\[', '\\]')\<CR>"
	" }}}
end

" }}}

" ==============================================================================
" Helper functions for debugging
" ============================================================================== 
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

	" If 'Tex_DebugLog' is given, write debug information into this file
	" (preferred method).
	" Otherwise, save it in a variable
	if Tex_GetVarValue('Tex_DebugLog') != ''
		exec 'redir! >> '.Tex_GetVarValue('Tex_DebugLog')
		silent! echo pattern.' : '.a:str
		redir END
	else
		if !exists('s:debugString_'.pattern)
			let s:debugString_{pattern} = ''
		endif
		let s:debugString_{pattern} = s:debugString_{pattern}.a:str."\n"

		if !exists('s:debugString_')
			let s:debugString_ = ''
		endif
		let s:debugString_ = s:debugString_ . pattern.' : '.a:str."\n"
	endif
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

" ==============================================================================
" Helper functions for grepping
" ============================================================================== 
" Tex_Grep: shorthand for :vimgrep {{{
function! Tex_Grep(string, where)
	exec 'silent! vimgrep! /'.a:string.'/ '.a:where
endfunction

" }}}
" Tex_Grepadd: shorthand for :vimgrepadd {{{
function! Tex_Grepadd(string, where)
	exec 'silent! vimgrepadd! /'.a:string.'/ '.a:where
endfunction

" }}}


" ==============================================================================
" Uncategorized helper functions
" ============================================================================== 
" Tex_Strntok: extract the n^th token from a list {{{
" example: Strntok('1,23,3', ',', 2) = 23
fun! Tex_Strntok(s, tok, n)
	return matchstr( a:s.a:tok[0], '\v(\zs([^'.a:tok.']*)\ze['.a:tok.']){'.a:n.'}')
endfun

" }}}
" Tex_CountMatches: count number of matches of pat in string {{{
fun! Tex_CountMatches( string, pat )
	let pos = 0
	let cnt = 0
	while pos >= 0
		let pos = matchend(a:string, a:pat, pos)
		let cnt = cnt + 1
	endwhile
	" We have counted one match to much
	return cnt - 1
endfun

" }}}
" Tex_CreatePrompt: creates a prompt string {{{
" Description: 
" Arguments:
"     promptList: This is a string of the form:
"         'item1,item2,item3,item4'
"     cols: the number of columns in the resultant prompt
"     sep: the list seperator token
"
" Example:
" Tex_CreatePrompt('item1,item2,item3,item4', 2, ',')
" returns
" "(1) item1\t(2)item2\n(3)item3\t(4)item4"
"
" This string can be used in the input() function.
function! Tex_CreatePrompt(promptList, cols, sep)
	" There is one more item than matches of the seperator
	let num_common = Tex_CountMatches( a:promptList, a:sep ) + 1

	let i = 1
	let promptStr = ""

	while i <= num_common

		let j = 0
		while j < a:cols && i + j <= num_common
			let com = Tex_Strntok(a:promptList, a:sep, i+j)
			let promptStr = promptStr.'('.(i+j).') '. 
						\ com."\t".( strlen(com) < 4 ? "\t" : '' )

			let j = j + 1
		endwhile

		let promptStr = promptStr."\n"

		let i = i + a:cols
	endwhile
	return promptStr
endfunction 

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
" Tex_GetVarValue: gets the value of the variable {{{
" Description: 
" 	See if a window-local, buffer-local or global variable with the given name
" 	exists and if so, returns the corresponding value. If none exist, return
" 	an empty string.
function! Tex_GetVarValue(varname, ...)
	if exists('w:'.a:varname)
		return w:{a:varname}
	elseif exists('b:'.a:varname)
		return b:{a:varname}
	elseif exists('g:'.a:varname)
		return g:{a:varname}
	elseif a:0 > 0
		return a:1
	else
		return ''
	endif
endfunction " }}}
" Tex_GetMainFileName: gets the name of the main file being compiled. {{{
" Description:  returns the full path name of the main file.
"               This function checks for the existence of a .latexmain file
"               which might point to the location of a "main" latex file.
"               If .latexmain exists, then return the full path name of the
"               file being pointed to by it.
"
"               Otherwise, return the full path name of the current buffer.
"
"               You can supply an optional "modifier" argument to the
"               function, which will optionally modify the file name before
"               returning.
"               NOTE: From version 1.6 onwards, this function always trims
"               away the .latexmain part of the file name before applying the
"               modifier argument.
function! Tex_GetMainFileName(...)
	if a:0 > 0
		let modifier = a:1
	else
		let modifier = ':p'
	endif

	" If the user wants to use his own way to specify the main file name, then
	" use it straight away.
	if Tex_GetVarValue('Tex_MainFileExpression') != ''
		exec 'let retval = '.Tex_GetVarValue('Tex_MainFileExpression')
		return retval
	endif

	let l:origdir = fnameescape(getcwd())

	let dirmodifier = '%:p:h'
	let dirLast = fnameescape(expand(dirmodifier))
	exe 'cd '.dirLast

	" move up the directory tree until we find a .latexmain file.
	" TODO: Should we be doing this recursion by default, or should there be a
	"       setting?
	while glob('*.latexmain',v:true) == ''
		let dirmodifier = dirmodifier.':h'
		let dirNew = fnameescape(expand(dirmodifier))
		" break from the loop if we cannot go up any further.
		if dirNew == dirLast
			break
		endif
		let dirLast = dirNew
		exe 'cd '.dirLast
	endwhile

	let lheadfile = glob('*.latexmain',v:true)
	if lheadfile != ''
		" Remove the trailing .latexmain part of the filename... We never want
		" that.
		let lheadfile = fnamemodify(substitute(lheadfile, '\.latexmain$', '', ''), modifier)
	else
		" If we cannot find any main file, just modify the filename of the
		" current buffer.
		let lheadfile = expand('%'.modifier)
	endif

	exe 'cd '.l:origdir

	" NOTE: The caller of this function needs to escape the file name with
	"       fnameescape() . The reason its not done here is that escaping is not
	"       safe if this file is to be used as part of an external command on
	"       certain platforms.
	return lheadfile
endfunction 

" }}}
" Tex_ChooseFromPrompt: process a user input to a prompt string {{{
" " Description: 
function! Tex_ChooseFromPrompt(dialog, list, sep)
	let g:Tex_ASDF = a:dialog
	let inp = input(a:dialog)
	" This is a workaround for a bug(?) in vim, see
	" https://github.com/vim/vim/issues/778
	redraw
	if inp =~ '\d\+'
		return Tex_Strntok(a:list, a:sep, inp)
	else
		return inp
	endif
endfunction " }}}
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
" Tex_FindInDirectory: check if file exists in a directory {{{
" Description:	Checks if file exists in globpath(directory, ...) and cuts off
" 				the rest of returned names. This guarantees that sourced file
" 				is from $HOME.
"               If the argument a:rtp is set, we interpret a:directory as a
"               subdirectory of &rtp/ftplugin/latex-suite/.
"               If an optional argument is given, it specifies how to expand
"               each filename found. For example, '%:p' will return a list of
"               the complete paths to the files. By default returns trailing
"               path-names without extenions.
"               NOTE: This function is very slow when a large number of
"                     matches are found because of a while loop which modifies
"                     each filename found. Some speedup was acheived by using
"                     a tokenizer approach rather than using Tex_Strntok which
"                     would have been more obvious.
function! Tex_FindInDirectory(filename, rtp, directory, ...)
	" how to expand each filename. ':p:t:r' modifies each filename to its
	" trailing part without extension.
	let expand = (a:0 > 0 ? a:1 : ':p:t:r')
	" The pattern used... An empty filename should be regarded as '*'
	let pattern = (a:filename != '' ? a:filename : '*')

	if a:rtp
		let filelist = globpath(&rtp, 'ftplugin/latex-suite/'.a:directory.'/'.pattern)."\n"
	else
		let filelist = globpath(a:directory, pattern)."\n"
	endif

	if filelist == "\n"
		return ''
	endif

	if pattern !~ '\*'
		" If we are not looking for a 'real' pattern, we return the first
		" match.
		return fnamemodify(Tex_Strntok(filelist, "\n", 1), expand)
	endif

	" Now cycle through the files modifying each filename in the desired
	" manner.
	let retfilelist = ''
	let i = 1
	while 1
		" Extract the portion till the next newline. Then shorten the filelist
		" by removing till the newline.
		let nextnewline = stridx(filelist, "\n")
		if nextnewline == -1
			break
		endif
		let filename = strpart(filelist, 0, nextnewline)
		let filelist = strpart(filelist, nextnewline+1)

		" The actual modification.
		if fnamemodify(filename, expand) != ''
			let retfilelist = retfilelist.fnamemodify(filename, expand).","
		endif
		let i = i + 1
	endwhile

	return substitute(retfilelist, ',$', '', '')
endfunction

" }}}
" Tex_FindInRtp: check if file exists in &rtp {{{
" Description:	Wrapper around Tex_FindInDirectory, using a:rtp
function! Tex_FindInRtp(filename, directory, ...)
	return call("Tex_FindInDirectory", [ a:filename, 1, a:directory ] + a:000 )
endfunction

" }}}
" Tex_GetErrorList: returns vim's clist {{{
" Description: returns the contents of the error list available via the :clist
"              command.
function! Tex_GetErrorList()
	let _a = @a
	redir @a | silent! clist | redir END
	let errlist = @a
	call setreg("a", _a, "c")

	if errlist =~ 'E42: '
		let errlist = ''
	endif

	return errlist
endfunction " }}}
" Tex_GetTempName: get the name of a temporary file in specified directory {{{
" Description: Unlike vim's native tempname(), this function returns the name
"              of a temporary file in the directory specified. This enables
"              us to create temporary files in a specified directory.
function! Tex_GetTempName(dirname)
	let prefix = 'latexSuiteTemp'
	let slash = (a:dirname =~ '\\$\|/$' ? '' : '/')
	let i = 0
	while filereadable(a:dirname.slash.prefix.i.'.tex') && i < 1000
		let i = i + 1
	endwhile
	if filereadable(a:dirname.slash.prefix.i.'.tex')
		echoerr "Temporary file could not be created in ".a:dirname
		return ''
	endif
	return expand(a:dirname.slash.prefix.i.'.tex', ':p')
endfunction
" }}}
" Tex_MakeMap: creates a mapping from lhs to rhs if rhs is not already mapped {{{
" Description:  
function! Tex_MakeMap(lhs, rhs, mode, extraargs)
	if !hasmapto(a:rhs, a:mode)
		exec a:mode.'map '.a:extraargs.' '.a:lhs.' '.a:rhs
	endif
endfunction " }}}
" Tex_CD: cds to given directory escaping spaces if necessary {{{
" " Description: 
function! Tex_CD(dirname)
	exec 'cd '.fnameescape(a:dirname)
endfunction " }}}
" Tex_FindFile: finds a file in the vim's 'path' {{{
" Description: finds a file in vim's 'path'
function! Tex_FindFile(fname, path, suffixesadd)
	if exists('*findfile')
		let _suffixesadd = &suffixesadd
		let &suffixesadd = a:suffixesadd
		let retval = findfile(a:fname, a:path)
		let &suffixesadd = _suffixesadd
		if retval != ''
			" Convert to full path and return
			return fnamemodify(retval, ':p')
		endif
	else
		" split a new window so we do not screw with the current buffer. We
		" want to use the same filename each time so that multiple scratch
		" buffers are not created.
		let retval = ''
		silent! split __HOPEFULLY_THIS_FILE_DOES_NOT_EXIST__
		let _suffixesadd = &suffixesadd
		let _path = &path
		let &suffixesadd = a:suffixesadd
		let &path = a:path
		exec 'silent! find '.a:fname
		if bufname('%') != '__HOPEFULLY_THIS_FILE_DOES_NOT_EXIST__'
			let retval = expand('%:p')
		end
		silent! bdelete!
		let &suffixesadd = _suffixesadd
		let &path = _path
	endif
	return retval
endfunction " }}}
" Tex_GetPos: gets position of cursor {{{
function! Tex_GetPos()
	if exists('*getcurpos')
		return getcurpos()
	elseif exists('*getpos')
		return getpos('.')
	else
		return line('.').' | normal! '.virtcol('.').'|'
	endif
endfunction " }}}
" Tex_SetPos: sets position of cursor {{{
function! Tex_SetPos(pos)
	if exists('*setpos')
		call setpos('.', a:pos)
	else
		exec a:pos
	endif
endfunction " }}}
" s:RemoveLastHistoryItem: removes last search item from search history {{{
" Description: Execute this string to clean up the search history.
let s:RemoveLastHistoryItem = ':call histdel("/", -1)|let @/=g:Tex_LastSearchPattern'

" }}}
" VEnclose: encloses the visually selected region with given arguments {{{
" Description: allows for differing action based on visual line wise
"              selection or visual characterwise selection. preserves the
"              marks and search history.
function! VEnclose(vstart, vend, VStart, VEnd)
	" it is characterwise if
	" 1. characterwise selection and valid values for vstart and vend.
	" OR
	" 2. linewise selection and invalid values for VStart and VEnd
	if (visualmode() ==# 'v' && (a:vstart != '' || a:vend != '')) || (a:VStart == '' && a:VEnd == '')

		let newline = ""
		let _r = @r

		let normcmd = "normal! \<C-\>\<C-n>`<v`>\"_s"

		exe "normal! \<C-\>\<C-n>`<v`>\"ry"
		if @r =~ "\n$"
			let newline = "\n"
			let @r = substitute(@r, "\n$", '', '')
		endif

		" In exclusive selection, we need to select an extra character.
		if &selection == 'exclusive'
			let movement = 8
		else
			let movement = 7
		endif
		let normcmd = normcmd.
			\ a:vstart."!!mark!!".a:vend.newline.
			\ "\<C-\>\<C-N>?!!mark!!\<CR>v".movement."l\"_s\<C-r>r\<C-\>\<C-n>"

		" this little if statement is because till very recently, vim used to
		" report col("'>") > length of selected line when `> is $. on some
		" systems it reports a -ve number.
		if col("'>") < 0 || col("'>") > strlen(getline("'>"))
			let lastcol = strlen(getline("'>"))
		else
			let lastcol = col("'>")
		endif
		if lastcol - col("'<") != 0
			let len = lastcol - col("'<")
		else
			let len = ''
		endif

		" the next normal! is for restoring the marks.
		let normcmd = normcmd."`<v".len."l\<C-\>\<C-N>"

		" First remember what the search pattern was. s:RemoveLastHistoryItem
		" will reset @/ to this pattern so we do not create new highlighting.
		let g:Tex_LastSearchPattern = @/

		silent! exe normcmd
		" this is to restore the r register.
		call setreg("r", _r, "c")
		" and finally, this is to restore the search history.
		execute s:RemoveLastHistoryItem

	else

		exec 'normal! `<O'.a:VStart."\<C-\>\<C-n>"
		exec 'normal! `>o'.a:VEnd."\<C-\>\<C-n>"
		if &indentexpr != ''
			silent! normal! `<kV`>j=
		endif
		silent! normal! `>
	endif
endfunction

" }}}
" ExecMap: adds the ability to correct an normal/visual mode mapping.  {{{
" Author: Hari Krishna Dara <hari_vim@yahoo.com>
" Reads a normal mode mapping at the command line and executes it with the
" given prefix. Press <BS> to correct and <Esc> to cancel.
nnoremap <silent> <script> <plug><+SelectRegion+> `<v`>

function! ExecMap(prefix, mode)
	" Temporarily remove the mapping, otherwise it will interfere with the
	" mapcheck call below:
	let myMap = maparg(a:prefix, a:mode)
	exec a:mode."unmap ".a:prefix

	" Generate a line with spaces to clear the previous message.
	let i = 1
	let clearLine = "\r"
	while i < &columns
		let clearLine = clearLine . ' '
		let i = i + 1
	endwhile

	let mapCmd = a:prefix
	let foundMap = 0
	let breakLoop = 0
	echon "\rEnter Map: " . mapCmd
	while !breakLoop
		let char = getchar()
		if char !~ '^\d\+$'
			if char == "\<BS>"
				let mapCmd = s:MultiByteWOLastCharacter(mapCmd)
			endif
		else " It is the ascii code.
			let char = nr2char(char)
			if char == "\<Esc>"
				let breakLoop = 1
			else
				let mapCmd = mapCmd . char
				if maparg(mapCmd, a:mode) != ""
					let foundMap = 1
					let breakLoop = 1
				elseif mapcheck(mapCmd, a:mode) == ""
					let mapCmd = s:MultiByteWOLastCharacter(mapCmd)
				endif
			endif
		endif
		echon clearLine
		echon "\rEnter Map: " . mapCmd
	endwhile
	if foundMap
		if a:mode == 'v'
			" use a plug to select the region instead of using something like
			" `<v`> to avoid problems caused by some of the characters in
			" '`<v`>' being mapped.
			let gotoc = "\<plug><+SelectRegion+>"
		else
			let gotoc = ''
		endif
		exec "normal ".gotoc.mapCmd
	endif
	exec a:mode.'noremap '.a:prefix.' '.myMap
endfunction

" }}}
" s:MultiByteWOLastCharacter: Return string without last multibyte character {{{
function! s:MultiByteWOLastCharacter(str)
	return substitute(a:str, ".$", "", "")
endfunction " }}}


" ==============================================================================
" Smart key-mappings
" ============================================================================== 
" TexQuotes: inserts `` or '' instead of " {{{
if g:Tex_SmartKeyQuote

	" TexQuotes: inserts `` or '' instead of "
	" Taken from texmacro.vim by Benji Fisher <benji@e-math.AMS.org>
	" TODO:  Deal with nested quotes.
	" The :imap that calls this function should insert a ", move the cursor to
	" the left of that character, then call this with <C-R>= .
	function! s:TexQuotes()
		let l = line(".")
		let c = col(".")
		let restore_cursor = l . "G" . virtcol(".") . "|"
		normal! H
		let restore_cursor = "normal!" . line(".") . "Gzt" . restore_cursor
		execute restore_cursor
		" In math mode, or when preceded by a \, just move the cursor past the
		" already-inserted " character.
		if synIDattr(synID(l, c, 1), "name") =~ "^texMath"
			\ || (c > 1 && getline(l)[c-2] == '\')
			return "\<Right>"
		endif
		" Find the appropriate open-quote and close-quote strings.
		if exists("b:Tex_SmartQuoteOpen")
			let open = b:Tex_SmartQuoteOpen
		elseif exists("g:Tex_SmartQuoteOpen")
			let open = g:Tex_SmartQuoteOpen
		else
			let open = "``"
		endif
		if exists("b:Tex_SmartQuoteClose")
			let close = b:Tex_SmartQuoteClose
		elseif exists("g:Tex_SmartQuoteClose")
			let close = g:Tex_SmartQuoteClose
		else
			let close = "''"
		endif
		let boundary = '\|'
		" This code seems to be obsolete, since this script variable is never
		" set. The idea is that some languages use ",," as an open- or
		" close-quote string, and we want to avoid confusing ordinary ","
		" with a quote boundary.
		if exists("s:TeX_strictquote")
			if( s:TeX_strictquote == "open" || s:TeX_strictquote == "both" )
				let boundary = '\<' . boundary
			endif
			if( s:TeX_strictquote == "close" || s:TeX_strictquote == "both" )
				let boundary = boundary . '\>'
			endif
		endif

		" Eventually return q; set it to the default value now.
		let q = open
		let pattern = 
			\ escape(open, '\~') .
			\ boundary .
			\ escape(close, '\~') .
			\ '\|^$\|"'

		while 1	" Look for preceding quote (open or close), ignoring
			" math mode and '\"' .
			call search(pattern, "bw")
			if synIDattr(synID(line("."), col("."), 1), "name") !~ "^texMath"
				\ && strpart(getline('.'), col('.')-2, 2) != '\"'
				break
			endif
		endwhile
		
		" Now, test whether we actually found a _preceding_ quote; if so, is it
		" an open quote?
		if ( line(".") < l || line(".") == l && col(".") < c )
			if strpart(getline("."), col(".")-1) =~ '\V\^' . escape(open, '\')
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
	let s:smartBS_pat = Tex_GetVarValue('Tex_SmartBSPattern')

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
" if amsmath package is detected then just use \dots and let amsmath take care
" of it.
if g:Tex_SmartKeyDot

	function! <SID>SmartDots()
		if strpart(getline('.'), col('.')-3, 2) == '..' && 
			\ g:Tex_package_detected =~ '\<amsmath\|ellipsis\>'
			return "\<bs>\<bs>\\dots"
		elseif synIDattr(synID(line('.'),col('.')-1,0),"name") =~ '^texMath'
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


" Python detection: Tex_UsePython(), Tex_HasPython, Tex_Python[File]Cmd {{{
if has('python3')
	let g:Tex_HasPython = 3
	let g:Tex_PythonCmd = 'python3'
	let g:Tex_PythonFileCmd = 'py3file'
elseif has('python')
	let g:Tex_HasPython = 2
	let g:Tex_PythonCmd = 'python'
	let g:Tex_PythonFileCmd = 'pyfile'
else
	let g:Tex_HasPython = 0
end
function! Tex_UsePython()
	return g:Tex_HasPython && Tex_GetVarValue('Tex_UsePython')
endfunction
" }}}

" source texproject.vim before other files
exe 'source '.fnameescape(s:path.'/texproject.vim')

" source all the relevant files.
exe 'source '.fnameescape(s:path.'/texmenuconf.vim')
exe 'source '.fnameescape(s:path.'/envmacros.vim')
exe 'source '.fnameescape(s:path.'/elementmacros.vim')

" source utf-8 or plain math menus
if exists("g:Tex_UseUtfMenus") && g:Tex_UseUtfMenus != 0 && has("gui_running")
	exe 'source '.fnameescape(s:path.'/mathmacros-utf.vim')
else
	exe 'source '.fnameescape(s:path.'/mathmacros.vim')
endif

exe 'source '.fnameescape(s:path.'/multicompile.vim')
exe 'source '.fnameescape(s:path.'/compiler.vim')
exe 'source '.fnameescape(s:path.'/folding.vim')
exe 'source '.fnameescape(s:path.'/templates.vim')
exe 'source '.fnameescape(s:path.'/custommacros.vim')
exe 'source '.fnameescape(s:path.'/bibtex.vim')

" source advanced math functions
exe 'source '.fnameescape(s:path.'/brackets.vim')

exe 'source '.fnameescape(s:path.'/smartspace.vim')

if g:Tex_Diacritics != 0
	exe 'source '.fnameescape(s:path.'/diacritics.vim')
endif

exe 'source '.fnameescape(s:path.'/texviewer.vim')
exe 'source '.fnameescape(s:path.'/version.vim')

" ==============================================================================
" Finally set up the folding, options, mappings and quit.
" ============================================================================== 
" SetTeXOptions: sets options/mappings for this file. {{{
function! <SID>SetTeXOptions()
	" Avoid reinclusion.
	if exists('b:doneSetTeXOptions')
		return
	endif
	let b:doneSetTeXOptions = 1

	exe 'setlocal dict^='.fnameescape(s:path.'/dictionaries/dictionary')

	call Tex_Debug('SetTeXOptions: sourcing maps', 'main')
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

	" This line seems to be necessary to source our compiler/tex.vim file.
	" The docs are unclear why this needs to be done even though this file is
	" the first compiler plugin in 'runtimepath'.
	runtime compiler/tex.vim

endfunction

augroup LatexSuite
	au LatexSuite User LatexSuiteFileType 
		\ call Tex_Debug('main.vim: Catching LatexSuiteFileType event', 'main') | 
		\ call <SID>SetTeXOptions()
augroup END

" }}}

" ==============================================================================
" Settings for taglist.vim plugin
" ============================================================================== 
" Sets Tlist_Ctags_Cmd for taglist.vim and regexps for ctags {{{
if exists("g:Tex_TaglistSupport") && g:Tex_TaglistSupport == 1 
	if !exists("g:tlist_tex_settings") 
		let g:tlist_tex_settings = 'tex;s:section;c:chapter;l:label;r:ref'
	endif

	if exists("Tlist_Ctags_Cmd")
		let s:tex_ctags = Tlist_Ctags_Cmd
	else
		let s:tex_ctags = 'ctags' " Configurable in texrc?
	endif

	if exists("g:Tex_InternalTagsDefinitions") && g:Tex_InternalTagsDefinitions == 1
		let Tlist_Ctags_Cmd = s:tex_ctags ." --langdef=tex --langmap=tex:.tex.ltx.latex"
		\.' --regex-tex="/\\\\begin{abstract}/Abstract/s,abstract/"'
		\.' --regex-tex="/\\\\part[ \t]*\*?\{[ \t]*([^}]*)\}/\1/s,part/"'
		\.' --regex-tex="/\\\\chapter[ \t]*\*?\{[ \t]*([^}]*)\}/\1/s,chapter/"'
		\.' --regex-tex="/\\\\section[ \t]*\*?\{[ \t]*([^}]*)\}/\1/s,section/"'
		\.' --regex-tex="/\\\\subsection[ \t]*\*?\{[ \t]*([^}]*)\}/+ \1/s,subsection/"'
		\.' --regex-tex="/\\\\subsubsection[ \t]*\*?\{[ \t]*([^}]*)\}/+  \1/s,subsubsection/"'
		\.' --regex-tex="/\\\\paragraph[ \t]*\*?\{[ \t]*([^}]*)\}/+   \1/s,paragraph/"'
		\.' --regex-tex="/\\\\subparagraph[ \t]*\*?\{[ \t]*([^}]*)\}/+    \1/s,subparagraph/"'
		\.' --regex-tex="/\\\\begin{thebibliography}/BIBLIOGRAPHY/s,thebibliography/"'
		\.' --regex-tex="/\\\\tableofcontents/TABLE OF CONTENTS/s,tableofcontents/"'
		\.' --regex-tex="/\\\\frontmatter/FRONTMATTER/s,frontmatter/"'
		\.' --regex-tex="/\\\\mainmatter/MAINMATTER/s,mainmatter/"'
		\.' --regex-tex="/\\\\backmatter/BACKMATTER/s,backmatter/"'
		\.' --regex-tex="/\\\\appendix/APPENDIX/s,appendix/"'
		\.' --regex-tex="/\\\\label[ \t]*\*?\{[ \t]*([^}]*)\}/\1/l,label/"'
		\.' --regex-tex="/\\\\ref[ \t]*\*?\{[ \t]*([^}]*)\}/\1/r,ref/"'
	endif
endif

" }}}
 
" commands to completion
let g:Tex_completion_explorer = ','

" Mappings defined in package files will overwrite all other
exe 'source '.fnameescape(s:path.'/packages.vim')

" ==============================================================================
" These functions are used to immitate certain operating system type functions
" (like reading the contents of a file), which are not available in vim. For
" example, in Vim, its not possible to read the contents of a file without
" opening a buffer on it, which means that over time, lots of buffers can open
" up needlessly.
"
" If python is available (and allowed), then these functions utilize python
" library functions without making calls to external programs.
" ============================================================================== 
" Tex_GotoTempFile: open a temp file. reuse from next time on {{{
function! Tex_GotoTempFile()
	if !exists('s:tempFileName')
		let s:tempFileName = tempname()
	endif
	exec 'silent! split '.s:tempFileName
endfunction " }}}
" Tex_IsPresentInFile: finds if a regexp, is present in filename {{{
if Tex_UsePython()
	function! Tex_IsPresentInFile(regexp, filename)
		exec g:Tex_PythonCmd . ' isPresentInFile(r"'.a:regexp.'", r"'.a:filename.'")'

		return retval
	endfunction
else
	function! Tex_IsPresentInFile(regexp, filename)
		call Tex_GotoTempFile()

		silent! 1,$ d _
		let _report = &report
		let _sc = &sc
		set report=9999999 nosc
		exec 'silent! 0r! '.g:Tex_CatCmd.' '.a:filename
		set nomod
		let &report = _report
		let &sc = _sc

		" Use very magic to digest usual regular expressions.
		if search('\v' . a:regexp, 'w')
			let retval = 1
		else
			let retval = 0
		endif
		silent! bd
		return retval
	endfunction
endif " }}}
" Tex_CatFile: returns the contents of a file in a <NL> seperated string {{{
if exists('*readfile')
	function! Tex_CatFile(filename)
		if glob(a:filename) == ''
			return ''
		endif
		return join(readfile(a:filename), "\n")
	endfunction
elseif Tex_UsePython()
	function! Tex_CatFile(filename)
		" catFile assigns a value to retval
		exec g:Tex_PythonCmd . ' catFile("'.a:filename.'")'

		return retval
	endfunction
else
	function! Tex_CatFile(filename)
		if glob(a:filename) == ''
			return ''
		endif

		call Tex_GotoTempFile()

		silent! 1,$ d _

		let _report = &report
		let _sc = &sc
		set report=9999999 nosc
		exec 'silent! 0r! '.g:Tex_CatCmd.' '.a:filename

		set nomod
		let _a = @a
		silent! normal! ggVG"ay
		let retval = @a
		call setreg("a", _a, "c")

		silent! bd
		let &report = _report
		let &sc = _sc
		return retval
	endfunction
endif
" }}}
" Tex_DeleteFile: removes a file if present {{{
" Description: 
if Tex_UsePython()
	function! Tex_DeleteFile(filename)
		exec g:Tex_PythonCmd . ' deleteFile(r"'.a:filename.'")'
		
		if exists('retval')
			return retval
		endif
	endfunction 
else
	function! Tex_DeleteFile(filename)
		if filereadable(a:filename)
			exec '! '.g:Tex_RmCmd.' '.a:filename
		endif
	endfunction
endif
" }}}


let &cpo = s:save_cpo

" Define the functions in python if available.
if Tex_UsePython()
	exec g:Tex_PythonFileCmd . ' ' . fnameescape(expand('<sfile>:p:h')).'/pytools.py'
endif

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4:nowrap
