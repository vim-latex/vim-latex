"        File: imaps.vim
"     Authors: Srinath Avadhanula <srinath AT fastmail.fm>
"              Benji Fisher <benji AT member.AMS.org>
"
"         WWW: http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi/vim-latex/vimfiles/plugin/imaps.vim?only_with_tag=MAIN
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
"
"--------------------------------------%<--------------------------------------
" Bonus: This script also provides a command Snip which puts tearoff strings,
" '----%<----' above and below the visually selected range of lines. The
" length of the string is chosen to be equal to the longest line in the range.
" Recommended Usage:
"   '<,'>Snip
"--------------------------------------%<--------------------------------------
" }}}

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
" }}}
" Variables {{{
" s:LHS_{ft}_{char} will be generated automatically.  It will look like
" s:LHS_tex_o = 'fo\|foo\|boo' and contain all mapped sequences ending in "o".
" s:Map_{ft}_{lhs} will be generated automatically.  It will look like
" s:Map_c_foo = 'for(<++>; <++>; <++>)', the mapping for "foo".
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
function! IMAP(lhs, rhs, ft, ...)
	return call('latexsuite#imaps#IMAP', [a:lhs, a:rhs, a:ft]+a:000)
endfunction

" }}}
" IMAP_list:  list the rhs and place holders corresponding to a:lhs {{{
"
" Added mainly for debugging purposes, but maybe worth keeping.
function! IMAP_list(lhs)
	return latexsuite#imaps#IMAP_list(a:lhs)
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
	return call('latexsuite#imaps#IMAP_PutTextWithMovement', [a:str]+a:000)
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
	return latexsuite#imaps#IMAP_Jumpfunc(a:direction, a:inclusive)
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
inoremap <silent> <Plug>IMAP_JumpForward    <c-r>=IMAP_Jumpfunc('', 0)<CR>
inoremap <silent> <Plug>IMAP_JumpBack       <c-r>=IMAP_Jumpfunc('b', 0)<CR>

" jumping in normal mode
nnoremap <silent> <Plug>IMAP_JumpForward        i<c-r>=IMAP_Jumpfunc('', 0)<CR>
nnoremap <silent> <Plug>IMAP_JumpBack           i<c-r>=IMAP_Jumpfunc('b', 0)<CR>

" deleting the present selection and then jumping forward.
vnoremap <silent> <Plug>IMAP_DeleteAndJumpForward       "_<Del>i<c-r>=IMAP_Jumpfunc('', 0)<CR>
vnoremap <silent> <Plug>IMAP_DeleteAndJumpBack          "_<Del>i<c-r>=IMAP_Jumpfunc('b', 0)<CR>

" jumping forward without deleting present selection.
vnoremap <silent> <Plug>IMAP_JumpForward       <C-\><C-N>i<c-r>=IMAP_Jumpfunc('', 0)<CR>
vnoremap <silent> <Plug>IMAP_JumpBack          <C-\><C-N>`<i<c-r>=IMAP_Jumpfunc('b', 0)<CR>

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
" enclosing selected region.
" ==============================================================================
" VEnclose: encloses the visually selected region with given arguments {{{
" Description: allows for differing action based on visual line wise
"              selection or visual characterwise selection. preserves the
"              marks and search history.
function! VEnclose(vstart, vend, VStart, VEnd)
	return latexsuite#imaps#VEnclose(a:vstart, a:vend, a:VStart, a:VEnd)
endfunction

" }}}
" ExecMap: adds the ability to correct an normal/visual mode mapping.  {{{
" Author: Hari Krishna Dara <hari_vim@yahoo.com>
" Reads a normal mode mapping at the command line and executes it with the
" given prefix. Press <BS> to correct and <Esc> to cancel.
function! ExecMap(prefix, mode)
	return latexsuite#imaps#ExecMap(a:prefix, a:mode)
endfunction

" }}}

" ==============================================================================
" helper functions
" ==============================================================================
" IMAP_GetPlaceHolderStart and IMAP_GetPlaceHolderEnd:  "{{{
" return the buffer local placeholder variables, or the global one, or the default.
function! IMAP_GetPlaceHolderStart()
	return latexsuite#imaps#IMAP_GetPlaceHolderStart()
endfun
function! IMAP_GetPlaceHolderEnd()
	return latexsuite#imaps#IMAP_GetPlaceHolderEnd()
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
	return latexsuite#imaps#IMAP_Debug(a:string, a:pattern)
endfunction " }}}
" IMAP_DebugClear: interface to Tex_DebugClear if avaialable, otherwise emulate it {{{
" Description:
function! IMAP_DebugClear(pattern)
	return latexsuite#imaps#IMAP_DebugClear(a:pattern)
endfunction " }}}
" IMAP_PrintDebug: interface to Tex_DebugPrint if avaialable, otherwise emulate it {{{
" Description:
function! IMAP_PrintDebug(pattern)
	return latexsuite#imaps#IMAP_PrintDebug(a:pattern)
endfunction " }}}
" IMAP_Mark:  Save the cursor position (if a:action == 'set') in a" {{{
" script-local variable; restore this position if a:action == 'go'.
function! IMAP_Mark(action)
	return latexsuite#imaps#IMAP_Mark(a:action)
endfunction	"" }}}
" IMAP_GetVal: gets the value of a variable {{{
" Description: first checks window local, then buffer local etc.
function! IMAP_GetVal(name, ...)
	return call('latexsuite#imaps#IMAP_GetVal', [a:name]+a:000)
endfunction " }}}

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
com! -nargs=0 -range Snip :<line1>,<line2>call latexsuite#imaps#Snip()
" }}}

let &cpo = s:save_cpo

" vim:ft=vim:ts=4:sw=4:noet:fdm=marker:commentstring=\"\ %s:nowrap
