"        File: imaps.vim
"      Author: Srinath Avadhanula
"              ( srinath@fastmail.fm )
"         WWW: http://robotics.eecs.berkeley.edu/~srinath/vim/.vim/imaps.vim
" Description: insert mode template expander with cursor placement
"              while preserving filetype indentation.
" Last Change: Mon Nov 04 02:00 PM 2002 PST
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
" The script already provides some default mappings. each "mapping" is of the
" form:
"
" call IMAP (lhs, rhs, ft)
" 
" Some characters in the RHS have special meaning which help in cursor
" placement.
"
" Example One:
"
" 	call IMAP ("bit`", "\\begin{itemize}\<cr>\\item «»\<cr>\\end{itemize}«»", "tex")
" 
" This effectively sets up the map for "bit`" whenever you edit a latex file.
" When you type in this sequence of letters, the following text is inserted:
" 
" \begin{itemize}
" \item *
" \end{itemize}«»
"
" where * shows the cursor position. The cursor position after inserting the
" text is decided by the position of the first "place-holder". Place holders
" are special characters which decide cursor placement and movement. In the
" example above, the place holder characters are « and ». After you have typed
" in the item, press <C-j> and you will be taken to the next set of «»'s.
" Therefore by placing the «» characters appropriately, you can minimize the
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
"
"--------------------------------------%<--------------------------------------
" Bonus: This script also provides a command Snip which puts tearoff strings,
" '----%<----' above and below the visually selected range of lines. The
" length of the string is chosen to be equal to the longest line in the range.
"--------------------------------------%<--------------------------------------
" }}}

" Prevent resourcing this file.
if exists('s:doneImaps')
	finish
endif
let s:doneImaps = 1

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
function! IMAP(lhs, rhs, ft)
	let lastLHSChar = a:lhs[strlen(a:lhs)-1]
	" s:charLens_<ft>_<char> contains the lengths of the left hand sides of
	" the various mappings for filetype <ft> which end in <char>. its a comma
	" seperated list of numbers.
	" for example if we want to create 2 mappings
	"   ab  --> cd
	"   lbb --> haha
	" for tex type files, then the variable will be:
	"   s:charLens_tex_b = '2,3,'
	let charLenHash = 's:charLens_'.a:ft.'_'.char2nr(lastLHSChar)

	" if this variable doesnt exist before, initialize...
	if !exists(charLenHash)
		exe 'let '.charLenHash.' = ""'
	end
	" get the value of the variable.
	exe "let charLens = ".charLenHash
	" check to see if this length is already there...
	if matchstr(charLens, '\(^\|,\)'.strlen(a:lhs).',') == ''
		" ... if not append.
		" but carefully. sort the charLens array in decreasing order. this way
		" the longest lhs is checked first. i.e if the user has 2 maps
		" ab    --> rhs1
		" csdfb --> rhs2
		" i.e 2 mappings ending in b, then check to see if the longer mapping
		" is satisfied first.
		" TODO: possible bug. what if the user has a mapping with lhs more
		" than 9 chars? (highly improbable).
		" largest element which is just smaller than the present length
		let idx = match(charLens, '[1-'.strlen(a:lhs).'],')
		if idx == -1
			let new = charLens.strlen(a:lhs).','
		else
			let left = strpart(charLens, 0, idx)
			let right = strpart(charLens, idx, 1000)
			let new = left.strlen(a:lhs).','.right
		end

		let charLens = new
		exe "let ".charLenHash." = charLens"
	end
	
	" create a variable corresponding to the lhs. convert all non-word
	" characters into their ascii codes so that a vim variable with that name
	" can be created.  this is a way to create hashes in vim.
	let lhsHash = 's:Map_'.a:ft.'_'.substitute(a:lhs, '\(\W\)', '\="_".char2nr(submatch(1))."_"', 'g')
	" store the value of the right-hand side of the mapping in this newly
	" created variable.
	exe "let ".lhsHash." = a:rhs"
	
	" store a token string of this length. this is helpful later for erasing
	" the left-hand side before inserting the right-hand side.
	let tokenLenHash = 's:LenStr_'.strlen(a:lhs)
	exe "let ".tokenLenHash." = a:lhs"

	" map only the last character of the left-hand side.
	if lastLHSChar == ' '
		let lastLHSChar = '<space>'
	end
	exe 'inoremap <silent> '.escape(lastLHSChar, '|').' <C-r>=<SID>LookupCharacter("'.escape(lastLHSChar, '\|').'")<CR>'
endfunction

