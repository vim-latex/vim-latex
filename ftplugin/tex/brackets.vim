" ============================================================================
" 	     File: brackets.vim
"         CVS: $Id$
" ============================================================================

" This file is a place-holder so that the zip files created contain this file.
" This is to over-write previous versions of this file which existed in this
" location and have now been moved elsewhere. Overwriting the previous version
" is necessary because multiple files can cause strange problems.
"
" This file should automatically "dissapear" the first time vim exits after
" sourcing a tex file.

if exists('g:Tex_DontRemoveTempFiles') && g:Tex_DontRemoveTempFiles
	finish
endif
" This autocommand ensures that this file is automatically removed when vim
" exits the first time after this file is sourced.
augroup Tex_RemoveTempFiles
	exec "au VimLeave * silent! call delete('".expand('<sfile>:p')."')"
augroup END
