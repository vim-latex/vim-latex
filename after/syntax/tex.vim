" Extended syntax support file for LaTeX
" Language:	LaTeX
" Maintainer:	Albin Ahlbäck <albin.ahlback@gmail.com>
" Last Change:	Mar 25, 2022

" Notes: {{{1
"
" Some part copied and many parts derived from Charles E. Campbell's Vim syntax
" file in Vim's Github repository. If you have any questions on how to add more
" syntax, we direct you to that file.

" Avoid Reinclusion: {{{1
if exists("s:doneOnce")
  finish
endif
let s:doneOnce = 1

" Type Styles: {{{1
" amsfonts: {{{2
syn match texTypeStyle		"\\mathbb\>"
syn match texTypeStyle		"\\mathfrak\>"
syn match texTypeStyle		"\\mathscr\>"

" doublestroke: {{{2
syn match texTypeStyle		"\\mathds\>"

" Bad Math: {{{1
" amsmath: {{{2
syn match texBadMath	"\\end\s*{\s*\(align\|alignat\|flalign\|gather\|multline\)\*\=\s*}"

" Math Zones: {{{1
" amsmath: {{{2
call TexNewMathZone("E","align",1)
call TexNewMathZone("F","alignat",1)
call TexNewMathZone("G","flalign",1)
call TexNewMathZone("H","gather",1)
call TexNewMathZone("I","multline",1)

" vim: ts=8 fdm=marker
