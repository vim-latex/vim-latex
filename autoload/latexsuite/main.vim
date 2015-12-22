" Tex_Strntok: extract the n^th token from a list {{{
" example: Strntok('1,23,3', ',', 2) = 23
fun! latexsuite#main#Tex_Strntok(s, tok, n)
	return matchstr( a:s.a:tok[0], '\v(\zs([^'.a:tok.']*)\ze['.a:tok.']){'.a:n.'}')
endfun

" }}}
" Tex_GetVarValue: gets the value of the variable {{{
" Description:
" 	See if a window-local, buffer-local or global variable with the given name
" 	exists and if so, returns the corresponding value. If none exist, return
" 	an empty string.
function! latexsuite#main#Tex_GetVarValue(varname, ...)
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
function! latexsuite#main#Tex_CreatePrompt(promptList, cols, sep)

	let g:listSep = a:sep
	let num_common = GetListCount(a:promptList)

	let i = 1
	let promptStr = ""

	while i <= num_common

		let j = 0
		while j < a:cols && i + j <= num_common
			let com = latexsuite#main#Tex_Strntok(a:promptList, a:sep, i+j)
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
" Tex_ChooseFromPrompt: process a user input to a prompt string {{{
" " Description:
function! latexsuite#main#Tex_ChooseFromPrompt(dialog, list, sep)
	let g:Tex_ASDF = a:dialog
	let inp = input(a:dialog)
	if inp =~ '\d\+'
		return latexsuite#main#Tex_Strntok(a:list, a:sep, inp)
	else
		return inp
	endif
endfunction " }}}

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4:nowrap
