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

" Tex_CompileMultipleTimes: compile a latex file multiple times {{{
" Description: compile a latex file multiple times to get cross-references asd
"              right.
function! Tex_CompileMultipleTimes()
	if has('python') && g:Tex_UsePython
		python compileMultipleTimes()
	else
		call Tex_CompileMultipleTimes_Vim()
			endif
endfunction " }}}

if !has('python') || !g:Tex_UsePython
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
			let retVal = 1
		else
			let retVal = 0
		endif

		silent! bd

		return retVal
	endfunction " }}}
	" Tex_CatFile: returns the contents of the file in a string {{{
	" Description: 
	function! Tex_CatFile(filename)
		call Tex_GotoTempFile()

		silent! 1,$ d _

		let _report = &report
		let _sc = &sc
		set report=9999999 nosc
		exec 'silent! 0r! '.g:Tex_CatCmd.' '.a:filename

		set nomod
		let _a = @a
		silent! normal! ggVG"ay
		let retVal = @a
		let @a = _a

		silent! bd
		let &report = _report
		let &sc = _sc
		return retVal
	endfunction " }}}
	" Tex_CompileMultipleTimes_Vim: vim implementaion of compileMultipleTimes() {{{
	" Description: compiles a file multiple times to get cross-references right.
	function! Tex_CompileMultipleTimes_Vim()
		let mainFileName_root = Tex_GetMainFileName(':p:t:r:r')

		if mainFileName_root == ''
			let mainFileName_root = expand("%:p:t:r")
		endif

		let runCount = 0
		let needToRerun = 1
		while needToRerun == 1 && runCount < 5
			" assume we need to run only once.
			let needToRerun = 0

			" first run latex once.
			silent! call Tex_CompileLatex()

			" The first time we see if we need to run bibtex
			if runCount == 0 && Tex_IsPresentInFile('\\bibdata', mainFileName_root.'.aux')
				let bibFileName = mainFileName_root . '.bbl'

				let biblinesBefore = Tex_CatFile(bibFileName)

				echomsg "running bibtex..."
				let temp_mp = &mp | let &mp='bibtex'
				exec 'silent! make '.mainFileName_root
				let &mp = temp_mp

				let biblinesAfter = Tex_CatFile(bibFileName)

				" If the .bbl file changed after running bibtex, we need to
				" latex again.
				if biblinesAfter != biblinesBefore
					echomsg 'need to rerun because bibliography file changed...'
					let needToRerun = 1
				endif
			endif

			if runCount == 0 && filereadable(mainFileName_root.'.idx')
				let idxFileName = mainFileName_root.'.idx'
				let idxlinesBefore = Tex_CatFile(idxFileName)

				echomsg "running makeindex..."
				let temp_mp = &mp | let &mp='makeindex $*.idx'
				exec 'silent! make '.mainFileName_root
				let &mp = temp_mp

				let idxlinesAfter = Tex_CatFile(idxFileName)

				" If the .idx file changed, then we need to rerun.
				if idxlinesBefore != idxlinesAfter
					echomsg 'need to rerun to get index right...'
					let needToRerun = 1
				endif
			endif

			" check if latex asks us to rerun
			if Tex_IsPresentInFile('Rerun to get cross-references right', mainFileName_root.'.log')
				echomsg "need to rerun to get cross-references right..."
				let needToRerun = 1
			endif

			let runCount = runCount + 1
		endwhile

		" finally set up the error window and the preview of the log
		silent! call Tex_SetupErrorWindow()
	endfunction " }}}

	finish
endif

python <<EOF
import vim
import re, os, string

# isPresentInFile: check if regexp is present in the file {{{
def isPresentInFile(regexp, filename):
	try:
		fp = open(filename)
		fcontents = string.join(fp.readlines(), '')
		fp.close()
		if re.search(regexp, fcontents):
			return 1
		else:
			return None
	except:
		return None

# }}}
# catFile: return the contents of a file. {{{
def catFile(fileName):
	try:
		file = open(fileName)
		lines = string.join(file.readlines(), '')
		file.close()
	except:
		lines = ''
	return lines

# }}}
# compileMultipleTimes: compile the main file multiple times as needed. {{{
def compileMultipleTimes():
	mainFileName_full = vim.eval("Tex_GetMainFileName(':p:r')")
	mainFileName_root = vim.eval("Tex_GetMainFileName(':p:r:r')")

	if not mainFileName_root:
		mainFileName_full = vim.eval('expand("%:p")')
		mainFileName_root = vim.eval('expand("%:p:r")')
	
	runCount = 0
	needToRerun = 1
	while needToRerun == 1 and runCount < 5:
		needToRerun = 0

		# first run latex once.
		vim.command('silent! call Tex_CompileLatex()')

		if runCount == 0 and isPresentInFile(r'\\bibdata', mainFileName_root + '.aux'):
			bibFileName = mainFileName_root + '.bbl'

			biblinesBefore = catFile(bibFileName)

			vim.command('echomsg "running bibtex..."')
			vim.command('let temp_mp = &mp | let &mp=\'bibtex\'')
			vim.command('silent! make %s' % mainFileName_root)
			vim.command('let &mp = temp_mp')

			biblinesAfter = catFile(bibFileName)

			# if the .bbl file changed with this bibtex command, then we need
			# to rerun latex to refresh the bibliography
			if biblinesAfter != biblinesBefore:
				vim.command("echomsg 'need to rerun because bibliography file changed...'")
				needToRerun = 1

		# The first time see if a .idx file has been created. If so we need to
		# run makeindex.
		if runCount == 0 and os.path.exists(mainFileName_root + '.idx'):
			idxFileName = mainFileName_root + '.idx'
			idxlinesBefore = catFile(idxFileName)

			vim.command('echomsg "running makeindex..."')
			vim.command("""let temp_mp = &mp | let &mp='makeindex $*.idx'""")
			vim.command("""silent! make %s""" % mainFileName_root)
			vim.command("""let &mp = temp_mp""")

			idxlinesAfter = Tex_CatFile(idxFileName)

			# If the .idx file changed, then we need to rerun.
			if idxlinesBefore != idxlinesAfter:
				vim.command("echomsg 'need to rerun to get index right...'")
				needToRerun = 1

		# check if latex asks us to rerun
		if isPresentInFile('Rerun to get cross-references right', mainFileName_root + '.log'):
			vim.command('echomsg "need to rerun to get cross-references right..."')
			needToRerun = 1

		runCount = runCount + 1

	# finally set up the error window and the preview of the log
	vim.command('echomsg "ran latex a total of %d times"' % runCount)
	vim.command('silent! call Tex_SetupErrorWindow()')
# }}}
EOF

" vim:fdm=marker:nowrap:noet:ff=unix:ts=4:sw=4
