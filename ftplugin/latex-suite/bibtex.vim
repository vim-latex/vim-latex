"=============================================================================
" 	       File: bibtex.vim
"      Function: BibT
"        Author: Alan G Isaac <aisaac@american.edu>
"   Last Change: Fri Apr 26 10:00 PM 2002 PDT
"=============================================================================

if exists('s:done')
	finish
endif
let s:done = 1

call IMAP ('BBA', "\<C-r>=BibT('article', '', 0)\<CR>", 'bib')
call IMAP ('BBB', "\<C-r>=BibT('inproceedings', '', 0)\<CR>", 'bib')
call IMAP ('BAS', "\<C-r>=BibT('', '', 0)\<CR>", 'bib')

" BibT: function to generate a formatted bibtex entry {{{
" three sample usages:
"   :call BibT()                    will request type choice
"   :call BibT("article")           preferred, provides most common fields
"   :call BibT("article","ox")      more optional fields (o) and extras (x)
"
function BibT(type, options, prompt)
	if a:type != ''
		let choosetype = a:type
	else
		let choosetype=input("Enter type (type in whole word!):\n".
			\" article\tbooklet\t\tbook\t\tconference\n".
			\" inbook\t\tincollection\tinproceedings\tmanual\n".
			\" msthesis\tmisc\t\tphdthesis\tproceedings\n".
			\" techreport\tunpublished\n\n:"
			\)
		if choosetype == ''
			let choosetype = 'article'
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
	let key='«key»'

	" characterize entry types
	if choosetype ==? "article"
		let required="atjy"
		let optional1="vnpm"
		let optional2="z" " z is note
		let retval = retval.'@ARTICLE{' . key . ','."\n"
	endif
	if choosetype ==? "book"
		let required="ætqy" " requires author *or* editor
		let optional1="wd"
		let optional2="vnsmz" " w is address, d is edition
		let extras="k" " isbn
		let retval = retval.'@BOOK{' . key . ','."\n"
	endif
	if choosetype ==? "booklet"
		let required="t"
		let optional1="ahy"
		let optional2="wmz" " w is address
		let retval = retval.'@BOOKLET{' . key . ','."\n"
	endif
	if choosetype ==? "inbook"
		let required="ætcpqy"
		let optional1="w" " w is address
		let optional2="vnsudmz" " d is edition
		let extras="k" " isbn
		let retval = retval.'@INBOOK{' . key . ','."\n"
	endif
	if choosetype ==? "incollection"
		let required="atbqy" " b is booktitle
		let optional1="cpw" " w is address, c is chapter
		let optional2="evnsudmz" " d is edition
		let extras="k" " isbn
		let retval = retval.'@INCOLLECTION{' . key . ','."\n"
	endif
	if choosetype ==? "inproceedings"
		let required="atby" " b is booktitle
		let optional1="epwoq" " w is address, q is publisher
		let optional2="vnsmz"
		let extras="k" " isbn
		let retval = retval.'@INPROCEEDINGS{' . key . ','."\n"
	endif
	if choosetype ==? "manual"
		let required="t"
		let optional1="ow"
		let optional2="admyz" " w is address
		let retval = retval.'@MANUAL{' . key . ','."\n"
	endif
	if choosetype ==? "msthesis"
		let required="atry" " r is school
		let optional1="w" " w is address
		let optional2="umz" " u is type, w is address
		let retval = retval.'@MASTERSTHESIS{' . key . ','."\n"
	endif
	if choosetype ==? "misc"
		let required=""
		let optional1="ath"
		let optional2="myz"
		let retval = retval.'@MISC{' . key . ','."\n"
	endif
	if choosetype ==? "phdthesis"
		let required="atry" " r is school
		let optional1="w" " w is address
		let optional2="umz" " u is type
		let retval = retval.'@PHDTHESIS{' . key . ','."\n"
	endif
	if choosetype ==? "proceedings"
		let required="ty"
		let optional1="ewo" " w is address
		let optional2="vnsmqz" " q is publisher
		let retval = retval.'@PROCEEDINGS{' . key . ','."\n"
	endif
	if choosetype ==? "techreport"
		let required="atiy"
		let optional1="unw" " u is type, w is address
		let optional2="mz"
		let retval = retval.'@TECHREPORT{' . key . ','."\n"
	endif
	if choosetype ==? "unpublished"
		let required="atz"
		let optional1="y"
		let optional2="m"
		let retval = retval.'@UNPUBLISHED{' . key . ','."\n"
	endif

	" define fields
	let fields = required
	if options =~ 'o'
		let fields = fields . optional1
	endif
	if options =~ "O"
		if options !~ 'o'
			let fields = fields . optional1
		endif
		let fields = fields . optional2
	endif
	if options =~ "x"
		let fields = fields . extras
	endif

	" implement fields
	if fields =~ "[aæ]"
		let author=s:Input("Author(s)? ", a:prompt)
		if author!="" || required =~ "a"
			let retval = retval.'author = {' . author . '},'."\n"
		endif
	endif
	if fields =~ "[eæ]"
		let editor=s:Input("Editor(s)? ", a:prompt)
		if editor!="" || required =~ "e"
			let retval = retval.'editor = {' . editor . '},'."\n"
		endif
	endif
	if fields =~ "y"
		let year=s:Input("Year? ", a:prompt)
		let retval = retval.'year = ' . year . ','."\n"
	endif
	if fields =~ "t"
		let title=s:Input("title? ", a:prompt)
		let retval = retval.'title = {' . title . '},'."\n"
	endif
	if fields =~ "b" " booktitle
		let booktitle=s:Input("booktitle? ", a:prompt)
		let retval = retval.'booktitle = {' . booktitle . '},'."\n"
	endif
	if fields =~ "d" " edition
		let edition=s:Input("edition? (E.g., 2nd) ", a:prompt)
		let retval = retval.'edition = {' . edition . '},'."\n"
	endif
	if fields =~ "c" " chapter
		let chapter=s:Input("chapter? ", a:prompt)
		if chapter !=""
			let retval = retval.'chapter = {' . chapter . '},'."\n"
		endif
	endif
	if fields =~ "j" " journal
		let jrnlkey=s:Input("{Journal Name} (in braces) or journal key? ", a:prompt)
		if jrnlkey != ""
			let retval = retval.'journal = ' . jrnlkey . ','."\n"
		else
			let retval = retval.'journal = {},'."\n"
		endif
	endif
	if fields =~ "v"
		let volume=s:Input("volume? ", a:prompt)
		if volume !=""
			let retval = retval.'volume = ' . volume . ','."\n"
		endif
	endif
	if fields =~ "n"
		let number=s:Input("number? ", a:prompt)
		if number !=""
			let retval = retval.'number = ' . number . ','."\n"
		endif
	endif
	if fields =~ "m"
		let month=s:Input("month? ", a:prompt)
		if month !=""
			let retval = retval.'month = ' . month . ','."\n"
		endif
	endif
	if fields =~ "p"
		let pages=s:Input("pages? ", a:prompt)
		let retval = retval.'pages = {' . pages . '},'."\n"
	endif
	if fields =~ "q"
		let publisher=s:Input("publisher? ", a:prompt)
		let retval = retval.'publisher = {' . publisher . '},'."\n"
	endif
	if fields =~ "w"
		let address=s:Input("address? ", a:prompt)
		let retval = retval.'address = {' . address . '},'."\n"
	endif
	if fields =~ "h"
		let howpublished=s:Input("howpublished? ", a:prompt)
		let retval = retval.'howpublished = {' . howpublished . '},'."\n"
	endif
	if fields =~ "i"
		let institution=s:Input("institution? ", a:prompt)
		let retval = retval.'institution = {' . institution . '},'."\n"
	endif
	if fields =~ "o"
		let organization=s:Input("organization? ", a:prompt)
		let retval = retval.'organization = {' . organization . '},'."\n"
	endif
	if fields =~ "r"
		let school=s:Input("school? ", a:prompt)
		let retval = retval.'school = {' . school . '},'."\n"
	endif
	if fields =~ "s"
		let series=s:Input("series? ", a:prompt)
		let retval = retval.'series = {' . series . '},'."\n"
	endif
	if fields =~ "u"
		let type=s:Input("type? (E.g., Working Paper)", a:prompt)
		let retval = retval.'type = {' . type . '},'."\n"
	endif
	if fields =~ "k"
		let isbn=s:Input("isbn? ", a:prompt)
		if isbn !=""
			let retval = retval.'isbn = {' . isbn . '},'."\n"
		endif
	endif
	let retval = retval.'otherinfo = {«»}'."\n"
	let retval = retval."}«»"."\n"

	return IMAP_PutTextWithMovement(retval)
endfunction

" }}}
function! s:Input(prompt, ask) " {{{
	if a:ask == 1
		let retval = input(a:prompt)
		if retval == ''
			return "«»"
		endif
	else
		return "«»"
	endif
endfunction 

" }}}

" vim:fdm=marker
