ifndef CVSUSER
	CVSUSER := srinathava
endif
DIR1 = $(PWD)

# The main target. This creates a latex suite archive (zip and tar.gz
# format) ensuring that all the files in the archive are in unix format so
# unix people can use it too...
latexs:
	# plugins:
	zip latexSuite.zip plugin/imaps.vim
	zip latexSuite.zip plugin/SyntaxFolds.vim
	zip latexSuite.zip plugin/libList.vim
	# ftplugins
	zip latexSuite.zip ftplugin/tex_latexSuite.vim
	# files in the latex-suite directory. Skip the CVS files.
	zip -R latexSuite.zip `find ftplugin/latex-suite -name '*' | grep -v CVS`
	# documentation
	zip latexSuite.zip doc/latex*.txt
	# indentation
	zip latexSuite.zip indent/tex.vim
	# compiler
	zip latexSuite.zip compiler/tex.vim
	# external tools
	zip latexSuite.zip ltags

	# Now to make a tar.gz file from the .zip file.
	mkdir -p $(TMP)/latexSuite0793
	cp latexSuite.zip $(TMP)/latexSuite0793/
	( \
		cd $(TMP)/latexSuite0793/ ; \
		unzip -o latexSuite.zip ; \
		\rm latexSuite.zip ; \
		tar cvzf latexSuite.tar.gz * ; \
		\mv latexSuite.tar.gz $(DIR1)/ ; \
	)

# target for removing archive files.
clean:
	rm -f latexSuite.zip
	rm -f latexSuite.tar.gz

# make a local install directory.
ltt:
	rm -rf /tmp/ltt/vimfiles/ftplugin
	cp -f latexSuite.zip /tmp/ltt/vimfiles/
	cd /tmp/ltt/vimfiles; unzip latexSuite.zip

# upload the archives to the web.
upload:
	pscp latexSuite.* $(CVSUSER)@vim-latex.sf.net:/home/groups/v/vi/vim-latex/htdocs/download/
