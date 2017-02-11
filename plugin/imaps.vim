"        File: imaps.vim
"     Authors: Srinath Avadhanula <srinath AT fastmail.fm>
"              Benji Fisher <benji AT member.AMS.org>
"              
" Description: insert mode template expander with cursor placement
"              while preserving filetype indentation.
"
"
" Documentation: {{{
"
" Motivation:
" this script provides a way to generate insert mode mappings which do not
" suffer from some of the problem of mappings and abbreviations while allowing
" cursor placement after the expansion. It can alternatively be thought of as
" a template expander. 
"
" Consider an example. If you do
"
" imap lhs something
"
" then a mapping is set up. However, there will be the following problems:
" 1. the 'ttimeout' option will generally limit how easily you can type the
"    lhs. if you type the left hand side too slowly, then the mapping will not
"    be activated.
" 2. if you mistype one of the letters of the lhs, then the mapping is
"    deactivated as soon as you backspace to correct the mistake.
"
" If, in order to take care of the above problems, you do instead
"
" iab lhs something
"
" then the timeout problem is solved and so is the problem of mistyping.
" however, abbreviations are only expanded after typing a non-word character.
" which causes problems of cursor placement after the expansion and invariably
" spurious spaces are inserted.
" 
" Usage Example:
" this script attempts to solve all these problems by providing an emulation
" of imaps wchich does not suffer from its attendant problems. Because maps
" are activated without having to press additional characters, therefore
" cursor placement is possible. furthermore, file-type specific indentation is
" preserved, because the rhs is expanded as if the rhs is typed in literally
" by the user.
"  
" Each "mapping" is of the form:
"
" call IMAP (lhs, rhs, ft)
" 
" Some characters in the RHS have special meaning which help in cursor
" placement.
"
" Example One:
"
" 	call IMAP ("bit`", "\\begin{itemize}\<cr>\\item <++>\<cr>\\end{itemize}<++>", "tex")
" 
" This effectively sets up the map for "bit`" whenever you edit a latex file.
" When you type in this sequence of letters, the following text is inserted:
" 
" \begin{itemize}
" \item *
" \end{itemize}<++>
"
" where * shows the cursor position. The cursor position after inserting the
" text is decided by the position of the first "place-holder". Place holders
" are special characters which decide cursor placement and movement. In the
" example above, the place holder characters are <+ and +>. After you have typed
" in the item, press <C-j> and you will be taken to the next set of <++>'s.
" Therefore by placing the <++> characters appropriately, you can minimize the
" use of movement keys.
"
" NOTE: Set g:Imap_UsePlaceHolders to 0 to disable placeholders altogether.
" Set 
" 	g:Imap_PlaceHolderStart and g:Imap_PlaceHolderEnd
" to something else if you want different place holder characters.
" Also, b:Imap_PlaceHolderStart and b:Imap_PlaceHolderEnd override the values
" of g:Imap_PlaceHolderStart and g:Imap_PlaceHolderEnd respectively. This is
" useful for setting buffer specific place hoders.
" 
" Example Two:
" You can use the <C-r> command to insert dynamic elements such as dates.
"	call IMAP ('date`', "\<c-r>=strftime('%b %d %Y')\<cr>", '')
"
" sets up the map for date` to insert the current date.
" }}}

if exists('b:suppress_latex_suite') && b:suppress_latex_suite == 1
	finish
endif

" line continuation used here.
let s:save_cpo = &cpo
set cpo&vim

" ==============================================================================
" Script Options / Variables
" ============================================================================== 
" Options {{{
if !exists('g:Imap_StickyPlaceHolders')
	let g:Imap_StickyPlaceHolders = 1
endif
if !exists('g:Imap_DeleteEmptyPlaceHolders')
	let g:Imap_DeleteEmptyPlaceHolders = 1
endif
if !exists('g:Imap_GoToSelectMode')
	let g:Imap_GoToSelectMode = 1
