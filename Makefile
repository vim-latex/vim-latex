PREFIX=/usr/local
VIMDIR=$(PREFIX)/share/vim
BINDIR=$(PREFIX)/bin
APPDATADIR=$(PREFIX)/share/appdata

VERSION=1.9.0
DATE=$(shell date +%Y%m%d)
COMMIT_COUNT=$(shell git log --oneline | wc -l)
ABBREV_HASH=$(shell git rev-parse --short=7 HEAD)

SNAPSHOTNAME=vim-latex-$(VERSION)-$(DATE).$(COMMIT_COUNT)-git$(ABBREV_HASH)

snapshot:
	git archive --prefix '$(SNAPSHOTNAME)/' HEAD | gzip > '$(SNAPSHOTNAME).tar.gz'

install:
	install -d '$(DESTDIR)$(VIMDIR)/doc'
	install -m 0644 doc/*.txt '$(DESTDIR)$(VIMDIR)/doc'

	install -d '$(DESTDIR)$(VIMDIR)'
	cp -R compiler ftplugin indent plugin '$(DESTDIR)$(VIMDIR)'
	chmod 0755 '$(DESTDIR)$(VIMDIR)/ftplugin/latex-suite/outline.py'

	install -d '$(DESTDIR)$(BINDIR)'
	install latextags ltags '$(DESTDIR)$(BINDIR)'

	install -d '$(DESTDIR)$(APPDATADIR)'
	install vim-latex.metainfo.xml '$(DESTDIR)$(APPDATADIR)'

upload: snapshot
	scp '$(SNAPSHOTNAME).tar.gz' frs.sourceforge.net:/home/frs/project/v/vi/vim-latex/snapshots

.PHONY: install upload
