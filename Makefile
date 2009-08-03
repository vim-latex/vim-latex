PREFIX = /usr
VIMDIR = $(PREFIX)/share/vim
BINDIR = $(PREFIX)/bin

VERSION=1.5

DATE = $(shell date +%Y%m%d)
SNAPSHOTNAME = vim-latex-$(VERSION)-$(DATE)

snapshot:
	rm -rf -- ./$(SNAPSHOTNAME)
	svn export . $(SNAPSHOTNAME)
	tar cvzf ./$(SNAPSHOTNAME).tar.gz ./$(SNAPSHOTNAME)
	rm -rf -- ./$(SNAPSHOTNAME)

install:
	install -d "$(DESTDIR)$(VIMDIR)/doc"
	install -m 0644 doc/*.txt "$(DESTDIR)$(VIMDIR)/doc"

	install -d "$(DESTDIR)$(VIMDIR)"
	cp -R compiler ftplugin indent plugin "$(DESTDIR)$(VIMDIR)"
	chmod 0755 "$(DESTDIR)$(VIMDIR)/ftplugin/latex-suite/outline.py"

	install -d "$(DESTDIR)$(BINDIR)"
	install latextags ltags "$(DESTDIR)$(BINDIR)"
