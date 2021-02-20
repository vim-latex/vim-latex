"=============================================================================
" 	       File: bibtex.vim
"      Function: BibT
"        Author: Alan G Isaac <aisaac@american.edu>
"                modified by Srinath Avadhanula for latex-suite.
"       License: Vim Charityware license.
"=============================================================================

" Fields:
" Define what field type each letter denotes {{{
"
let s:a_standsfor = 'author'
let s:A_standsfor = 'address'
let s:b_standsfor = 'booktitle'
let s:c_standsfor = 'chapter'
let s:d_standsfor = 'doi'
let s:e_standsfor = 'edition'
let s:E_standsfor = 'editor'
let s:h_standsfor = 'howpublished'
let s:i_standsfor = 'institution'
let s:I_standsfor = 'isbn'
let s:j_standsfor = 'journal'
let s:l_standsfor = 'location'
let s:m_standsfor = 'month'
let s:n_standsfor = 'number'
let s:N_standsfor = 'note'
let s:o_standsfor = 'organization'
let s:p_standsfor = 'pages'
let s:P_standsfor = 'publisher'
let s:s_standsfor = 'series'
let s:S_standsfor = 'school'
let s:t_standsfor = 'title'
let s:T_standsfor = 'type'
let s:u_standsfor = 'url'
let s:U_standsfor = 'urldate'
let s:v_standsfor = 'volume'
let s:y_standsfor = 'year'

" }}}
" Define the fields required for the various entry types {{{
"
" s:{type}_required defines the required fields
" s:{type}_optional1 defines common optional fields
" s:{type}_optional2 defines uncommmon optional fields
" s:{type}_retval defines the first line of the formatted bib entry.
"
let s:key='<+key+>'

let s:{'article'}_required="atjyvnpmd"
let s:{'article'}_optional1="huU"
let s:{'article'}_optional2="N"
let s:{'article'}_retval = '@article{' . s:key . ','."\n"

let s:{'book'}_required="abevlPyp"
let s:{'book'}_optional1="huU"
let s:{'book'}_optional2="I"
let s:{'book'}_retval = '@book{' . s:key . ','."\n"

let s:{'dataset'}_required="ayth"
let s:{'dataset'}_optional1="uU"
let s:{'dataset'}_optional2="N"
let s:{'dataset'}_retval = '@dataset{' . s:key . ','."\n"

"let s:{'booklet'}_required="t"
"let s:{'booklet'}_optional1="ahy"
"let s:{'booklet'}_optional2="wmz" " w is address
"let s:{'booklet'}_retval = '@BOOKLET{' . s:key . ','."\n"

let s:{'inbook'}_required="atbevElPycp"
let s:{'inbook'}_optional1="huU"
let s:{'inbook'}_optional2="I"
let s:{'inbook'}_retval = '@inbook{' . s:key . ','."\n"

"let s:{'incollection'}_required="atbqy" " b is booktitle
"let s:{'incollection'}_optional1="cpw" " w is address, c is chapter
"let s:{'incollection'}_optional2="evnsudmz" " d is edition
"let s:{'incollection'}_extras="k" " isbn
"let s:{'incollection'}_retval = '@INCOLLECTION{' . s:key . ','."\n"

"let s:{'inproceedings'}_required="atby" " b is booktitle
"let s:{'inproceedings'}_optional1="epwoq" " w is address, q is publisher
"let s:{'inproceedings'}_optional2="vnsmz"
"let s:{'inproceedings'}_extras="k" " isbn
"let s:{'inproceedings'}_retval = '@INPROCEEDINGS{' . s:key . ','."\n"

"let s:{'conference'}_required="atby" " b is booktitle
"let s:{'conference'}_optional1="epwoq" " w is address, q is publisher
"let s:{'conference'}_optional2="vnsmz"
"let s:{'conference'}_extras="k" " isbn
"let s:{'conference'}_retval = '@CONFERENCE{' . s:key . ','."\n"

let s:{'manual'}_required="tlPy"
let s:{'manual'}_optional1="huU"
let s:{'manual'}_optional2="N"
let s:{'manual'}_retval = '@manual{' . s:key . ','."\n"

"let s:{'msthesis'}_required="atry" " r is school
"let s:{'msthesis'}_optional1="w" " w is address
"let s:{'msthesis'}_optional2="umz" " u is type, w is address
"let s:{'msthesis'}_retval = '@MASTERSTHESIS{' . s:key . ','."\n"

let s:{'misc'}_required="aty"
let s:{'misc'}_optional1="huU"
let s:{'misc'}_optional2="N"
let s:{'misc'}_retval = '@misc{' . s:key . ','."\n"

"let s:{'phdthesis'}_required="atry" " r is school
"let s:{'phdthesis'}_optional1="w" " w is address
"let s:{'phdthesis'}_optional2="umz" " u is type
"let s:{'phdthesis'}_retval = '@PHDTHESIS{' . s:key . ','."\n"

"let s:{'proceedings'}_required="ty"
"let s:{'proceedings'}_optional1="ewo" " w is address
"let s:{'proceedings'}_optional2="vnsmqz" " q is publisher
"let s:{'proceedings'}_retval = '@PROCEEDINGS{' . s:key . ','."\n"

"let s:{'techreport'}_required="atiy"
"let s:{'techreport'}_optional1="unw" " u is type, w is address
"let s:{'techreport'}_optional2="mz"
"let s:{'techreport'}_retval = '@TECHREPORT{' . s:key . ','."\n"

