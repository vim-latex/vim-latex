latexs:
	# set of latex-tools for latex.
	# plugins:
	zip latexSuite.zip plugin/imaps.vim
	zip latexSuite.zip plugin/SyntaxFolds.vim
	zip latexSuite.zip plugin/libList.vim
	# ftplugins and others.
	zip latexSuite.zip ftplugin/tex_latexSuite.vim
	zip -R latexSuite.zip `find ftplugin/latex-suite -name '*' | grep -v CVS`
	# documentation
	zip latexSuite.zip doc/latex*.txt
	# indentation
	zip latexSuite.zip indent/tex.vim
	# compiler
	zip latexSuite.zip compiler/tex.vim
	# external tools
	zip latexSuite.zip vimlatex
	zip latexSuite.zip ltags
clean:
	rm -f winmanager.zip
	rm -f flisttree.zip
	rm -f latexSuite.zip
	rm -f minibe.zip
	rm -f all.zip
ltt:
	rm -rf /tmp/ltt/vimfiles/ftplugin
	cp -f latexSuite.zip /tmp/ltt/vimfiles/
	cd /tmp/ltt/vimfiles; unzip latexSuite.zip
