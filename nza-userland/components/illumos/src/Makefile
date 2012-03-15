NZA_KERNEL       = nza-kernel
NZA_CLOSED       = nza-closed
ILLUMOS_DEB      = illumos-deb
NZA_PATCHES      = nza-patches
SUNSTUDIO_PATH   = /opt/SUNWspro
SUN_GATE         = http://dlc.sun.com/osol/on/downloads/20100817
CLOSED_BINARY1   = on-closed-bins.i386.tar.bz2
CLOSED_BINARY2   = on-closed-bins-nd.i386.tar.bz2
JNUMBER         ?= -j6

NZA_ROOT         = $(CURDIR)
CODEMGR_WS       = $(NZA_ROOT)/$(NZA_KERNEL)
NZA_KERNEL_PATH ?= https://repos.nexenta.com/$(NZA_KERNEL)
NZA_CLOSED_PATH ?= https://repos.nexenta.com/$(NZA_CLOSED)
NZA_PATCH_DIR    = $(NZA_ROOT)/$(NZA_PATCHES)
ILLUMOS_DEB_PATH = $(NZA_ROOT)/$(ILLUMOS_DEB)
CUR_REV          = $(CODEMGR_WS)/.rev

define buildkernel
	REV=`cat $(CUR_REV)`; \
	cd $(CODEMGR_WS) && CODEMGR_WS='$(CODEMGR_WS)' GATE=$$REV ksh93 bldenv.sh -d illumos.sh -c 'cd usr/src && dmake setup' 1>&2; \
	cd $(CODEMGR_WS) && CODEMGR_WS='$(CODEMGR_WS)' GATE=$$REV ./nightly.sh illumos.sh
endef

define buildpackages
        cd $(CODEMGR_WS)/$(ILLUMOS_DEB) && PVERSION='$(PVERSION)' CODEMGR_WS='$(CODEMGR_WS)' gmake clobber; \
        cd $(CODEMGR_WS)/$(ILLUMOS_DEB) && PVERSION='$(PVERSION)' CODEMGR_WS='$(CODEMGR_WS)' gmake gen; \
        cd $(CODEMGR_WS)/$(ILLUMOS_DEB) && PVERSION='$(PVERSION)' CODEMGR_WS='$(CODEMGR_WS)' gmake $(JNUMBER) pkgs
endef

ifndef PVERSION
  $(warning *******************************************************************)
  $(warning *                    PVERSION is not set!                         *)
  $(warning * PVERSION is responsible for a version of Kernel deb packages.   *)
  $(warning *  For Nexenta 4.0 it should have a format 40-0-X (X:0,1,2,3,...) *)
  $(warning *   Target will not been completed correctly!   *)
  $(warning *******************************************************************)
endif

all:
	@echo "Please, select 'build-releasepackages' or 'build-debugpackages'!"

checktools:
	if test ! -d $(SUNSTUDIO_PATH)/bin ; then \
		echo "Sunstudio is not installed!"; \
		exit 1; \
	fi; \
	if test ! -d $(NZA_PATCH_DIR) ; then \
		echo "'$(NZA_PATCHES)' not found in '$(NZA_ROOT)'!"; \
		exit 1; \
	fi; \
	if test ! -d $(ILLUMOS_DEB_PATH) ; then \
		echo "'$(ILLUMOS_DEB)' not found in '$(NZA_ROOT)'!"; \
		exit 1; \
	fi
	touch $@

clonning: checktools
	if test ! -d $(CODEMGR_WS) ; then \
		hg clone $(NZA_KERNEL_PATH) $(CODEMGR_WS); \
	else \
		cd $(CODEMGR_WS); \
		hg pull -u; \
	fi
	if test ! -d $(CODEMGR_WS)/usr/$(NZA_CLOSED); then \
		hg clone $(NZA_CLOSED_PATH) $(CODEMGR_WS)/usr/$(NZA_CLOSED); \
	else \
		cd $(CODEMGR_WS)/usr/$(NZA_CLOSED); \
		hg pull -u; \
	fi
	cd $(CODEMGR_WS) && hg log -l1 --template '{node|short}' > $(CUR_REV)
	touch $@

setup-closed: clonning
	wget -c $(SUN_GATE)/$(CLOSED_BINARY1) --directory-prefix=$(CODEMGR_WS)
	wget -c $(SUN_GATE)/$(CLOSED_BINARY2) --directory-prefix=$(CODEMGR_WS)
	tar xvpf $(CODEMGR_WS)/$(CLOSED_BINARY1) -C $(CODEMGR_WS)
	tar xvpf $(CODEMGR_WS)/$(CLOSED_BINARY2) -C $(CODEMGR_WS)
	touch $@

