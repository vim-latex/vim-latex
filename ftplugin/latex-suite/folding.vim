"=============================================================================
" 	     File: folding.vim
"      Author: Srinath Avadhanula
" 	  Version: 1.0 
"     Created: Tue Apr 23 05:00 PM 2002 PST
" Last Change: Tue Apr 23 05:00 PM 2002 PDT
" 
"  Description: functions to interact with Syntaxfolds.vim
"=============================================================================

" MakeTexFolds: function to create fold items for latex. {{{
"
" used in conjunction with MakeSyntaxFolds().
" see ../plugin/syntaxFolds.vim for documentation
"
function! MakeTexFolds(force)
	if exists('g:Tex_Folding') && !g:Tex_Folding
		return
	endif
	if &ft != 'tex'
		return
	end

	" the order in which these calls are made decides the nestedness. in
	" latex, a table environment will always be embedded in either an item or
	" a section etc. not the other way around. so we first fold up all the
	" tables. and then proceed with the other regions.

	let b:numFoldItems = 0

	" {{{ table
	call AddSyntaxFoldItem (
		\ '^\s*\\begin{table}',
		\ '^\s*\\end{table}',
		\ 0,
		\ 0
		\ )
	" }}}
	" {{{ figure
	call AddSyntaxFoldItem (
		\ '^\s*\\begin{figure',
		\ '^\s*\\end{figure}',
		\ 0,
		\ 0
		\ )
	" }}}
	" {{{ equation/eqnarray
	call AddSyntaxFoldItem (
		\ '^\s*\\begin{eq',
		\ '^\s*\\end{eq',
		\ 0,
		\ 0
		\ )
	" }}}
	" {{{ items
	call AddSyntaxFoldItem (
		\ '^\s*\\item',
		\ '^\s*\\item\|^\s*\\end{\(enumerate\|itemize\|description\)}',
		\ 0,
		\ -1,
		\ '^\s*\\begin{\(enumerate\|itemize\|description\)}',
		\ '^\s*\\end{\(enumerate\|itemize\|description\)}'
		\ )
	" }}}
	" {{{ subsubsection
	call AddSyntaxFoldItem (
		\ '^\s*\\subsubsection',
		\ '^\s*\\section\|^\s*\\subsection\|^\s*\\subsubsection\|^\s*\\end{document}',
		\ 0,
		\ -1,
		\ )
	" }}}
	" {{{ subsection
	call AddSyntaxFoldItem (
		\ '^\s*\\subsection',
		\ '^\s*\\section\|^\s*\\subsection\|^\s*\\end{document}',
		\ 0,
		\ -1,
		\ )
	" }}}
	" {{{ section
	call AddSyntaxFoldItem (
		\ '^\s*\\section',
		\ '^\s*\\section\|^\s*\\end{document}',
		\ 0,
		\ -1,
		\ )
	" }}}
	" {{{ chapter
	call AddSyntaxFoldItem (
		\ '^\s*\\chapter',
		\ '^\s*\\section',
		\ 0,
		\ -1
		\ )
	" }}}
	" {{{ slide
	call AddSyntaxFoldItem (
		\ '^\s*\\begin{slide',
		\ '^\s*\\end{slide',
		\ 0,
		\ 0
		\ )
	" }}}

	call MakeSyntaxFolds(a:force)
	normal! zv
endfunction

" }}}
" TexFoldTextFunction: create fold text for folds {{{
function! TexFoldTextFunction()
	if getline(v:foldstart) =~ '^\s*\\begin{'
		let header = matchstr(getline(v:foldstart), '^\s*\\begin{\zs\(figure\|table\|equation\|eqnarray\)[^}]*\ze}')

		let caption = ''
		let label = ''
		let i = v:foldstart
		while i <= v:foldend
			if getline(i) =~ '\\caption'
				let caption = matchstr(getline(i), '\\caption{\zs.*')
				let caption = substitute(caption, '\zs}[^}]*$', '', '')
			elseif getline(i) =~ '\\label'
				let label = matchstr(getline(i), '\\label{\zs.*')
				let label = substitute(label, '\zs}[^}]*$', '', '')
			end

			let i = i + 1
		endwhile

		let ftxto = foldtext()
		" if no caption found, then use the second line.
		if caption == ''
			let caption = getline(v:foldstart + 1)
		end

		let retText = matchstr(ftxto, '^[^:]*').': '.header.' ('.label.') : '.caption
		return retText
	else
		return foldtext()
	end
endfunction
" }}}

" vim:fdm=marker:ts=4:sw=4:noet
