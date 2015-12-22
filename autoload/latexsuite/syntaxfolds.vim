
" Function: AddSyntaxFoldItem (start, end, startoff, endoff [, skipStart, skipEnd]) {{{
function! latexsuite#sytaxfolds#AddSyntaxFoldItem(start, end, startoff, endoff, ...)
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
" Description: This function calls FoldRegions() several times with the
"     parameters specifying various regions resulting in a nested fold
"     structure for the file.
function! latexsuite#sytaxfolds#MakeSyntaxFolds(force, ...)
	if exists('b:doneFolding') && a:force == 0
		return
	end

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
			call InitStack('BeginSkipArray')
			call FoldRegionsWithSkip(startPat, endPat, startOff, endOff, skipStart, skipEnd, 1, line('$'))
			" call PrintError('done folding ['.startPat.']')
		else
			call FoldRegionsWithNoSkip(startPat, endPat, startOff, endOff, 1, line('$'), '')
		end

		let i = i + 1
	endwhile

	exe maxline

	if a:0 == 0
		exe r
		exe "normal! ".c."|"
		if foldlevel(r) > 1
			exe "normal! ".(foldlevel(r) - 1)."zo"
		end
		let b:doneFolding = 0
	end
endfunction


" }}}
" FoldRegionsWithSkip: folding things such as \item's which can be nested. {{{
function! latexsuite#sytaxfolds#FoldRegionsWithSkip(startpat, endpat, startoff, endoff, startskip, endskip, line1, line2)
	exe a:line1
	" count the regions which have been skipped as we go along. do not want to
	" create a fold which with a beginning or end line in one of the skipped
	" regions.
	let skippedRegions = ''

	" start searching for either the starting pattern or the end pattern.
	while search(a:startskip.'\|'.a:endskip, 'W')

		if getline('.') =~ a:endskip

			let lastBegin = Pop('BeginSkipArray')
			" call PrintError('popping '.lastBegin.' from stack and folding till '.line('.'))
			call FoldRegionsWithNoSkip(a:startpat, a:endpat, a:startoff, a:endoff, lastBegin, line('.'), skippedRegions)
			let skippedRegions = skippedRegions.lastBegin.','.line('.').'|'


		" if this is the beginning of a skip region, then, push this line as
		" the beginning of a skipped region.
		elseif getline('.') =~ a:startskip

			" call PrintError('pushing '.line('.').' ['.getline('.').'] into stack')
			call Push('BeginSkipArray', line('.'))

		end
	endwhile

	" call PrintError('with skip starting at '.a:line1.' returning at line# '.line('.'))
endfunction

" }}}
" FoldRegionsWithNoSkip: folding things such as \sections which do not nest. {{{
function! latexsuite#sytaxfolds#FoldRegionsWithNoSkip(startpat, endpat, startoff, endoff, line1, line2, skippedRegions)
	exe a:line1

	" call PrintError('line1 = '.a:line1.', searching from '.line('.').'... for ['.a:startpat.'')
	let lineBegin = s:MySearch(a:startpat, 'in')
	" call PrintError('... and finding it at '.lineBegin)

	while lineBegin <= a:line2
		if IsInSkippedRegion(lineBegin, a:skippedRegions)
			let lineBegin = s:MySearch(a:startpat, 'out')
			" call PrintError(lineBegin.' is being skipped')
			continue
		end
		let lineEnd = s:MySearch(a:endpat, 'out')
		while IsInSkippedRegion(lineEnd, a:skippedRegions) && lineEnd <= a:line2
			let lineEnd = s:MySearch(a:endpat, 'out')
		endwhile
		if lineEnd > a:line2
			exe (lineBegin + a:startoff).','.a:line2.' fold'
			break
		else
			" call PrintError ('for ['.a:startpat.'] '.(lineBegin + a:startoff).','.(lineEnd + a:endoff).' fold')
			exe (lineBegin + a:startoff).','.(lineEnd + a:endoff).' fold'
		end

		" call PrintError('line1 = '.a:line1.', searching from '.line('.').'... for ['.a:startpat.'')
		let lineBegin = s:MySearch(a:startpat, 'in')
		" call PrintError('... and finding it at '.lineBegin)
	endwhile

	exe a:line2
	return
endfunction

" }}}
" InitStack: initialize a stack {{{
function! latexsuite#sytaxfolds#InitStack(name)
	exe 'let s:'.a:name.'_numElems = 0'
endfunction
" }}}
" Push: push element into stack {{{
function! latexsuite#sytaxfolds#Push(name, elem)
	exe 'let numElems = s:'.a:name.'_numElems'
	let numElems = numElems + 1
	exe 'let s:'.a:name.'_Element_'.numElems.' = a:elem'
	exe 'let s:'.a:name.'_numElems = numElems'
endfunction
" }}}
" Pop: pops element off stack {{{
function! latexsuite#sytaxfolds#Pop(name)
	exe 'let numElems = s:'.a:name.'_numElems'
	if numElems == 0
		return ''
	else
		exe 'let ret = s:'.a:name.'_Element_'.numElems
		let numElems = numElems - 1
		exe 'let s:'.a:name.'_numElems = numElems'
		return ret
	end
endfunction
" }}}
" MySearch: just like search(), but returns large number on failure {{{
function! s:MySearch(pat, opt)
	if a:opt == 'in'
		if getline('.') =~ a:pat
			let ret = line('.')
		else
			let ret = search(a:pat, 'W')
		end
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
function! latexsuite#sytaxfolds#IsInSkippedRegion(lnum, regions)
	let i = 1
	let subset = s:Strntok(a:regions, '|', i)
	while subset != ''
		let n1 = s:Strntok(subset, ',', 1)
		let n2 = s:Strntok(subset, ',', 2)
		if a:lnum >= n1 && a:lnum <= n2
			return 1
		end

		let subset = s:Strntok(a:regions, '|', i)
		let i = i + 1
	endwhile

	return 0
endfunction " }}}
" Function: Strntok (string, tok, n) {{{
" extract the n^th token from s seperated by tok.
" example: Strntok('1,23,3', ',', 2) = 23
fun! s:Strntok(s, tok, n)
	return matchstr( a:s.a:tok[0], '\v(\zs([^'.a:tok.']*)\ze['.a:tok.']){'.a:n.'}')
endfun " }}}

" vim600:fdm=marker
