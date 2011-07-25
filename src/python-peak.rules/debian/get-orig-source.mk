# debian/rules snippet for creating multi-upstream tarball relying on
# several debian/*.watch files

# XXX: adapted to use as version number those returned by the "main"
# debian/watch

# Copyright © 2009 Stefano Zacchiroli <zack@debian.org>
# License: GNU GPL version 3 or above
# Created: Sat, 30 May 2009 11:58:16 +0200
# Last-Modified: Sat, 20 Jun 2009 12:59:10 +0200

# TODO: does not yet fully implement policy wrt get-orig-source:
#       - the target cannot be invoked from any dir (rely on "debian/")
#       - tmpdir handling is not fully safe (e.g., no "mktemp -d")

GOSTMP = get-orig-source.tmp
ORIGVERSION := $(shell uscan --report --dehs | grep '<upstream-version>' | sed 's/<[^>]\+>//g')
ORIGNAME = $(PKG)-$(ORIGVERSION)
ORIGTARBALL = $(PKG)_$(ORIGVERSION).orig.tar.gz

get-orig-source: $(patsubst %,%/get-orig-source,$(UPSTREAMS))
	cd $(GOSTMP) && \
	mkdir $(ORIGNAME) && \
	for p in $(UPSTREAMS) ; do \
		mv `readlink $$p` $(ORIGNAME) ; \
		mv $$p $(ORIGNAME) ; \
	done && \
	tar cvzf $(ORIGTARBALL) $(ORIGNAME) && \
	mv $(ORIGTARBALL) ../ && \
	cd .. && \
	rm -rf $(GOSTMP)/
$(GOSTMP):
	-mkdir $@
%/get-orig-source: $(GOSTMP)
	uscan --watchfile debian/$*.watch \
		--upstream-version 0 --package $* \
		--download --destdir $(GOSTMP)/
	cd $(GOSTMP) && \
	tar xzf $**.orig.tar.gz && \
	ln -s `tar tzf $**.orig.tar.gz | head -n1` $*
