
" line continuation used here.
let s:save_cpo = &cpo
set cpo&vim


" ==============================================================================
" functions for easy insert mode mappings.
" ==============================================================================
" IMAP: Adds a "fake" insert mode mapping. {{{
"       For example, doing
"           IMAP('abc', 'def' ft)
"       will mean that if the letters abc are pressed in insert mode, then
"       they will be replaced by def. If ft != '', then the "mapping" will be
"       specific to the files of type ft.
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
function! latexsuite#imaps#IMAP(lhs, rhs, ft, ...)

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
	let lastLHSChar = s:MultiByteStrpart(a:lhs,s:MultiByteStrlen(a:lhs)-1)
	let hash = s:Hash(lastLHSChar)
	if !exists("s:LHS_" . a:ft . "_" . hash)
		let s:LHS_{a:ft}_{hash} = escape(a:lhs, '\')
	else
		let s:LHS_{a:ft}_{hash} = escape(a:lhs, '\') .'\|'.  s:LHS_{a:ft}_{hash}
	endif

	" map only the last character of the left-hand side.
	if lastLHSChar == ' '
		let lastLHSChar = '<space>'
	end
	exe 'inoremap <silent>'
				\ escape(lastLHSChar, '|')
				\ '<C-r>=<SID>LookupCharacter("' .
				\ escape(lastLHSChar, '\|"') .
				\ '")<CR>'
endfunction

" }}}
" IMAP_list:  list the rhs and place holders corresponding to a:lhs {{{
"
" Added mainly for debugging purposes, but maybe worth keeping.
function! latexsuite#imaps#IMAP_list(lhs)
	let char = s:MultiByteStrpart(a:lhs,s:MultiByteStrlen(a:lhs)-1)
	let charHash = s:Hash(char)
	if exists("s:LHS_" . &ft ."_". charHash) && a:lhs =~ s:LHS_{&ft}_{charHash}
		let ft = &ft
	elseif exists("s:LHS__" . charHash) && a:lhs =~ s:LHS__{charHash}
		let ft = ""
	else
		return ""
	endif
	let hash = s:Hash(a:lhs)
	return "rhs = " . s:Map_{ft}_{hash} . " place holders = " .
				\ s:phs_{ft}_{hash} . " and " . s:phe_{ft}_{hash}
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
				\ && text =~ "\\C\\V\\(" . s:LHS_{&ft}_{charHash} . "\\)\\$"
		let ft = &ft
	elseif exists("s:LHS__" . charHash)
				\ && text =~ "\\C\\V\\(" . s:LHS__{charHash} . "\\)\\$"
		let ft = ""
	else
		" If this is a character which could have been used to trigger an
		" abbreviation, check if an abbreviation exists.
		if a:char !~ '\k'
			let lastword = matchstr(getline('.'), '\k\+$', '')
			call IMAP_Debug('getting lastword = ['.lastword.']', 'imap')
			if lastword != ''
				" An extremeley wierd way to get around the fact that vim
				" doesn't have the equivalent of the :mapcheck() function for
				" abbreviations.
				let _a = @a
				exec "redir @a | silent! iab ".lastword." | redir END"
				let abbreviationRHS = matchstr(@a."\n", "\n".'i\s\+'.lastword.'\s\+@\?\zs.*\ze'."\n")

				call IMAP_Debug('getting abbreviationRHS = ['.abbreviationRHS.']', 'imap')

				if @a =~ "No abbreviation found" || abbreviationRHS == ""
					call setreg("a", _a, "c")
					return a:char
				endif

				call setreg("a", _a, "c")
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
		let lhs = matchstr(text, "\\C\\V\\(" . s:LHS_{ft}_{charHash} . "\\)\\$")
		let hash = s:Hash(lhs)
		let rhs = s:Map_{ft}_{hash}
		let phs = s:phs_{ft}_{hash}
		let phe = s:phe_{ft}_{hash}
	endif

	if strlen(lhs) == 0
		return a:char
	endif
	" enough back-spaces to erase the left-hand side; -1 for the last
	" character typed:
	let bs = substitute(s:MultiByteStrpart(lhs, 1), ".", "\<bs>", "g")
	" \<c-g>u inserts an undo point
	return a:char . "\<c-g>u\<bs>" . bs . IMAP_PutTextWithMovement(rhs, phs, phe)
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
function! latexsuite#imaps#IMAP_PutTextWithMovement(str, ...)

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

	" Problem:  depending on the setting of the 'encoding' option, a character
	" such as "\xab" may not match itself.  We try to get around this by
	" changing the encoding of all our strings.  At the end, we have to
	" convert text back.
	let phsEnc     = s:Iconv(phs, "encode")
	let pheEnc     = s:Iconv(phe, "encode")
	let phsUserEnc = s:Iconv(phsUser, "encode")
	let pheUserEnc = s:Iconv(pheUser, "encode")
	let textEnc    = s:Iconv(text, "encode")
	if textEnc != text
		let textEncoded = 1
	else
		let textEncoded = 0
	endif

	let pattern = '\V\(\.\{-}\)' .phs. '\(\.\{-}\)' .phe. '\(\.\*\)'
	" If there are no placeholders, just return the text.
	if textEnc !~ pattern
		call IMAP_Debug('Not getting '.phs.' and '.phe.' in '.textEnc, 'imap')
		return text
	endif
	" Break text up into "initial <+template+> final"; any piece may be empty.
	let initialEnc  = substitute(textEnc, pattern, '\1', '')
	let templateEnc = substitute(textEnc, pattern, '\2', '')
	let finalEnc    = substitute(textEnc, pattern, '\3', '')

	" If the user does not want to use placeholders, then remove all but the
	" first placeholder.
	" Otherwise, replace all occurences of the placeholders here with the
	" user's choice of placeholder settings.
	if exists('g:Imap_UsePlaceHolders') && !g:Imap_UsePlaceHolders
		let finalEnc = substitute(finalEnc, '\V'.phs.'\.\{-}'.phe, '', 'g')
	else
		let finalEnc = substitute(finalEnc, '\V'.phs.'\(\.\{-}\)'.phe,
					\ phsUserEnc.'\1'.pheUserEnc, 'g')
	endif

	" The substitutions are done, so convert back, if necessary.
	if textEncoded
		let initial = s:Iconv(initialEnc, "decode")
		let template = s:Iconv(templateEnc, "decode")
		let final = s:Iconv(finalEnc, "decode")
	else
		let initial = initialEnc
		let template = templateEnc
		let final = finalEnc
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
	let text = text . "i\<C-r>=IMAP_Jumpfunc('', 1)\<CR>"

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
function! latexsuite#imaps#IMAP_Jumpfunc(direction, inclusive)

	" The user's placeholder settings.
	let phsUser = IMAP_GetPlaceHolderStart()
	let pheUser = IMAP_GetPlaceHolderEnd()

	let searchString = ''
	" If this is not an inclusive search or if it is inclusive, but the
	" current cursor position does not contain a placeholder character, then
	" search for the placeholder characters.
	if !a:inclusive || strpart(getline('.'), col('.')-1) !~ '\V\^'.phsUser
		let searchString = '\V'.phsUser.'\_.\{-}'.pheUser
	endif

	" If we didn't find any placeholders return quietly.
	if searchString != '' && !search(searchString, a:direction)
		return ''
	endif

	" Open any closed folds and make this part of the text visible.
	silent! foldopen!

	" Calculate if we have an empty placeholder or if it contains some
	" description.
	let template =
		\ matchstr(strpart(getline('.'), col('.')-1),
		\          '\V\^'.phsUser.'\zs\.\{-}\ze\('.pheUser.'\|\$\)')
	let placeHolderEmpty = !strlen(template)

	" If we are selecting in exclusive mode, then we need to move one step to
	" the right
	let extramove = ''
	if &selection == 'exclusive'
		let extramove = 'l'
	endif

	" Select till the end placeholder character.
	let movement = "\<C-o>v/\\V".pheUser."/e\<CR>".extramove

	" First remember what the search pattern was. s:RemoveLastHistoryItem will
	" reset @/ to this pattern so we do not create new highlighting.
	let g:Tex_LastSearchPattern = @/

	" Now either goto insert mode or select mode.
	if placeHolderEmpty && g:Imap_DeleteEmptyPlaceHolders
		" delete the empty placeholder into the blackhole.
		return movement."\"_c\<C-o>:".s:RemoveLastHistoryItem."\<CR>"
	else
		return movement."\<C-\>\<C-N>:".s:RemoveLastHistoryItem."\<CR>gv\<C-g>"
	endif

endfunction

" }}}

nnoremap <silent> <script> <plug><+SelectRegion+> `<v`>

" ==============================================================================
" enclosing selected region.
" ==============================================================================
" VEnclose: encloses the visually selected region with given arguments {{{
" Description: allows for differing action based on visual line wise
"              selection or visual characterwise selection. preserves the
"              marks and search history.
function! latexsuite#imaps#VEnclose(vstart, vend, VStart, VEnd)

	" its characterwise if
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
function! latexsuite#imaps#ExecMap(prefix, mode)
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
				let mapCmd = s:MultiByteStrpart(mapCmd, 0, s:MultiByteStrlen(mapCmd) - 1)
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
					let mapCmd = s:MultiByteStrpart(mapCmd, 0, s:MultiByteStrlen(mapCmd) - 1)
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

" ==============================================================================
" helper functions
" ==============================================================================
" Strntok: extract the n^th token from a list {{{
" example: Strntok('1,23,3', ',', 2) = 23
fun! <SID>Strntok(s, tok, n)
	return matchstr( a:s.a:tok[0], '\v(\zs([^'.a:tok.']*)\ze['.a:tok.']){'.a:n.'}')
endfun

" }}}
" s:RemoveLastHistoryItem: removes last search item from search history {{{
" Description: Execute this string to clean up the search history.
let s:RemoveLastHistoryItem = ':call histdel("/", -1)|let @/=g:Tex_LastSearchPattern'

" }}}
" s:Hash: Return a version of a string that can be used as part of a variable" {{{
" name.
" 	Converts every non alphanumeric character into _{ascii}_ where {ascii} is
" 	the ASCII code for that character...
fun! s:Hash(text)
	return substitute(a:text, '\([^[:alnum:]]\)',
				\ '\="_".char2nr(submatch(1))."_"', 'g')
endfun
"" }}}
" IMAP_GetPlaceHolderStart and IMAP_GetPlaceHolderEnd:  "{{{
" return the buffer local placeholder variables, or the global one, or the default.
function! latexsuite#imaps#IMAP_GetPlaceHolderStart()
	if exists("b:Imap_PlaceHolderStart") && strlen(b:Imap_PlaceHolderEnd)
		return b:Imap_PlaceHolderStart
	elseif exists("g:Imap_PlaceHolderStart") && strlen(g:Imap_PlaceHolderEnd)
		return g:Imap_PlaceHolderStart
	else
		return "<+"
endfun
function! latexsuite#imaps#IMAP_GetPlaceHolderEnd()
	if exists("b:Imap_PlaceHolderEnd") && strlen(b:Imap_PlaceHolderEnd)
		return b:Imap_PlaceHolderEnd
	elseif exists("g:Imap_PlaceHolderEnd") && strlen(g:Imap_PlaceHolderEnd)
		return g:Imap_PlaceHolderEnd
	else
		return "+>"
endfun
" }}}
" s:Iconv:  a wrapper for iconv()" {{{
" Problem:  after
" 	let text = "\xab"
" (or using the raw 8-bit ASCII character in a file with 'fenc' set to
" "latin1") if 'encoding' is set to utf-8, then text does not match itself:
" 	echo text =~ text
" returns 0.
" Solution:  When this happens, a re-encoded version of text does match text:
" 	echo iconv(text, "latin1", "utf8") =~ text
" returns 1.  In this case, convert text to utf-8 with iconv().
" TODO:  Is it better to use &encoding instead of "utf8"?  Internally, vim
" uses utf-8, and can convert between latin1 and utf-8 even when compiled with
" -iconv, so let's try using utf-8.
" Arguments:
" 	a:text = text to be encoded or decoded
" 	a:mode = "encode" (latin1 to utf8) or "decode" (utf8 to latin1)
" Caution:  do not encode and then decode without checking whether the text
" has changed, becuase of the :if clause in encoding!
function! s:Iconv(text, mode)
	if a:mode == "decode"
		return iconv(a:text, "utf8", "latin1")
	endif
	if a:text =~ '\V\^' . escape(a:text, '\') . '\$'
		return a:text
	endif
	let textEnc = iconv(a:text, "latin1", "utf8")
	if textEnc !~ '\V\^' . escape(a:text, '\') . '\$'
		call IMAP_Debug('Encoding problems with text '.a:text.' ', 'imap')
	endif
	return textEnc
endfun
"" }}}
" IMAP_Debug: interface to Tex_Debug if available, otherwise emulate it {{{
" Description:
" Do not want a memory leak! Set this to zero so that imaps always
" starts out in a non-debugging mode.
if !exists('g:Imap_Debug')
	let g:Imap_Debug = 0
endif
function! latexsuite#imaps#IMAP_Debug(string, pattern)
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
function! latexsuite#imaps#IMAP_DebugClear(pattern)
	if exists('*Tex_DebugClear')
		call Tex_DebugClear(a:pattern)
	else
		let s:debug_{a:pattern} = ''
	endif
endfunction " }}}
" IMAP_PrintDebug: interface to Tex_DebugPrint if avaialable, otherwise emulate it {{{
" Description:
function! latexsuite#imaps#IMAP_PrintDebug(pattern)
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
function! latexsuite#imaps#IMAP_Mark(action)
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
function! latexsuite#imaps#IMAP_GetVal(name, ...)
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
" s:MultiByteStrpart: Same as strpart() but counts multibyte characters {{{
" instead of bytes.
function! s:MultiByteStrpart(src,start,...)
	let lensrc=s:MultiByteStrlen(a:src)
	let start=a:start
	let len=lensrc-a:start
	if a:0 != 0
		let len=a:1
	endif
	if start < 0
		let len=max([0,len+start])
		let start=0
	endif
	let len=min([len,lensrc-start])
	let end=lensrc - len - start
	let src=substitute(a:src,"^.\\{".start."\\}","","")
	return substitute(src,".\\{".end."\\}$","","")
endfunction
" }}}

" ==============================================================================
" A bonus function: Snip()
" ==============================================================================
" Snip: puts a scissor string above and below block of text {{{
" Desciption:
"-------------------------------------%<-------------------------------------
"   this puts a the string "--------%<---------" above and below the visually
"   selected block of lines. the length of the 'tearoff' string depends on the
"   maximum string length in the selected range. this is an aesthetically more
"   pleasing alternative instead of hardcoding a length.
"-------------------------------------%<-------------------------------------
function! latexsuite#imaps#Snip() range
	let i = a:firstline
	let maxlen = -2
	" find out the maximum virtual length of each line.
	while i <= a:lastline
		exe i
		let length = virtcol('$')
		let maxlen = (length > maxlen ? length : maxlen)
		let i = i + 1
	endwhile
	let maxlen = (maxlen > &tw && &tw != 0 ? &tw : maxlen)
	let half = maxlen/2
	exe a:lastline
	" put a string below
	exe "norm! o\<esc>".(half - 1)."a-\<esc>A%<\<esc>".(half - 1)."a-"
	" and above. its necessary to put the string below the block of lines
	" first because that way the first line number doesnt change...
	exe a:firstline
	exe "norm! O\<esc>".(half - 1)."a-\<esc>A%<\<esc>".(half - 1)."a-"
endfunction

" }}}

let &cpo = s:save_cpo

" vim:ft=vim:ts=4:sw=4:noet:fdm=marker:commentstring=\"\ %s:nowrap
