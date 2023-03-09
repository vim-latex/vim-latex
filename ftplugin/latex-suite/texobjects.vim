" Taken from grew's grew/vim-conf-gerw/ftplugin/tex.vim
" Create word objects {{{

" Inline-math text objects (similar to "aw" [a word] and "iw" [inner word])
" a$ selects / use including limiting $
" i$ selects / use excluding limiting $
" BUG / FEATURE:
" If you have "$1+1$ here is the cursor $2+2$", then "da$" results in "$1+12+2$"
onoremap <silent> i$ :<c-u>normal! T$vt$<cr>
onoremap <silent> a$ :<c-u>normal! F$vf$<cr>
vnoremap <silent> i$ :<c-u>normal! T$vt$<cr>
vnoremap <silent> a$ :<c-u>normal! F$vf$<cr>


" Text objects corresponding to latex environments
onoremap <silent>ae :<C-u>call LatexEnvironmentTextObject(0)<CR>
onoremap <silent>ie :<C-u>call LatexEnvironmentTextObject(1)<CR>
vnoremap <silent>ae :<C-u>call LatexEnvironmentTextObject(0)<CR>
vnoremap <silent>ie :<C-u>call LatexEnvironmentTextObject(1)<CR>

function! LatexEnvironmentTextObject(inner)
	let b:my_count = v:count
	let b:my_inner = a:inner

	let startstring = '\\begin{\w*\*\?}'
	let endstring = '\\end{\w*\*\?}\zs'
	let skipexpr = ''

	" Determine start of environment
	call searchpair(startstring, '', endstring, 'bcW', skipexpr)
	for i in range( v:count1 - 1)
		call searchpair(startstring, '', endstring, 'bW', skipexpr)
	endfor


	" Start selecting
	normal! V

	" Determine end of environment
	" normal! ^
	call searchpair(startstring, '', endstring, 'W', skipexpr)
	normal! ^

	if a:inner == 1
		normal! ojok
	end

endfunction
