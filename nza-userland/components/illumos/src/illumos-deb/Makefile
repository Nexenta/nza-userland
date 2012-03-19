# Makefile
#
# Copyright (c) 2012, Nexenta Systems, Inc. All rights reserved.

FIND = /usr/gnu/bin/find

CWD = $(shell pwd)

include $(CWD)/Makefile.conf

HOSTARCH = solaris-i386
IPS2DEB = $(CWD)/ips2deb.pl
BLDPKG = $(CWD)/bldpkg.sh $(PROTO) $(KPKGS)

FDIR = $(CWD)/debs

KSTEMP = $(FDIR)/stemps
KPKGS = $(FDIR)/pkgs
KDIRPKGS = $(FDIR)/pkgsdir

#----------------------------------------------------------------------------
BASEGATEPATH = $(PROTO)
DESTINATION = $(KDIRPKGS)

DIRS = $(KSTEMP) $(KPKGS) $(KDIRPKGS)

PKGSALL = $(shell $(FIND) $(KDIRPKGS)/ -maxdepth 1 -type d -name "*")
PKGS = $(PKGSALL:$(KDIRPKGS)/%=%)

PKGSTAMP = $(PKGS:%=$(KSTEMP)/%.stamp)

all: pkgs

test:
	@echo $(BASEGATE)

clean:
	-rm -f $(KSTEMP)/*.stamp
	-rm -f $(KDIRPKGS)/*.deb
	-rm -f $(KDIRPKGS)/*.changes
	-rm -f bldpkg_err.txt

clobber: clean
	rm -f $(KPKGS)/*
	rm -rf $(FDIR)

dirs: 
	mkdir -p $(DIRS)

gen: dirs
	$(IPS2DEB) --verbose \
	--mfg "$(MANIFESTS)" \
	--mfe "$(MFEXT)" \
	-d "$(PROTO)" \
	-d "$(CODEMGR_WS)/usr/src/tools/proto/root_i386-nd" \
	-o "$(DESTINATION)" \
	--maintainer "$(MAINTAINER)" \
	--pv "$(PVERSION)" \
	--category "$(PKGTYPE)"

pkgs: $(PKGSTAMP)

$(KSTEMP)/%.stamp:
	@cd $(KDIRPKGS)/$*; \
	$(BLDPKG)
	@touch $@