endif
" }}}
" Variables {{{
" s:LHS_{ft}_{char} will be generated automatically.  It will look like
" s:LHS_tex_o = 'fo\|foo\|boo' and contain all mapped sequences ending in "o".
"
" s:Map_{ft}_{lhs} will be generated automatically.  It will look like
" s:Map_c_foo = 'for(<++>; <++>; <++>)', the mapping for "foo".
"
" s:LHS_{ft} will be generated automatically. It contains all chars for which
" s:LHS_{ft}_{char} is not empty.
"
" b:IMAP_imaps will be generated automatically. It contains all chars which
" were mapped in the current buffer.
"
" }}}

" ==============================================================================
" functions for easy insert mode mappings.
" ==============================================================================
" IMAP: Adds a "fake" insert mode mapping. {{{
"       For example, doing
"           IMAP('abc', 'def' ft) 
"       will mean that if the letters abc are pressed in insert mode, then
"       they will be replaced by def. If ft != '', then the "mapping" will be
"       buffer local. You have to call IMAP_infect() on new buffers of type ft.
"
"       Using IMAP has a few advantages over simply doing:
"           imap abc def
"       1. with imap, if you begin typing abc, the cursor will not advance and
"          long as there is a possible completion, the letters a, b, c will be
"          displayed on on top of the other. using this function avoids that.
"       2. with imap, if a backspace or arrow key is pressed before completing
"          the word, then the mapping is lost. this function allows movement. 
"          (this ofcourse means that this function is only limited to
"          left-hand-sides which do not have movement keys or unprintable
"          characters)
"       It works by only mapping the last character of the left-hand side.
"       when this character is typed in, then a reverse lookup is done and if
"       the previous characters consititute the left hand side of the mapping,
"       the previously typed characters and erased and the right hand side is
"       inserted

