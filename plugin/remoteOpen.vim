" File: remoteOpen.vim
" Author: Srinath Avadhanula <srinath AT fastmail DOT fm>
"
" Description:
" Often times, an external program needs to open a file in gvim from the
" command line. However, it will not know if the file is already opened in a
" previous vim session. It is not sufficient to simply specify
"
" gvim --remote-silent <filename>
"
" because this simply opens up <filename> in the first remote gvim session it
" sees. This script provides a command RemoteOpen which is meant to be used
" from the command line as follows:
"
" gvim -c ":RemoteOpen +<lnum> <filename>"
"
" where <lnum> is the line-number you wish <filename> to open to.  What will
" happen is that a new gvim will start up and enquire from all previous
" sessions if <filename> is already open in any of them. If it is, then it
" will edit the file in that session and bring it to the foreground and itself
" quit. Otherwise, it will not quit and instead open up the file for editing
" at <lnum>.
"
" This was mainly created to be used with Yap (the dvi previewer in miktex),
" so you can specify the program for "inverse search" as specified above.
" This ensures that the inverse search uses the correct gvim each time.
"
" Ofcourse, this requires vim with +clientserver. If not, then RemoteOpen just
" opens in the present session.

" Enclose <args> in single quotes so it can be passed as a function argument.
com! -nargs=1 RemoteOpen :call RemoteOpen('<args>')
com! -nargs=? RemoteInsert :call RemoteInsert('<args>')

" RemoteOpen: open a file remotely (if possible) {{{
" Description: checks all open vim windows to see if this file has been opened
"              anywhere and if so, opens it there instead of in this session.
function! RemoteOpen(arglist)
	return latesuite#remoteopen#RemoteOpen(a:arglist)
endfunction " }}}
" RemoteInsert: inserts a \cite'ation remotely (if possible) {{{
" Description:
function! RemoteInsert(...)
	return call('latexsuite#remoteopen#RemoteInsert', a:000)
endfunction " }}}

" vim:ft=vim:ts=4:sw=4:noet:fdm=marker:commentstring=\"\ %s:nowrap
