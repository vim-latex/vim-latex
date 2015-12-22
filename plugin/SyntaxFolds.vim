" ==============================================================================
"        File: syntaxFolds.vim
"      Author: Srinath Avadhanula
"              ( srinath@fastmail.fm )
" Last Change: Sun Oct 27 01:00 AM 2002 PST
" Description: Emulation of the syntax folding capability of vim using manual
"              folding
"
" This script provides an emulation of the syntax folding of vim using manual
" folding. Just as in syntax folding, the folds are defined by regions. Each
" region is specified by a call to FoldRegions() which accepts 4 parameters:
"
"    call FoldRegions(startpat, endpat, startoff, endoff)
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
" Each time a call is made to FoldRegions(), all the regions (which might be
" disjoint, but not nested) are folded up.
" Nested folds can be created by successive calls to FoldRegions(). The first
" call defines the region which is deepest in the folding. See MakeTexFolds()
" for an idea of how this works for latex files.

" Function: AddSyntaxFoldItem (start, end, startoff, endoff [, skipStart, skipEnd]) {{{
function! AddSyntaxFoldItem(start, end, startoff, endoff, ...)
	return call('latexsuite#syntaxfolds#AddSyntaxFoldItem', [a:start, a:end, a:startoff, a:endoff]+a:000)
endfunction


" }}}
" Function: MakeSyntaxFolds (force) {{{
" Description: This function calls FoldRegions() several times with the
"     parameters specifying various regions resulting in a nested fold
"     structure for the file.
function! MakeSyntaxFolds(force, ...)
	return call('latexsuite#syntaxfolds#MakeSyntaxFolds', [a:force]+a:000)
endfunction


" }}}
" FoldRegionsWithSkip: folding things such as \item's which can be nested. {{{
function! FoldRegionsWithSkip(startpat, endpat, startoff, endoff, startskip, endskip, line1, line2)
  return latexsuite#syntaxfolds#FoldRegionsWithSkip(a:startpat, a:endpat, a:startoff, a:endoff, a:startskip, a:endskip, a:line1, a:line2)
endfunction

" }}}
" FoldRegionsWithNoSkip: folding things such as \sections which do not nest. {{{
function! FoldRegionsWithNoSkip(startpat, endpat, startoff, endoff, line1, line2, skippedRegions)
	return latexsuite#syntaxfolds#FoldRegionsWithNoSkip(a:startpat, a:endpat, a:startoff, a:endoff, a:line1, a:line2, a:skippedRegions)
endfunction

" }}}
" InitStack: initialize a stack {{{
function! InitStack(name)
	return latexsuite#sytaxfolds#InitStack(a:name)
endfunction
" }}}
" Push: push element into stack {{{
function! Push(name, elem)
	return latexsuite#sytaxfolds#Push(a:name, a:elem)
endfunction
" }}}
" Pop: pops element off stack {{{
function! Pop(name)
	return latexsuite#sytaxfolds#Pop(a:name)
endfunction
" }}}
" Function: IsInSkippedRegion (lnum, regions) {{{
" Description: finds whether a given line number is within one of the regions
"              skipped.
function! IsInSkippedRegion(lnum, regions)
	return latexsuite#sytaxfolds#IsInSkippedRegion(a:lnum, a:regions)
endfunction " }}}

" vim600:fdm=marker