" IMAP: set up a filetype specific mapping.
" Description:
"   "maps" the lhs to rhs in files of type 'ft'. If supplied with 2
"   additional arguments, then those are assumed to be the placeholder
"   characters in rhs. If unspecified, then the placeholder characters
"   are assumed to be '<+' and '+>' These placeholder characters in
"   a:rhs are replaced with the users setting of
"   [bg]:Imap_PlaceHolderStart and [bg]:Imap_PlaceHolderEnd settings.
"
function! IMAP(lhs, rhs, ft, ...)

	" Find the place holders to save for IMAP_PutTextWithMovement() .
	if a:0 < 2
		let phs = '<+'
		let phe = '+>'
	else
		let phs = a:1
		let phe = a:2
	endif

	let hash = s:Hash(a:lhs)
	let s:Map_{a:ft}_{hash} = a:rhs
	let s:phs_{a:ft}_{hash} = phs
	let s:phe_{a:ft}_{hash} = phe

	" Add a:lhs to the list of left-hand sides that end with lastLHSChar:
	let lastLHSChar = s:MultiByteLastCharacter(a:lhs)
	let hash = s:Hash(lastLHSChar)
	if !exists("s:LHS_" . a:ft . "_" . hash)
		let s:LHS_{a:ft}_{hash} = escape(a:lhs, '\')
	else
		" Check whether this lhs is already mapped.
		if a:lhs !~# '\V\^\%(' . s:LHS_{a:ft}_{hash} . '\)\$'
			let s:LHS_{a:ft}_{hash} = escape(a:lhs, '\') .'\|'.  s:LHS_{a:ft}_{hash}
		endif
	endif

	" Add lastLHSChar to s:LHS_{ft}
	if a:ft != ''
		if !exists('s:LHS_'.a:ft)
			let s:LHS_{a:ft} = []
		endif
		if index(s:LHS_{a:ft}, lastLHSChar) < 0
			call add(s:LHS_{a:ft}, lastLHSChar )
		endif
	endif

	" Only add a imap if it is a global IMAP or we are in the correct filetype
	" (then, we add a <buffer>-local imap, other buffers have to be infected
	" with IMAP_infect).
	if a:ft != ''
		if &ft == a:ft
			let buffer = '<buffer>'
		else
			return
		endif
	else
		let buffer = ''
	endif

	" map only the last character of the left-hand side.
	call s:IMAP_add_imap( lastLHSChar, buffer )
endfunction

" }}}
" IUNMAP: Removes a "fake" insert mode mapping. {{{
function! IUNMAP(lhs, ft)
	let lastLHSChar = s:MultiByteLastCharacter(a:lhs)
	let charHash = s:Hash(lastLHSChar)

	" Check whether the mapping exists
	if exists("s:LHS_" . a:ft . "_" . charHash)
				\ && a:lhs =~# '\V\^\%(' . s:LHS_{a:ft}_{charHash} . '\)\$'

		" Remove lhs from the list of mappings
		let s:LHS_{a:ft}_{charHash} = substitute(s:LHS_{a:ft}_{charHash},
					\ '\V\(\^\|\\|\)' . escape(escape(a:lhs, '\'), '\') . '\(\$\|\\|\)',
					\ '\\|', '')

		" Remove leading/trailing '\|'
		let s:LHS_{a:ft}_{charHash} = substitute(s:LHS_{a:ft}_{charHash}, '^\\|\|\\|$', '', '')

		let hash = s:Hash(a:lhs)
		unlet s:Map_{a:ft}_{hash}
		unlet s:phs_{a:ft}_{hash}
		unlet s:phe_{a:ft}_{hash}

		if strlen(s:LHS_{a:ft}_{charHash}) == 0
			" No more mappings left for this lastLHSChar.
			let idx = index(s:LHS_{a:ft}, lastLHSChar)
			if idx >= 0
				call remove(s:LHS_{a:ft}, idx )
			endif

			" Check for ft and unmap the last character of the left-hand side.
			" (if ft is set, other buffers with the same ft have to be updated with
			" IMAP_desinfect() and IMAP_infect()).
			if a:ft != ''
				if &ft == a:ft
					call s:IMAP_rm_imap( lastLHSChar, '<buffer>' )
				endif
			else
				call s:IMAP_rm_imap( lastLHSChar, '' )
			endif
		endif

	else
		" a:lhs is not mapped!
		" Do nothing.
	endif
endfunction
" }}}
" IMAP_infect: Infect the current buffer with ft IMAPS. {{{
function! IMAP_infect()
	if &ft != '' && exists('s:LHS_'.&ft)
		for lastLHSChar in s:LHS_{&ft}
			call s:IMAP_add_imap( lastLHSChar, '<buffer>' )
		endfor
	endif
endfunction
" }}}
" IMAP_desinfect: Desinfect the current buffer with ft IMAPS. {{{
function! IMAP_desinfect()
	if exists('b:IMAP_imaps')
		for lastLHSChar in copy(b:IMAP_imaps)
			call s:IMAP_rm_imap( lastLHSChar, '<buffer>' )
		endfor
	endif
endfunction
" }}}
" IMAP_list:  list the rhs and place holders corresponding to a:lhs {{{
"
" Added mainly for debugging purposes, but maybe worth keeping.
function! IMAP_list(lhs)
	let char = s:MultiByteLastCharacter(a:lhs)
	let charHash = s:Hash(char)
	if exists("s:LHS_" . &ft ."_". charHash)
				\ && a:lhs =~# '\V\^\%(' . s:LHS_{&ft}_{charHash} . '\)\$'
		let ft = &ft
	elseif exists("s:LHS__" . charHash)
				\ && a:lhs =~# '\V\^\%(' . s:LHS__{charHash} . '\)\$'
		let ft = ""
	else
		return ""
	endif
	let hash = s:Hash(a:lhs)
	return "rhs = " . strtrans( s:Map_{ft}_{hash} ) . " place holders = " .
				\ s:phs_{ft}_{hash} . " and " . s:phe_{ft}_{hash}
endfunction
" }}}
" IMAP_list_all:  list all the rhs and place holders with lhs ending in a:char {{{
function! IMAP_list_all(char)
	let result = ''
	let charHash = s:Hash(a:char)
	if &ft == ''
		let ft_list = ['']
	else
		let ft_list = [&ft, '']
	endif

	" Loop over current file type and global IMAPs
	for ft in ft_list
		if ft == ''
			let ft_display = 'global: '
		else
			let ft_display = ft . ': '
		endif
		if exists("s:LHS_" . ft ."_". charHash)
			for lhs in split( s:LHS_{ft}_{charHash}, '\\|' )
				" Undo the escaping of backslashes in lhs
				let lhs = substitute(lhs, '\\\\', '\', 'g')
				let hash = s:Hash(lhs)
				let result .= ft_display . lhs . " => " . strtrans( s:Map_{ft}_{hash} ) . "\n"
			endfor
		endif
	endfor
	return result
endfunction
" }}}
" LookupCharacter: inserts mapping corresponding to this character {{{
"
" This function extracts from s:LHS_{&ft}_{a:char} or s:LHS__{a:char}
" the longest lhs matching the current text.  Then it replaces lhs with the
" corresponding rhs saved in s:Map_{ft}_{lhs} .
" The place-holder variables are passed to IMAP_PutTextWithMovement() .
function! s:LookupCharacter(char)
	if IMAP_GetVal('Imap_FreezeImap', 0) == 1
		return a:char
	endif
	let charHash = s:Hash(a:char)

	" The line so far, including the character that triggered this function:
	let text = strpart(getline("."), 0, col(".")-1) . a:char
	" Prefer a local map to a global one, even if the local map is shorter.
	" Is this what we want?  Do we care?
	" Use '\V' (very no-magic) so that only '\' is special, and it was already
	" escaped when building up s:LHS_{&ft}_{charHash} .
	if exists("s:LHS_" . &ft . "_" . charHash)
				\ && text =~ "\\C\\V\\%(" . s:LHS_{&ft}_{charHash} . "\\)\\$"
		let ft = &ft
	elseif exists("s:LHS__" . charHash)
				\ && text =~ "\\C\\V\\%(" . s:LHS__{charHash} . "\\)\\$"
		let ft = ""
	else
		" If this is a character which could have been used to trigger an
		" abbreviation, check if an abbreviation exists.
		if a:char !~ '\k'
			let lastword = matchstr(getline('.'), '\k\+$', '')
			call IMAP_Debug('getting lastword = ['.lastword.']', 'imap')
			if lastword != ''
				let abbreviationRHS = maparg( lastword, 'i', 1 )

				call IMAP_Debug('getting abbreviationRHS = ['.abbreviationRHS.']', 'imap')

				if abbreviationRHS == ''
					return a:char
				endif

				let abbreviationRHS = escape(abbreviationRHS, '\<"')
				exec 'let abbreviationRHS = "'.abbreviationRHS.'"'

				let lhs = lastword.a:char
				let rhs = abbreviationRHS.a:char
				let phs = IMAP_GetPlaceHolderStart()
				let phe = IMAP_GetPlaceHolderEnd()
			else
				return a:char
			endif
		else
			return a:char
		endif
	endif
	" Find the longest left-hand side that matches the line so far.
	" matchstr() returns the match that starts first. This automatically
	" ensures that the longest LHS is used for the mapping.
	if !exists('lhs') || !exists('rhs')
		let lhs = matchstr(text, "\\C\\V\\%(" . s:LHS_{ft}_{charHash} . "\\)\\$")
		let hash = s:Hash(lhs)
		let rhs = s:Map_{ft}_{hash}
		let phs = s:phs_{ft}_{hash} 
		let phe = s:phe_{ft}_{hash}
	endif

	if strlen(lhs) == 0
		return a:char
	endif

	" enough back-spaces to erase the left-hand side
	let bs = repeat("\<bs>", s:MultiByteStrlen(lhs))

	" \<c-g>u inserts an undo point
	let result = a:char . "\<c-g>u" . bs . IMAP_PutTextWithMovement(rhs, phs, phe)

	if a:char !~? '[a-z0-9]'
		" If 'a:char' is not a letter or number, insert it literally.
		let result = "\<c-v>" . result
	endif

	return result
endfunction

" }}}
" IMAP_PutTextWithMovement: returns the string with movement appended {{{
" Description:
"   If a:str contains "placeholders", then appends movement commands to
"   str in a way that the user moves to the first placeholder and enters
"   insert or select mode. If supplied with 2 additional arguments, then
"   they are assumed to be the placeholder specs. Otherwise, they are
"   assumed to be '<+' and '+>'. These placeholder chars are replaced
"   with the users settings of [bg]:Imap_PlaceHolderStart and
"   [bg]:Imap_PlaceHolderEnd.
function! IMAP_PutTextWithMovement(str, ...)

	" The placeholders used in the particular input string. These can be
	" different from what the user wants to use.
	if a:0 < 2
		let phs = '<+'
		let phe = '+>'
	else
		let phs = escape(a:1, '\')
		let phe = escape(a:2, '\')
	endif

	let text = a:str

	" The user's placeholder settings.
	let phsUser = IMAP_GetPlaceHolderStart()
	let pheUser = IMAP_GetPlaceHolderEnd()

	let pattern = '\V\(\.\{-}\)' .phs. '\(\.\{-}\)' .phe. '\(\.\*\)'
	" If there are no placeholders, just return the text.
	if text !~ pattern
		call IMAP_Debug('Not getting '.phs.' and '.phe.' in '.text, 'imap')
		return text
	endif
	" Break text up into "initial <+template+> final"; any piece may be empty.
	let initial  = substitute(text, pattern, '\1', '')
	let template = substitute(text, pattern, '\2', '')
	let final    = substitute(text, pattern, '\3', '')

	" If the user does not want to use placeholders, then remove all but the
	" first placeholder.
	" Otherwise, replace all occurences of the placeholders here with the
	" user's choice of placeholder settings.
	if exists('g:Imap_UsePlaceHolders') && !g:Imap_UsePlaceHolders
		let final = substitute(final, '\V'.phs.'\.\{-}'.phe, '', 'g')
	else
		let final = substitute(final, '\V'.phs.'\(\.\{-}\)'.phe,
					\ phsUser.'\1'.pheUser, 'g')
	endif

	" Build up the text to insert:
	" 1. the initial text plus an extra character;
	" 2. go to Normal mode with <C-\><C-N>, so it works even if 'insertmode'
	" is set, and mark the position;
	" 3. replace the extra character with tamplate and final;
	" 4. back to Normal mode and restore the cursor position;
	" 5. call IMAP_Jumpfunc().
	let template = phsUser . template . pheUser
	" Old trick:  insert and delete a character to get the same behavior at
	" start, middle, or end of line and on empty lines.
	let text = initial . "X\<C-\>\<C-N>:call IMAP_Mark('set')\<CR>\"_s"
	let text = text . template . final
	let text = text . "\<C-\>\<C-N>:call IMAP_Mark('go')\<CR>"
	let text = text . ":call IMAP_Jumpfunc('', 1)\<CR>"

	call IMAP_Debug('IMAP_PutTextWithMovement: text = ['.text.']', 'imap')
	return text
endfunction

" }}}
" IMAP_Jumpfunc: takes user to next <+place-holder+> {{{
" Author: Luc Hermitte
" Arguments:
" direction: flag for the search() function. If set to '', search forwards,
"            if 'b', then search backwards. See the {flags} argument of the
"            |search()| function for valid values.
" inclusive: In vim, the search() function is 'exclusive', i.e we always goto
"            next cursor match even if there is a match starting from the
"            current cursor position. Setting this argument to 1 makes
"            IMAP_Jumpfunc() also respect a match at the current cursor
"            position. 'inclusive'ness is necessary for IMAP() because a
"            placeholder string can occur at the very beginning of a map which
"            we want to select.
"            We use a non-zero value only in special conditions. Most mappings
"            should use a zero value.
function! IMAP_Jumpfunc(direction, inclusive)

	" The user's placeholder settings.
	let phsUser = IMAP_GetPlaceHolderStart()
	let pheUser = IMAP_GetPlaceHolderEnd()

	" Set up flags for the search() function
	let flags = a:direction
	if a:inclusive
		let flags .= 'c'
	end

	let searchString = '\V'.phsUser.'\_.\{-}'.pheUser

	" If we didn't find any placeholders return quietly.
	if !search(searchString, flags)
		return
	endif

	" Open any closed folds and make this part of the text visible.
	silent! foldopen!

	" We are at the starting placeholder. Start visual mode.
	normal! v

	" Calculate if we have an empty placeholder. It is empty if both
	" placeholders appear one after the other.
	" Check also whether the empty placeholder ends at the end of the line.
	let curline = strpart(getline('.'), col('.')-1)
	let phUser = phsUser.pheUser
	let placeHolderEmpty = (strpart(curline,0,strlen(phUser)) ==# phUser)
	let placeHolderEOL = (curline ==# phUser)

	" Search for the end placeholder and position the cursor.
	call search(searchString, 'ce')

	" If we are selecting in exclusive mode, then we need to move one step to
	" the right
	if &selection == 'exclusive'
		normal! l
	endif

	" Now either goto insert mode, visual mode or select mode.
	if placeHolderEmpty && g:Imap_DeleteEmptyPlaceHolders
		" Delete the empty placeholder into the blackhole.
		normal! "_d
		" Start insert mode. If the placeholder was at the end of the line, use
		" startinsert! (equivalent to 'A'), otherwise startinsert (equiv. 'i')
		if placeHolderEOL
			startinsert!
		else
			startinsert
		endif
	else
		if g:Imap_GoToSelectMode
			" Go to select mode
			execute "normal! \<C-g>"
		else
			" Do not go to select mode
		endif
	endif
endfunction
" }}}
" Maps for IMAP_Jumpfunc {{{
"
" These mappings use <Plug> and thus provide for easy user customization. When
" the user wants to map some other key to jump forward, he can do for
" instance:
"   nmap ,f   <plug>IMAP_JumpForward
" etc.

" jumping forward and back in insert mode.
inoremap <silent> <Plug>IMAP_JumpForward    <C-\><C-N>:call IMAP_Jumpfunc('', 0)<CR>
inoremap <silent> <Plug>IMAP_JumpBack       <C-\><C-N>:call IMAP_Jumpfunc('b', 0)<CR>

" jumping in normal mode
nnoremap <silent> <Plug>IMAP_JumpForward        :call IMAP_Jumpfunc('', 0)<CR>
nnoremap <silent> <Plug>IMAP_JumpBack           :call IMAP_Jumpfunc('b', 0)<CR>

" deleting the present selection and then jumping forward.
vnoremap <silent> <Plug>IMAP_DeleteAndJumpForward       "_<Del>:call IMAP_Jumpfunc('', 0)<CR>
vnoremap <silent> <Plug>IMAP_DeleteAndJumpBack          "_<Del>:call IMAP_Jumpfunc('b', 0)<CR>

" jumping forward without deleting present selection.
vnoremap <silent> <Plug>IMAP_JumpForward       <C-\><C-N>:call IMAP_Jumpfunc('', 0)<CR>
vnoremap <silent> <Plug>IMAP_JumpBack          <C-\><C-N>`<:call IMAP_Jumpfunc('b', 0)<CR>

" }}}
" Default maps for IMAP_Jumpfunc {{{
" map only if there is no mapping already. allows for user customization.
" NOTE: Default mappings for jumping to the previous placeholder are not
"       provided. It is assumed that if the user will create such mappings
"       hself if e so desires.
if !hasmapto('<Plug>IMAP_JumpForward', 'i')
    imap <C-J> <Plug>IMAP_JumpForward
endif
if !hasmapto('<Plug>IMAP_JumpForward', 'n')
    nmap <C-J> <Plug>IMAP_JumpForward
endif
if exists('g:Imap_StickyPlaceHolders') && g:Imap_StickyPlaceHolders
	if !hasmapto('<Plug>IMAP_JumpForward', 'v')
		vmap <C-J> <Plug>IMAP_JumpForward
	endif
else
	if !hasmapto('<Plug>IMAP_DeleteAndJumpForward', 'v')
		vmap <C-J> <Plug>IMAP_DeleteAndJumpForward
	endif
endif
" }}}

" ============================================================================== 
" helper functions
" ============================================================================== 
" s:Hash: Return a version of a string that can be used as part of a variable" {{{
" name.
" 	Converts every non alphanumeric character into _{ascii}_ where {ascii} is
" 	the ASCII code for that character...
fun! s:Hash(text)
	return substitute(a:text, '\([^[:alnum:]]\)',
				\ '\="_".char2nr(submatch(1))."_"', 'g')
endfun
"" }}}
" s:IMAP_add_imap() Adds the imap for IMAP {{{
function! s:IMAP_add_imap( lastLHSChar, buffer )
	if a:lastLHSChar == ' '
		for lastLHSChar in ['<space>', '<s-space>', '<c-space>', '<cs-space>']
			call s:IMAP_add_imap( lastLHSChar, a:buffer )
		endfor
	else
		if a:buffer =~# '<buffer>'
			if !exists('b:IMAP_imaps')
				let b:IMAP_imaps = []
			endif
			if index(b:IMAP_imaps, a:lastLHSChar) < 0
				call add(b:IMAP_imaps, a:lastLHSChar )
			endif
		endif
		exe 'inoremap <silent>' . a:buffer
					\ escape(a:lastLHSChar, '|')
					\ '<C-r>=<SID>LookupCharacter("' .
					\ escape(a:lastLHSChar, '\|"') .
					\ '")<CR>'
	endif
endfunction
" }}}
" s:IMAP_rm_imap() Removes the imap for IMAP {{{
function! s:IMAP_rm_imap( lastLHSChar, buffer )
	if a:lastLHSChar == ' '
		for lastLHSChar in ['<space>', '<s-space>', '<c-space>', '<cs-space>']
			call s:IMAP_rm_imap( lastLHSChar, a:buffer )
		endfor
	else
		if a:buffer =~# '<buffer>' && exists('b:IMAP_imaps')
			let idx = index(b:IMAP_imaps, a:lastLHSChar)
			if idx >= 0
				call remove(b:IMAP_imaps, idx)
			endif
		endif
		exe 'iunmap <silent>' . a:buffer escape(a:lastLHSChar, '|')
	endif
endfunction
" }}}
" IMAP_GetPlaceHolderStart and IMAP_GetPlaceHolderEnd:  "{{{
" return the buffer local placeholder variables, or the global one, or the default.
function! IMAP_GetPlaceHolderStart()
	if exists("b:Imap_PlaceHolderStart") && strlen(b:Imap_PlaceHolderEnd)
		return b:Imap_PlaceHolderStart
	elseif exists("g:Imap_PlaceHolderStart") && strlen(g:Imap_PlaceHolderEnd)
		return g:Imap_PlaceHolderStart
	else
		return "<+"
endfun
function! IMAP_GetPlaceHolderEnd()
	if exists("b:Imap_PlaceHolderEnd") && strlen(b:Imap_PlaceHolderEnd)
		return b:Imap_PlaceHolderEnd
	elseif exists("g:Imap_PlaceHolderEnd") && strlen(g:Imap_PlaceHolderEnd)
		return g:Imap_PlaceHolderEnd
	else
		return "+>"
endfun
" }}}
" IMAP_Debug: interface to Tex_Debug if available, otherwise emulate it {{{
" Description: 
" Do not want a memory leak! Set this to zero so that imaps always
" starts out in a non-debugging mode.
if !exists('g:Imap_Debug')
	let g:Imap_Debug = 0
endif
function! IMAP_Debug(string, pattern)
	if !g:Imap_Debug
		return
	endif
	if exists('*Tex_Debug')
		call Tex_Debug(a:string, a:pattern)
	else
		if !exists('s:debug_'.a:pattern)
			let s:debug_{a:pattern} = a:string
		else
			let s:debug_{a:pattern} = s:debug_{a:pattern}.a:string
		endif
	endif
endfunction " }}}
" IMAP_DebugClear: interface to Tex_DebugClear if avaialable, otherwise emulate it {{{
" Description: 
function! IMAP_DebugClear(pattern)
	if exists('*Tex_DebugClear')
		call Tex_DebugClear(a:pattern)
	else	
		let s:debug_{a:pattern} = ''
	endif
endfunction " }}}
" IMAP_PrintDebug: interface to Tex_DebugPrint if avaialable, otherwise emulate it {{{
" Description: 
function! IMAP_PrintDebug(pattern)
	if exists('*Tex_PrintDebug')
		call Tex_PrintDebug(a:pattern)
	else
		if exists('s:debug_'.a:pattern)
			echo s:debug_{a:pattern}
		endif
	endif
endfunction " }}}
" IMAP_Mark:  Save the cursor position (if a:action == 'set') in a" {{{
" script-local variable; restore this position if a:action == 'go'.
let s:Mark = "(0,0)"
let s:initBlanks = ''
function! IMAP_Mark(action)
	if a:action == 'set'
		let s:Mark = "(" . line(".") . "," . col(".") . ")"
		let s:initBlanks = matchstr(getline('.'), '^\s*')
	elseif a:action == 'go'
		execute "call cursor" s:Mark
		let blanksNow = matchstr(getline('.'), '^\s*')
		if strlen(blanksNow) > strlen(s:initBlanks)
			execute 'silent! normal! '.(strlen(blanksNow) - strlen(s:initBlanks)).'l'
		elseif strlen(blanksNow) < strlen(s:initBlanks)
			execute 'silent! normal! '.(strlen(s:initBlanks) - strlen(blanksNow)).'h'
		endif
	endif
endfunction	"" }}}
" IMAP_GetVal: gets the value of a variable {{{
" Description: first checks window local, then buffer local etc.
function! IMAP_GetVal(name, ...)
	if a:0 > 0
		let default = a:1
	else
		let default = ''
	endif
	if exists('w:'.a:name)
		return w:{a:name}
	elseif exists('b:'.a:name)
		return b:{a:name}
	elseif exists('g:'.a:name)
		return g:{a:name}
	else
		return default
	endif
endfunction " }}}
" s:MultiByteStrlen: Same as strlen() but counts multibyte characters {{{
" instead of bytes.
function! s:MultiByteStrlen(str)
	return strlen(substitute(a:str, ".", "x", "g"))
endfunction " }}}
" s:MultiByteLastCharacter: Return last multibyte characters {{{
function! s:MultiByteLastCharacter(str)
	return matchstr(a:str, ".$")
endfunction " }}}

let &cpo = s:save_cpo

" vim:ft=vim:ts=4:sw=4:noet:fdm=marker:commentstring=\"\ %s:nowrap
