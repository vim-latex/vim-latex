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

# rsync is like cp (copy) on steroids.  Here are some useful options:
# -C	auto ignore like CVS
# -r	recurse into directories
# -t	preserve times
# -u	update (do not overwrite newer files)
# -W	whole files, no incremental checks (default for local usage)
# --existing	only update files that already exist
# --exclude	exclude files matching the pattern
# -n	dry run (for testing)

# Usage:  after "cvs update", do
#   make install [VIMFILES=path/to/vimfiles]
# Before "cvs commit", do
#   make stallin [VIMFILES=path/to/vimfiles]
# If you have made changes in both directories, and want to keep the most
# recent versions, do
#   make sync [VIMFILES=path/to/vimfiles]
# Note:  defining VIMFILES when you invoke make overrides the value below.
# Warning:  install and stallin do not check modification times!

VIMFILES=${HOME}/.vim
EXCLUDE="--exclude='*~' --exclude='*.swp' --exclude='makefile'"

install:
	rsync -CrtW ${EXCLUDE}	. ${VIMFILES}

# stallin = reverse install
# If you can think of a better name for this target, be my guest!
stallin:
	rsync -CrtW --existing ${VIMFILES} .

sync:
	rsync -CrtuW ${EXCLUDE}	. ${VIMFILES}
	rsync -CrtuW --existing ${VIMFILES} .