" }}}
" LookupCharacter: inserts mapping corresponding to this character {{{
"
" This function performs a reverse lookup when this character is typed in. It
" loops over all the possible left-hand side variables ending in this
" character and then if a possible match exists, ereases the left-hand side
" and inserts the right hand side instead.
function! <SID>LookupCharacter(char)
	let charHash = char2nr(a:char)

	if !exists('s:charLens_'.&ft.'_'.charHash)
		\ && !exists('s:charLens__'.charHash)
		return a:char
	end

	let k = 1
	while k <= 2
		" first check the filetype specific mappings and then the general
		" purpose mappings.
		if k == 1
			let ft = &ft
		else
			let ft = ''
		end

		" get the lengths of the left-hand side mappings which end in this
		" character. if no mappings ended in this character, then continue... 
		if !exists('s:charLens_'.ft.'_'.charHash)
			let k = k + 1
			continue
		end

		exe 'let lens = s:charLens_'.ft.'_'.charHash

		let i = 1
		while 1
			" get the i^th length. 
			let numchars = s:Strntok(lens, ',', i)
			" if there are no more lengths, then skip to the next outer while
			" loop.
			if numchars == ''
				break
			end

			if col('.') < numchars
				let i = i + 1
				continue
			end
			
			" get the corresponding text from before the text. append the present
			" char to complete the (possible) LHS
			let text = strpart(getline('.'), col('.') - numchars, numchars - 1).a:char
			let lhsHash = 's:Map_'.ft.'_'.substitute(text, '\(\W\)', '\="_".char2nr(submatch(1))."_"', 'g')

			" if there is no mapping of this length which satisfies the previously
			" typed in characters, then proceed to the next length group...
			if !exists(lhsHash)
				let i = i + 1
				continue
			end

			"  ... otherwise insert the corresponding RHS
			" first generate the required number of back-spaces to erase the
			" previously typed in characters.
			exe "let tokLHS = s:LenStr_".numchars
			let bkspc = substitute(tokLHS, '.$', '', '')
			let bkspc = substitute(bkspc, '.', "\<bs>", "g")

			" get the corresponding RHS
			exe "let ret = ".lhsHash
			
			return bkspc.IMAP_PutTextWithMovement(ret)

		endwhile

		let k = k + 1
	endwhile
	
	return a:char
endfunction

" }}}
" IMAP_PutTextWithMovement: appends movement commands to a text  {{{
" 		This enables which cursor placement.
function! IMAP_PutTextWithMovement(text)
	
	let text = a:text

	" if the user doesnt want to use place-holders, then remove them.
	if exists('g:Imap_UsePlaceHolders') && !g:Imap_UsePlaceHolders
		" a heavy-handed way to just use the first placeholder or ä and remove
		" the rest.
		" substitute the placeholders with ä
		let text = substitute(text, '«[^»]*»', 'ä', 'g')
		" substitute the first ä with ë ...
		let text = substitute(text, 'ä', 'ë', '')
		" ... now remove all the ä's.
		let text = substitute(text, 'ä', '', 'g')
		" ... and substitute back the first ë with ä
		let text = substitute(text, 'ë', 'ä', '')
	endif

	" change the default values of the place-holder variables.
	let phs = '«'
	if exists('b:Imap_PlaceHolderStart')
		let phs = b:Imap_PlaceHolderStart
	elseif exists('g:Imap_PlaceHolderStart')
		let phs = g:Imap_PlaceHolderStart
	endif
	let text = substitute(text, '«', phs, 'g')
	let phe = '»'
	if exists('b:Imap_PlaceHolderEnd')
		let phe = b:Imap_PlaceHolderEnd
	elseif exists('g:Imap_PlaceHolderEnd')
		let phe = g:Imap_PlaceHolderEnd
	endif
	let text = substitute(text, '»', phe, 'g')

	let fc = match(text, 'ä\|'.phs.'[^'.phe.']*'.phe)
	if fc < 0
		let initial = ""
		let movement = ""
	" if the place to go to is at the very beginning, then a simple back
	" search will do...
	elseif fc == 0
		let initial = ""
		let movement = "\<C-\>\<C-N>?ä\<cr>:call SAImaps_RemoveLastHistoryItem()\<cr>s"

	" however, if its somewhere in the middle, then we need to go back to the
	" beginning of the pattern and then do a forward lookup from that point.
	else

		" hopefully ¡¡IMAPS_Start!! is rare enough. prepend that to the text.
		let initial = "¡¡IMAPS_Start!!"
		" and then do a backwards lookup. this takes us to the beginning. then
		" delete that dummy part. we are left at the very beginning.
		let movement = "\<C-\>\<C-N>?¡¡IMAPS_Start!!\<cr>v".(strlen(initial)-1)."l\"_x"

		" now proceed with the forward search for cursor placement
		let movement = movement."/ä\\|".phs."[^".phe."]*".phe."\<cr>"

		" we needed 2 searches to get here. remove them from the search
		" history.
		let movement = movement.":call SAImaps_RemoveLastHistoryItem()\<cr>"
		let movement = movement.":call SAImaps_RemoveLastHistoryItem()\<cr>"

		" if its a ä or «», then just delete it
		if text[fc] == 'ä'
			let movement = movement."\"_s"
		elseif strpart(text, fc, 2) == phs.phe
			let movement = movement."\"_2s"

		" otherwise enter select mode...
		else
			let movement = movement."vf".phe."\<C-g>"
		end

	end
	return initial.text.movement
