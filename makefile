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
	zip latexSuite.zip ltags
	make -s zip2tar
zip2tar:
	# copy over zip file to temp dir.
	mkdir -p $(TMP)/latexSuite0793
	cp latexSuite.zip $(TMP)/latexSuite0793/
	# now unzip the .zip file there, and create a .tar.gz file from the
	# directory contents.
	( \
		cd $(TMP)/latexSuite0793/ ; \
		unzip -o latexSuite.zip ; \
		\rm latexSuite.zip ; \
		tar cvzf latexSuite.tar.gz * \
	)
	\mv $(TMP)/latexSuite0793/latexSuite.tar.gz ./
clean:
	rm -f latexSuite.zip
ltt:
	rm -rf /tmp/ltt/vimfiles/ftplugin
	cp -f latexSuite.zip /tmp/ltt/vimfiles/
	cd /tmp/ltt/vimfiles; unzip latexSuite.zip
upload:
	pscp latexSuite.* $(CVSUSER)@vim-latex.sf.net:/home/groups/v/vi/vim-latex/htdocs/download/
