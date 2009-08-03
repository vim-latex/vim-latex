PREFIX = /usr/local
VIMDIR = $(PREFIX)/share/vim
BINDIR = $(PREFIX)/bin

VERSION=1.5
REVISION=$(shell svn info 2>/dev/null| head -n 5 | tail -n 1 | cut -d" " -f2)
DATE = $(shell date +%Y%m%d)

SNAPSHOTNAME = vim-latex-$(VERSION)-$(DATE)-r$(REVISION)

snapshot:
	rm -rf -- ./$(SNAPSHOTNAME)
	svn export . $(SNAPSHOTNAME)
	make -C $(SNAPSHOTNAME)/doc
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