patching: clonning
	mkdir -p $(CODEMGR_WS)/.hg/patches
	rm -f $(CODEMGR_WS)/.hg/patches/*
	ln -s $(NZA_PATCH_DIR)/* $(CODEMGR_WS)/.hg/patches
	echo '\n[ui] \nusername = mercurial' >> $(CODEMGR_WS)/.hg/hgrc
	echo '\n[extensions] \nmq =' >> $(CODEMGR_WS)/.hg/hgrc
	cd $(CODEMGR_WS) && hg qpush -a
	touch $@

hacking: clonning
	sed -i 's/^#define HAVE_CPP_UNDERBAR_FUNCTION_DEFINED 1/\/\*#define HAVE_CPP_UNDERBAR_FUNCTION_DEFINED 1\*\//' /usr/include/net-snmp/net-snmp-config.h
	touch $@

copy-tools: patching
	cp $(CODEMGR_WS)/usr/src/tools/env/illumos.sh $(CODEMGR_WS)
	ln -sf $(CODEMGR_WS)/usr/src/tools/scripts/bldenv.sh $(CODEMGR_WS)
	cp $(CODEMGR_WS)/usr/src/tools/scripts/nightly.sh $(CODEMGR_WS)
	chmod +x $(CODEMGR_WS)/nightly.sh
	cp -r $(ILLUMOS_DEB_PATH) $(CODEMGR_WS)
	touch $@

adjust-scripts: copy-tools
	sed -i 's/export GATE=.*//' $(CODEMGR_WS)/illumos.sh
	sed -i 's/export CODEMGR_WS=.*//' $(CODEMGR_WS)/illumos.sh
	sed -i 's/CODEMGR_WS =.*//' $(CODEMGR_WS)/$(ILLUMOS_DEB)/Makefile.conf
	sed -i 's/PVERSION =.*//' $(CODEMGR_WS)/$(ILLUMOS_DEB)/Makefile.conf
	touch $@

setrelease:
	sed -i "s/export NIGHTLY_OPTIONS='-FnCDlmprt'/export NIGHTLY_OPTIONS='-NndritM'/" $(CODEMGR_WS)/illumos.sh
	touch $@

setdebug:
	sed -i "s/export NIGHTLY_OPTIONS='-FnCDlmprt'/export NIGHTLY_OPTIONS='-FNnDdritM'/" $(CODEMGR_WS)/illumos.sh
	touch $@

build-releasekernel: adjust-scripts hacking setup-closed setrelease
	$(buildkernel)
	touch $@

build-debugkernel: adjust-scripts hacking setup-closed setdebug
	$(buildkernel)
	touch $@

build-releasepackages: build-releasekernel
	$(buildpackages)
	touch $@

build-debugpackages: build-debugkernel
	$(buildpackages)
	touch $@

.PHONY: all clean clean_patches help

clean:
	rm -f checktools clonning setup-closed patching hacking
	rm -f copy-tools adjust-scripts build-releasekernel build-debugkernel build-releasepackages build-debugpackages
	rm -rf $(CODEMGR_WS)

clean_patches:
	cd $(CODEMGR_WS) && hg qpop -a
	rm -f patching

help:
	@echo ""
	@echo "Usage: make [build-releasekernel|build-debugkernel|build-releasepackages|build-debugpackages|clean|clean_patches|help]"
	@echo ""
	@echo "PVERSION:"
	@echo "	   Version of Kernel deb packages. Must be set for 'build-releasepackages|build-debugpackages'"
	@echo "	   The format (for Nexenta 4.0) is: 40-0-X (X:0,1,2,3,...)."
	@echo ""
	@echo "NZA_KERNEL_PATH:"
	@echo "           Path to $(NZA_KERNEL) repo."
	@echo "	   It points to mercurial repo on default."
	@echo "	   However you can re-export this var to clone"
	@echo "	   $(NZA_KERNEL) from your locally shared place."
	@echo "NZA_CLOSED_PATH:"
	@echo "           Path to $(NZA_CLOSED) repo."
	@echo "	   It points to mercurial repo on default."
	@echo "	   However you can re-export this var to clone"
	@echo "	   $(NZA_CLOSED) from your locally shared place."
	@echo "JNUMBER:"
	@echo "           Number of processes to build"
	@echo "	   deb packages of Kernel. It is -j6 on default."
	@echo ""
