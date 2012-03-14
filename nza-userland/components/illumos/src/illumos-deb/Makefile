# Makefile

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

all: deb

test:
	@echo $(BASEGATE)

clean:
	-rm -f $(KSTEMP)/*.stamp
	-rm -f $(KDIRPKGS)/*.deb
	-rm -f $(KDIRPKGS)/*.changes
	-rm -f bldpkg_err.txt
	-rm -f ips2deb.failed.txt

clobber: clean
	-rm -f $(KPKGS)/*
	-rm -rf $(FDIR)

dirs: 
	mkdir -p $(DIRS)

gen: dirs
	@MANIFESTGATE="$(MANIFESTS)" \
	BASEGATE="$(PROTO)" \
	MAINTAINER="$(MAINTAINER)" \
	DESTINATION="$(DESTINATION)" \
	PKGVER="$(PVERSION)" \
	PKGTYPE="$(PKGTYPE)" \
	MFEXT="$(MFEXT)" \
	$(IPS2DEB) -d $(PROTO) \
		-d $(CODEMGR_WS)/usr/src/tools/proto/root_i386-nd
	touch $(FDIR)/.generated

deb: dirs $(PKGSTAMP)

$(FDIR)/.generated: gen
	@echo "Structure of directories have been generated"
	touch $(FDIR)/.generated

$(KSTEMP)/%.stamp: $(FDIR)/.generated
	@cd $(KDIRPKGS)/$*; \
	$(BLDPKG)
	@touch $@
