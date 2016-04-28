" ==============================================================================
"        File: syntaxFolds.vim
"     Authors: Srinath Avadhanula, Gerd Wachsmuth
"              ( srinath@fastmail.fm )
" Description: Emulation of the syntax folding capability of vim using manual
"              folding
"
" This script provides an emulation of the syntax folding of vim using manual
" folding. Just as in syntax folding, the folds are defined by regions. Each
" region is specified by a call to AddSyntaxFoldItem() which accepts either 4
" or 6 parameters. When it is called with 4 arguments, it is equivalent to
" calling it with 6 arguments with the last two left blank (i.e as empty
" strings).
" The folds are actually created when calling MakeSyntaxFolds().
"
"    call AddSyntaxFoldItem(startpat, endpat, startoff, endoff [, skipStart, skipEnd])
"
"    startpat: a line matching this pattern defines the beginning of a fold.
"    endpat  : a line matching this pattern defines the end of a fold.
"    startoff: this is the offset from the starting line at which folding will
"              actually start
"    endoff  : like startoff, but gives the offset of the actual fold end from
"              the line satisfying endpat.
"              startoff and endoff are necessary when the folding region does
"              not have a specific end pattern corresponding to a start
"              pattern. for example in latex,
"              \begin{section}
"              defines the beginning of a section, but its not necessary to
"              have a corresponding
"              \end{section}
"              the section is assumed to end 1 line _before_ another section
"              starts.
"    startskip: a pattern which defines the beginning of a "skipped" region.
"
"               For example, suppose we define a \itemize fold as follows:
"               startpat =  '^\s*\\item',
"               endpat = '^\s*\\item\|^\s*\\end{\(enumerate\|itemize\|description\)}',
"               startoff = 0,
"               endoff = -1
"
"               This defines a fold which starts with a line beginning with an
"               \item and ending one line before a line beginning with an
"               \item or \end{enumerate} etc.
"
"               Then, as long as \item's are not nested things are fine.
"               However, once items begin to nest, the fold started by one
"               \item can end because of an \item in an \itemize
"               environment within this \item. i.e, the following can happen:
"
"               \begin{itemize}
"               \item Some text <------- fold will start here
"                     This item will contain a nested item
"                     \begin{itemize} <----- fold will end here because next line contains \item...
"                     \item Hello
"                     \end{itemize} <----- ... instead of here.
"               \item Next item of the parent itemize
"               \end{itemize}
"
"               Therefore, in order to completely define a folding item which
"               allows nesting, we need to also define a "skip" pattern.
"               startskip and end skip do that.
"               Leave '' when there is no nesting.
"    endskip: the pattern which defines the end of the "skip" pattern for
"             nested folds.
"
"    Example: 
"    1. A syntax fold region for a latex section is
"           startpat = "\\section{"
"           endpat   = "\\section{"
"           startoff = 0
"           endoff   = -1
"           startskip = ''
"           endskip = ''
"    Note that the start and end patterns are thus the same and endoff has a
"    negative value to capture the effect of a section ending one line before
"    the next starts.
"    2. A syntax fold region for the \itemize environment is:
"           startpat = '^\s*\\item',
"           endpat = '^\s*\\item\|^\s*\\end{\(enumerate\|itemize\|description\)}',
"           startoff = 0,
"           endoff = -1,
"           startskip = '^\s*\\begin{\(enumerate\|itemize\|description\)}',
"           endskip = '^\s*\\end{\(enumerate\|itemize\|description\)}'
"     Note the use of startskip and endskip to allow nesting.
"
"
" Each time a call is made to FoldRegionWith[No]Skip(), all the regions are folded up.
" Nested folds can be created by successive calls to AddSyntaxFoldItem(). See
" MakeTexFolds() for an idea of how this works for latex files.

" Function: AddSyntaxFoldItem (start, end, startoff, endoff [, skipStart, skipEnd]) {{{
function! AddSyntaxFoldItem(start, end, startoff, endoff, ...)
	if a:0 > 0
		let skipStart = a:1
		let skipEnd = a:2
	else
		let skipStart = ''
		let skipEnd = ''
	end
	if !exists('b:numFoldItems')
		let b:numFoldItems = 0
	end
	let b:numFoldItems = b:numFoldItems + 1

	exe 'let b:startPat_'.b:numFoldItems.' = a:start'
	exe 'let b:endPat_'.b:numFoldItems.' = a:end'
	exe 'let b:startOff_'.b:numFoldItems.' = a:startoff'
	exe 'let b:endOff_'.b:numFoldItems.' = a:endoff'
	exe 'let b:skipStartPat_'.b:numFoldItems.' = skipStart'
	exe 'let b:skipEndPat_'.b:numFoldItems.' = skipEnd'
endfunction 
" }}}
" Function: MakeSyntaxFolds (force) {{{
" Description: This function calls FoldRegionsWith[No]Skip() several times with the
"     parameters specifying various regions resulting in a nested fold
"     structure for the file.
function! MakeSyntaxFolds(force, ...)
	if exists('b:doneFolding') && a:force == 0
		return
	end
	let start = reltime()

	let skipEndPattern = ''
	if a:0 > 0
		let line1 = a:1
		let skipEndPattern = '\|'.a:2
	else
		let line1 = 1
		let r = line('.')
		let c = virtcol('.')
		
		setlocal fdm=manual
		normal! zE
	end
	if !exists('b:numFoldItems')
		b:numFoldItems = 1000000
	end
	
	let i = 1

	let maxline = line('.')

	while exists('b:startPat_'.i) && i <= b:numFoldItems
		exe 'let startPat = b:startPat_'.i
		exe 'let endPat = b:endPat_'.i
		exe 'let startOff = b:startOff_'.i
		exe 'let endOff = b:endOff_'.i
		
		let skipStart = ''
		let skipEnd = ''
		if exists('b:skipStartPat_'.i)
			exe 'let skipStart = b:skipStartPat_'.i
			exe 'let skipEnd = b:skipEndPat_'.i
		end
		exe line1
		let lastLoc = line1

		if skipStart != ''
			call FoldRegionsWithSkip(startPat, endPat, startOff, endOff, skipStart, skipEnd, 1, line('$'))
			call s:Debug('done folding ['.startPat.']')
		else
			call FoldRegionsWithNoSkip(startPat, endPat, startOff, endOff, 1, line('$'), [])
		end

		let i = i + 1
	endwhile

	" Close all folds.
	normal zM

	exe maxline
	
	if a:0 == 0
		exe r
		exe "normal! ".c."|"
		if foldlevel(r) > 1
			exe "normal! ".(foldlevel(r) - 1)."zo"
		end
		let b:doneFolding = 0
	end

	" Report a folding performance.
	if exists('*Tex_Debug')
		call Tex_Debug('Finished folding in ' . reltimestr(reltime(start)) . ' seconds.', 'SyntaxFolds')
	end
endfunction
" }}}
" Function: FoldRegionsWithSkip: folding things such as \item's which can be nested. {{{
function! FoldRegionsWithSkip(startpat, endpat, startoff, endoff, startskip, endskip, line1, line2)
	exe a:line1
	" count the regions which have been skipped as we go along. do not want to
	" create a fold which with a beginning or end line in one of the skipped
	" regions.
	let skippedRegions = []

	let BeginSkipArray = []

	" start searching for either the starting pattern or the end pattern.
	while search(a:startskip.'\|'.a:endskip, 'W')
	
		if getline('.') =~ a:endskip

			if len(BeginSkipArray) > 0
				" Get last element:
				let lastBegin = BeginSkipArray[-1]
				" Remove last element:
				let BeginSkipArray = BeginSkipArray[:-2]
				call s:Debug('popping '.lastBegin.' from stack and folding till '.line('.'))
				call FoldRegionsWithNoSkip(a:startpat, a:endpat, a:startoff, a:endoff, lastBegin, line('.'), skippedRegions[-1])
				" Remove last element:
				let skippedRegions = skippedRegions[:-2]

				" The found region should be skipped on higher levels:
				if len(skippedRegions) > 0
					let skippedRegions[-1] = skippedRegions[-1] + [[lastBegin, line('.')]]
				end
			else
				call s:Debug('Found [' . a:endskip . '] on line ' . line('.') . ', but nothing is in BeginSkipArray. Something is wrong here.')
			end

		elseif getline('.') =~ a:startskip
			" if this is the beginning of a skip region, then, push this line as
			" the beginning of a skipped region.
			call s:Debug('pushing '.line('.').' ['.getline('.').'] into stack')
			let BeginSkipArray = BeginSkipArray + [line('.')]
			let skippedRegions = skippedRegions + [[]]

		end
	endwhile

	if len(BeginSkipArray) > 0
		call s:Debug('Finished FoldRegionsWithSkip, but BeginSkipArray is not empty, something is wrong here')
		for i in range(0,len(BeginSkipArray)-1)
			call s:Debug('BeginSkipArray[' . i . '] = ' . BeginSkipArray[i] )
		endfor
	end

	call s:Debug('FoldRegionsWithSkip finished')
endfunction
" }}}
" Function: FoldRegionsWithNoSkip: folding things such as \sections which do not nest. {{{
function! FoldRegionsWithNoSkip(startpat, endpat, startoff, endoff, line1, line2, skippedRegions)
	call s:Debug('line1 = '.a:line1.', line2 = ' . a:line2 . ', skippedRegions = ' . string(a:skippedRegions))

	" Move cursor to (begin of) line1
	exe a:line1
	normal 0

	call s:Debug('searching for ['.a:startpat.']')
	let lineBegin = s:MySearch(a:startpat, 'in')
	call s:Debug('... and finding it at '.lineBegin)

	while lineBegin <= a:line2
		if IsInSkippedRegion(lineBegin, a:skippedRegions)
			let lineBegin = s:MySearch(a:startpat, 'out')
			call s:Debug(lineBegin.' is being skipped')
			continue
		end

		" Move to end of start pattern:
		normal! 0
		call search(a:startpat, 'cWe')

		let lineEnd = s:MySearch(a:endpat, 'out')
		while IsInSkippedRegion(lineEnd, a:skippedRegions) && lineEnd <= a:line2
			let lineEnd = s:MySearch(a:endpat, 'out')
		endwhile
		if lineEnd > a:line2
			exe (lineBegin + a:startoff).','.a:line2.' fold'
			" Open all folds:
			normal zR
			break
		else
			call s:Debug ('for ['.a:startpat.'] '.(lineBegin + a:startoff).','.(lineEnd + a:endoff).' fold')
			exe (lineBegin + a:startoff).','.(lineEnd + a:endoff).' fold'
			" Open all folds:
			normal zR
		end

		call s:Debug('line1 = '.a:line1.', searching from '.line('.').'... for ['.a:startpat.']')
		let lineBegin = s:MySearch(a:startpat, 'in')
		call s:Debug('... and finding it at '.lineBegin)
	endwhile

	" Move cursor to (end of) line2
	exe a:line2
	normal $
	return
endfunction
" }}}
" Function: MySearch: just like search(), but returns large number on failure {{{
function! <SID>MySearch(pat, opt)
	if a:opt == 'in'
		normal! 0
		let ret = search(a:pat, 'cW')
	else
		normal! $
		let ret = search(a:pat, 'W')
	end

	if ret == 0
		let ret = line('$') + 1
	end
	return ret
endfunction
" }}}
" Function: IsInSkippedRegion (lnum, regions) {{{
" Description: finds whether a given line number is within one of the regions
"              skipped.
function! IsInSkippedRegion(lnum, regions)
	for region in a:regions
		if a:lnum >= region[0] && a:lnum <= region[1]
			return 1
		end
	endfor
	return 0
endfunction
" }}}
" Function: Debug: A wrapper for Tex_Debug, if it exists and if g:SyntaxFolds_Debug == 1 {{{
function! <SID>Debug(string)
	if exists('g:SyntaxFolds_Debug') && g:SyntaxFolds_Debug == 1 && exists('*Tex_Debug')
		call Tex_Debug(a:string,'SyntaxFolds')
	end
endfunction
" }}}
" vim600:fdm=marker