endfunction 

" }}}
" IMAP_Jumpfunc: takes user to next «place-holder» {{{
" Author: Gergely Kontra
"         taken from mu-template.vim by him This idea is originally
"         from Stephen Riehm's bracketing system.
" modified by SA to use optional place holder characters.
function! IMAP_Jumpfunc()
	let phs = '«'
	let phe = '»'

	if exists('b:Imap_PlaceHolderStart')
		let phs = b:Imap_PlaceHolderStart
	elseif exists('g:Imap_PlaceHolderStart')
		let phs = g:Imap_PlaceHolderStart
	endif

	if exists('b:Imap_PlaceHolderEnd')
		let phe = b:Imap_PlaceHolderEnd
	elseif exists('g:Imap_PlaceHolderEnd')
		let phe = g:Imap_PlaceHolderEnd
	endif

	if !search(phs.'.\{-}'.phe,'W') "no more marks
		echomsg "no marks found\n"
		return "\<CR>"
	else
		if getline('.')[col('.')] == phe
			return "\<Del>\<Del>"
		else
			if col('.') > 1
				return "\<Esc>lvf".phe."\<C-g>"
			else
				return "\<C-\>\<C-n>vf".phe."\<C-g>"
			endif
		endif
	endif
endfunction
" map only if there is no mapping already. allows for user customization.
if !hasmapto('IMAP_Jumpfunc')
    inoremap <C-J> <c-r>=IMAP_Jumpfunc()<CR>
    nmap <C-J> i<C-J>
end
" }}}

nmap <silent> <script> <plug>«SelectRegion» `<v`>

" ============================================================================== 
" enclosing selected region.
" ============================================================================== 
" VEnclose: encloses the visually selected region with given arguments {{{
" Description: allows for differing action based on visual line wise
"              selection or visual characterwise selection. preserves the
"              marks and search history.
function! VEnclose(vstart, vend, VStart, VEnd)

	" its characterwise if
	" 1. characterwise selection and valid values for vstart and vend.
	" OR
	" 2. linewise selection and invalid values for VStart and VEnd
	if (visualmode() == 'v' && (a:vstart != '' || a:vend != '')) || (a:VStart == '' && a:VEnd == '')

		let newline = ""
		let _r = @r

		let normcmd = "normal! \<C-\>\<C-n>`<v`>\"_s"

		exe "normal! \<C-\>\<C-n>`<v`>\"ry"
		if @r =~ "\n$"
			let newline = "\n"
			let @r = substitute(@r, "\n$", '', '')
		endif

		let normcmd = normcmd.
			\a:vstart."!!mark!!".a:vend.newline.
			\"\<C-\>\<C-N>?!!mark!!\<CR>v7l\"_s\<C-r>r\<C-\>\<C-n>"

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

		silent! exe normcmd
		" this is to restore the r register.
		let @r = _r
		" and finally, this is to restore the search history.
		call SAImaps_RemoveLastHistoryItem()

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
				let mapCmd = strpart(mapCmd, 0, strlen(mapCmd) - 1)
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
					let mapCmd = strpart(mapCmd, 0, strlen(mapCmd) - 1)
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
			let gotoc = "\<plug>«SelectRegion»"
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
" SAImaps_RemoveLastHistoryItem: removes last search item from search history {{{
" Description: This function needs to be globally visible because its
"              called from outside the script during expansion.
function! SAImaps_RemoveLastHistoryItem()
  call histdel("/", -1)
  let @/ = histget("/", -1)
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
function! <SID>Snip() range
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

com! -nargs=0 -range Snip :<line1>,<line2>call <SID>Snip()
" }}}

" vim6:fdm=marker:nowrap
