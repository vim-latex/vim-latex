" ============================================================================
" 	     File: latexm.vim
"      Author: Srinath Avadhanula
"     Created: Sat Jul 05 03:00 PM 2003 
" Description: compile a .tex file multiple times to get cross references
"              right.
"     License: Vim Charityware License
"              Part of vim-latexSuite: http://vim-latex.sourceforge.net
"         CVS: $Id$
" ============================================================================

" Tex_CompileMultipleTimes: The main function {{{
" Description: compiles a file multiple times to get cross-references right.
function! Tex_CompileMultipleTimes()
	let mainFileName_root = Tex_GetMainFileName(':p:t:r:r')

	if mainFileName_root == ''
		let mainFileName_root = expand("%:p:t:r")
	endif

	let idxFileName = mainFileName_root.'.idx'


	let runCount = 0
	let needToRerun = 1
	while needToRerun == 1 && runCount < 5
		" assume we need to run only once.
		let needToRerun = 0

		let idxlinesBefore = Tex_CatFile(idxFileName)

		" first run latex once.
		echomsg "latex run number : ".(runCount+1)
		silent! call Tex_CompileLatex()

		let idxlinesAfter = Tex_CatFile(idxFileName)

		" If .idx file changed, then run makeindex to generate the new .ind
		" file and remember to rerun latex.
		if runCount == 0 && glob(idxFileName) != '' && idxlinesAfter != idxlinesAfter
			echomsg "Running makeindex..."
			let temp_mp = &mp | let &mp='makeindex $*.idx'
			exec 'silent! make '.mainFileName_root
			let &mp = temp_mp

			let needToRerun = 1
		endif

		" The first time we see if we need to run bibtex
		if runCount == 0 && Tex_IsPresentInFile('\\bibdata', mainFileName_root.'.aux')
			let bibFileName = mainFileName_root . '.bbl'

			let biblinesBefore = Tex_CatFile(bibFileName)
			call Tex_Debug('bibbefore = ['.biblinesBefore.']', 'comp')

			echomsg "Running bibtex..."
			let temp_mp = &mp | let &mp='bibtex'
			exec 'silent! make '.mainFileName_root
			let &mp = temp_mp

			let biblinesAfter = Tex_CatFile(bibFileName)
			call Tex_Debug('bibafter = ['.biblinesAfter.']', 'comp')

			" If the .bbl file changed after running bibtex, we need to
			" latex again.
			if biblinesAfter != biblinesBefore
				echomsg 'Need to rerun because bibliography file changed...'
				let needToRerun = 1
			endif
		endif

		" check if latex asks us to rerun
		if Tex_IsPresentInFile('Rerun to get cross-references right', mainFileName_root.'.log')
			echomsg "Need to rerun to get cross-references right..."
			let needToRerun = 1
		endif

		let runCount = runCount + 1
	endwhile

	echomsg "Ran latex ".runCount." time(s)"

	" After all compiler calls are done, reparse the .log file for
	" errors/warnings to handle the situation where the clist might have been
	" emptied because of bibtex/makeindex being run as the last step.
	exec 'silent! cfile '.mainFileName_root.'.log'
endfunction " }}}

" Various helper functions used by Tex_CompileMultipleTimes(). These functions
" use python where available (and allowed) otherwise do it in native vim at
" the cost of some slowdown and a new temporary buffer being added to the
" buffer list.
" Tex_GotoTempFile: open a temp file. reuse from next time on {{{
" Description: 
function! Tex_GotoTempFile()
	if !exists('s:tempFileName')
		let s:tempFileName = tempname()
	endif
	exec 'silent! split '.s:tempFileName
endfunction " }}}
" Tex_IsPresentInFile: finds if a string str, is present in filename {{{
" Description: 
function! Tex_IsPresentInFile(regexp, filename)
	if has('python') && g:Tex_UsePython
		exec 'python isPresentInFile(r"'.a:regexp.'", r"'.a:filename.'")'
	else
		call Tex_GotoTempFile()

		silent! 1,$ d _
		let _report = &report
		let _sc = &sc
		set report=9999999 nosc
		exec 'silent! 0r! '.g:Tex_CatCmd.' '.a:filename
		set nomod
		let &report = _report
		let &sc = _sc

		if search(a:regexp, 'w')
			let retval = 1
		else
			let retval = 0
		endif
		silent! bd
	endif

	return retval
endfunction " }}}
" Tex_CatFile: returns the contents of a file in a <NL> seperated string {{{
function! Tex_CatFile(filename)
	if has('python') && g:Tex_UsePython
		" catFile assigns a value to retval
		exec 'python catFile("'.a:filename.'")'
	else
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
		let @a = _a

		silent! bd
		let &report = _report
		let &sc = _sc
	endif
	return retval
endfunction
" }}}

" Define the functions in python if available.
if !has('python') || !g:Tex_UsePython
	finish
endif

python <<EOF
import string, vim, re
# catFile: assigns a local variable retval to the contents of a file {{{
def catFile(filename):
	try:
		file = open(filename)
		lines = ''.join(file.readlines())
		file.close()
	except:
		lines = ''

	# escape double quotes and backslashes before quoting the string so
	# everything passes throught.
	vim.command("""let retval = "%s" """ % re.sub(r'"|\\', r'\\\g<0>', lines))
	return lines

# }}}
# isPresentInFile: check if regexp is present in the file {{{
def isPresentInFile(regexp, filename):
	try:
		fp = open(filename)
		fcontents = string.join(fp.readlines(), '')
		fp.close()
		if re.search(regexp, fcontents):
			vim.command('let retval = 1')
			return 1
		else:
			vim.command('let retval = 0')
			return None
	except:
		vim.command('let retval = 0')
		return None

# }}}
EOF

" vim:fdm=marker:nowrap:noet:ff=unix:ts=4:sw=4
