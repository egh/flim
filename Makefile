#
# Makefile for FLIM.
#

PACKAGE = flim
VERSION = 1.11.0

TAR	= tar
RM	= /bin/rm -f
CP	= /bin/cp -p

EMACS	= emacs
XEMACS	= xemacs
FLAGS   = -batch -q -no-site-file -eval "$${EVALARGS:-nil}"
FLAGS_CURDIR   = $(FLAGS) -eval '(setq load-path (cons "." load-path))'

PREFIX = NONE
LISPDIR = NONE
PACKAGEDIR = NONE
VERSION_SPECIFIC_LISPDIR = NONE

GOMI	= *.elc \
	  *.cp *.cps *.ky *.kys *.fn *.fns *.vr *.vrs \
	  *.pg *.pgs *.tp *.tps *.toc *.aux *.log
FILES	= README.?? Makefile FLIM-MK FLIM-CFG FLIM-ELS *.el ChangeLog


elc: ew-parse.el
	$(EMACS) $(FLAGS) -l FLIM-MK -f compile-flim $(PREFIX) $(LISPDIR) \
		$(VERSION_SPECIFIC_LISPDIR)

install:	elc
	$(EMACS) $(FLAGS) -l FLIM-MK -f install-flim $(PREFIX) $(LISPDIR) \
		$(VERSION_SPECIFIC_LISPDIR)


package:
	$(XEMACS) $(FLAGS) -f compile-flim-package $(PACKAGEDIR)

install-package:	package
	$(XEMACS) $(FLAGS) -f install-flim-package $(PACKAGEDIR)

clean:
	-$(RM) $(GOMI)


tar:
	cvs commit
	sh -c 'cvs tag -RF $(PACKAGE)-`echo $(VERSION) \
				| sed s/\\\\./_/ | sed s/\\\\./_/`; \
	cd /tmp; \
	cvs -d :pserver:anonymous@chamonix.jaist.ac.jp:/hare/cvs/root \
		export -d $(PACKAGE)-$(VERSION) \
		-r $(PACKAGE)-`echo $(VERSION) | sed s/\\\\./_/ | sed s/\\\\./_/` \
		flim'
	cd /tmp; $(RM) $(PACKAGE)-$(VERSION)/ftp.in ; \
		$(TAR) cvzf $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION)
	cd /tmp; $(RM) -r $(PACKAGE)-$(VERSION)
	sed "s/VERSION/$(VERSION)/" < ftp.in > ftp

release:
	-$(RM) /pub/GNU/elisp/flim/$(PACKAGE)-$(VERSION).tar.gz
	mv /tmp/$(PACKAGE)-$(VERSION).tar.gz /pub/GNU/elisp/flim/
	cd /pub/GNU/elisp/semi/ ; \
		ln -s ../flim/$(PACKAGE)-$(VERSION).tar.gz .

ew-parse.el: ew-parse.scm lalr-el.scm
	-scm -f lalr-el.scm -f ew-parse.scm > ew-parse.out

check:
	$(EMACS) $(FLAGS_CURDIR) -l ./TESTPAT -eval '(report)'

# The file BENCHMARK is not a part of FLAM-DOODLE because it is so large.
benchmark:
	$(EMACS) $(FLAGS_CURDIR) -l ./BENCHMARK -eval '(report)'

