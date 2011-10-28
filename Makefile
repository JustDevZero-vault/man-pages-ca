# Do "make screen" first, if you want to protect already installed,
# more up-to-date manual pages than the ones included in this package.
# Do "make install" to copy the pages to their destination.
# Do "make gz" or "make bz2" first if you use compressed source pages.

MANDIR=$(prefix)/usr/share/man/ca

GZIP=gzip -9
BZIP2=bzip2 -9

all: screen remove install

allgz: gz all

allbz: bz2 all

# Unfortunately, due to BSD brain damage codified by POSIX,
# code like "for i in dir/*; do STH; done" does not loop over
# all files in dir - indeed, when dir is empty it does STH
# once instead of zero times. David Balazic found that he
# lost his files and noticed the cause.
# [If we knew for sure this was using bash, we could set
#  allow_null_glob_expansion.]

screen:
	-mkdir not_installed
	files=man?/*; \
	if [ "$$files" != "man\?/\*" ]; then for i in $$files; do \
		if [ $(MANDIR)/$$i -nt $$i ]; then \
			diff -q $(MANDIR)/$$i $$i > /dev/null 2>&1; \
			if [ $$? != 0 ]; then mv $$i not_installed; fi; \
		fi; \
	done; fi

remove:
	files=man?/*; \
	if [ "$$files" != "man\?/\*" ]; then for i in $$files; do \
		rm -f $(MANDIR)/$$i $(MANDIR)/$$i.gz $(MANDIR)/$$i.bz2; \
	done; fi

gz:
	for i in man?; do $(GZIP) $$i/*; done

bz2:
	for i in man?; do $(BZIP2) $$i/*; done

gz2plain:
	for i in man?; do gunzip $$i/*; done

bz2plain:
	for i in man?; do bunzip2 $$i/*; done

# Use with
#  make HTDIR=/some/dir HTOPTS=whatever html
# The sed removes the lines "Content-type: text/html\n\n"
html:
	@if [ x$(HTDIR) = x ]; then echo "You must set HTDIR."; else \
	for i in man?; do \
		[ -d $(HTDIR)/$$i ] || mkdir -p $(HTDIR)/$$i; \
		find "$$i/" -type f | while read f; do \
			(cd $$i; man2html $(HTOPTS) `basename $$f`) | \
			sed -e '1,2d' > $(HTDIR)/$$i/`basename $$f`.html; \
		done; \
	done; fi

README=$(MANDIR)/man1/README
install:
	for i in man?; do \
		install -d -m 755 $(MANDIR)/$$i; \
		install -m 644 $$i/* $(MANDIR)/$$i; \
	done; \
	rm -f $(README) $(README).gz $(README).bz2

uninstall:
	for i in man?/*; do \
		rm -i $(MANDIR)/$$i; \
	done;

# someone might also want to look at /var/catman/cat2 or so ...
# a problem is that the location of cat pages varies a lot
