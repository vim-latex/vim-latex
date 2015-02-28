# vim-latex
Enhanced LaTeX support for Vim

## SumatraPdf support
I'm sometimes using Vim on windows and I really like [SumatraPdf](http://www.sumatrapdfreader.org/). Since it supports forwards and backwards searching for LaTeX i made a few minor addtions to vim-latex to support this.

### Changes.
I only modified the existing compiler.vim slightly.

### Further setup

####Vim - forward search
First of all be sure that the directory where you have the SumatraPdf exectuable is added to your path. (I use the portable version)
Furthermore you need to add the following lines to your .vimrc to make use of forward/backward searching.
```
let g:Tex_ViewRule_pdf = 'SumatraPDF -reuse-instance' 
let g:Tex_CompileRule_pdf = 'pdflatex -synctex=1 -src-specials -interaction=nonstopmode'
```
Or these if you also use BibLaTeX and want to be sure the index and bibliography is properly compiled when you view the pdf.

```
let g:Tex_ViewRule_pdf = 'SumatraPDF -reuse-instance'
let g:Tex_CompileRule_pdf = 'pdflatex -synctex=1 -src-specials -interaction=nonstopmode $* & bibtex %:r & pdflatex -synctex=1 -src-specials -interaction=nonstopmode $* & pdflatex -synctex=1 -src-specials -interaction=nonstopmode $*'
```

####SumatraPdf - inverse search
Also check that the directory where vim is installed is added to your path.
To configure inverse search in SumatraPdf, go to options and use this as inverse search command.
```
gvim.exe -c ":RemoteOpen +%l %f"
```
