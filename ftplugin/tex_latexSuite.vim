" LaTeX filetype
"	  Language: LaTeX (ft=tex)
"	Maintainer: Srinath Avadhanula
"		 Email: srinath@fastmail.fm
"		   URL: 
"  Last Change: Fri Apr 12 09:00 PM 2002 PDT

if exists('b:didLatexSuite')
	finish
endif
let b:didLatexSuite = 1
exec 'so '.expand('<sfile>:p:h').'/latex-suite/main.vim'