let s:{'thesis'}_required="atTily" " r is school
let s:{'thesis'}_optional1="huU" " w is address
let s:{'thesis'}_optional2="N" " u is type
let s:{'thesis'}_retval = '@thesis{' . s:key . ','."\n"

"let s:{'unpublished'}_required="atz"
"let s:{'unpublished'}_optional1="y"
"let s:{'unpublished'}_optional2="m"
"let s:{'unpublished'}_retval = '@UNPUBLISHED{' . s:key . ','."\n"

" }}}

if exists('s:done')
	finish
endif
let s:done = 1

call IMAP ('BBB', "\<C-r>=BibT('', '', 0)\<CR>", 'bib')
call IMAP ('BBL', "\<C-r>=BibT('', 'o', 0)\<CR>", 'bib')
call IMAP ('BBH', "\<C-r>=BibT('', 'O', 0)\<CR>", 'bib')
call IMAP ('BBX', "\<C-r>=BibT('', 'Ox', 0)\<CR>", 'bib')

let g:Bib_Leader = '`'
call IMAP (g:Bib_Leader.'au', 'author = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'ad', 'address = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'bo', 'booktitle = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'ch', 'chapter = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'do', 'doi = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'en', 'edition = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'er', 'editor = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'ho', 'howpublished = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'in', 'institution = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'is', 'isbn = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'jo', 'journal = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'lo', 'location = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'la', 'language = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'mo', 'month = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'nu', 'number = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'no', 'note = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'or', 'organization = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'pa', 'pages = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'pu', 'publisher = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'se', 'series = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'sc', 'school = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'ti', 'title = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'ty', 'type = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'ur', 'url = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'ud', 'urldate = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'vo', 'volume = {<++>},<++>', "bib")
call IMAP (g:Bib_Leader.'ye', 'year = {<++>},<++>', "bib")

" BibT: function to generate a formatted bibtex entry {{{
" three sample usages:
"   :call BibT()                    will request type choice
"   :call BibT("article")           preferred, provides most common fields
"   :call BibT("article","ox")      more optional fields (o) and extras (x)
"
" Input Arguments:
" type: is one of the types listed above. (this should be a complete name, not
"       the acronym).
" options: a string containing 0 or more of the letters 'oOx'
"          where
"          o: include a bib entry with first set of options
"          O: include a bib entry with extended options
"          x: incude bib entry with extra options
" prompt: whether the fields are asked to be filled on the command prompt or
"         whether place-holders are used. when prompt == 1, then comman line
"         questions are used.
"
" Returns:
" a string containing a formatted bib entry
function BibT(type, options, prompt)
	if a:type != ''
		let choosetype = a:type
	else
		let types =
			\ 'article'."\n".
			"\ 'booklet'."\n".
			\ 'book'."\n".
			"\ 'conference'."\n".
			\ 'dataset'."\n".
			\ 'inbook'."\n".
			"\ 'incollection'."\n".
			"\ 'inproceedings'."\n".
			\ 'manual'."\n".
			"\ 'msthesis'."\n".
			\ 'misc'."\n".
			\ 'online'."\n".
			"\ 'phdthesis'."\n".
			"\ 'proceedings'."\n".
			"\ 'techreport'."\n".
			\ 'thesis'
			"\ 'unpublished'
		let choosetype = Tex_ChooseFromPrompt(
					\ "Choose the type of bibliographic entry: \n" .
					\ Tex_CreatePrompt(types, 3, "\n") .
					\ "\nEnter number or filename :",
					\ types, "\n")
		if choosetype == ''
			let choosetype = 'article'
		endif
		if types !~ '^\|\n'.choosetype.'$\|\n'
			echomsg 'Please choose only one of the given types'
			return
		endif
	endif
	if a:options != ''
		let options = a:options
	else
		let options = ""
	endif

	let fields = ''
	let extras=""
	let retval = ""

	" define fields
	let fields = s:{choosetype}_required
	if options =~ 'o' && exists('s:'.choosetype.'_optional1')
		let fields = fields . s:{choosetype}_optional1
	endif
	if options =~ "O" && exists('s:'.choosetype.'_optional2')
		if options !~ 'o'&& exists('s:'.choosetype.'_optional1')
			let fields = fields . s:{choosetype}_optional1
		endif
		let fields = fields . s:{choosetype}_optional2
	endif
	if options =~ "x" && exists('s:'.choosetype.'_extras')
		let fields = fields . extras
	endif
	if exists('g:Bib_'.choosetype.'_options')
		let fields = fields . g:Bib_{choosetype}_options
	endif

	let retval = s:{choosetype}_retval

	let i = 0
	while i < strlen(fields)
		let field = strpart(fields, i, 1)

		if exists('s:'.field.'_standsfor')
			let field_name = s:{field}_standsfor
			let retval = retval.field_name." = {<++>},\n"
		endif

		let i = i + 1
	endwhile

	" If the user wants even more fine-tuning...
	if Tex_GetVarValue('Bib_'.choosetype.'_extrafields') != ''

		let extrafields = Tex_GetVarValue('Bib_'.choosetype.'_extrafields')

		let i = 1
		while 1
			let field_name = Tex_Strntok(extrafields, "\n", i)
			if field_name == ''
				break
			endif

			let retval = retval.field_name." = {<++>},\n"

			let i = i + 1
		endwhile

	endif

	let retval = retval.'otherinfo = {<++>}'."\n"
	let retval = retval."}<++>"."\n"

	return IMAP_PutTextWithMovement(retval)
endfunction

" }}}

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4
