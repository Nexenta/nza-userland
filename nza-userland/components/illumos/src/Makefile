NZA_KERNEL       = nza-kernel
NZA_CLOSED       = nza-closed
NZA_PATCHES      = nza-patches
SUNSTUDIO_PATH   = /opt/SUNWspro
SUN_GATE         = http://dlc.sun.com/osol/on/downloads/20100817
CLOSED_BINARY1   = on-closed-bins.i386.tar.bz2
CLOSED_BINARY2   = on-closed-bins-nd.i386.tar.bz2
DEB_VERSION     ?= 40-0-21
DEB_MAINTAINER  ?= Nexenta Systems <maintainer@nexenta.com>
NZA_KERNEL_REV  ?= default
NZA_CLOSED_REV  ?= default

NZA_ROOT         = $(CURDIR)
CODEMGR_WS       = $(NZA_ROOT)/$(NZA_KERNEL)
NZA_KERNEL_PATH ?= https://repos.nexenta.com/$(NZA_KERNEL)
NZA_CLOSED_PATH ?= https://repos.nexenta.com/$(NZA_CLOSED)
NZA_PATCH_DIR    = $(NZA_ROOT)/$(NZA_PATCHES)
CUR_REV          = $(CODEMGR_WS)/.rev

define buildkernel
	REV=`cat $(CUR_REV)`; \
	cd $(CODEMGR_WS) && CODEMGR_WS='$(CODEMGR_WS)' GATE=$$REV ksh93 bldenv.sh -d illumos.sh -c 'cd usr/src && dmake setup' 1>&2; \
	cd $(CODEMGR_WS) && CODEMGR_WS='$(CODEMGR_WS)' GATE=$$REV ./nightly.sh illumos.sh
endef

define buildpackages
	REV=`cat $(CUR_REV)`; \
	cd $(CODEMGR_WS) && CODEMGR_WS='$(CODEMGR_WS)' GATE=$$REV ksh93 bldenv.sh -d illumos.sh -c 'cd usr/src/pkg && dmake deb'; \
	cd $(CODEMGR_WS) && CODEMGR_WS='$(CODEMGR_WS)' GATE=$$REV ksh93 bldenv.sh -d illumos.sh -c 'cd usr/src/pkg && dmake debapt'
endef

ifndef DEB_VERSION
  $(warning *******************************************************************)
  $(warning *                    DEB_VERSION is not set!                         *)
  $(warning * DEB_VERSION is responsible for a version of Kernel deb packages.   *)
  $(warning *  For Nexenta 4.0 it should have a format 40-0-X (X:0,1,2,3,...) *)
  $(warning *   DEB_VERSION is 40-0-0 on default!   *)
  $(warning *******************************************************************)
endif

all:
	@echo "Please, select 'build-releasekernel' or 'build-debugkernel'!"

checktools:
	if test ! -d $(SUNSTUDIO_PATH)/bin ; then \
		echo "Sunstudio is not installed!"; \
		exit 1; \
	fi; \
	if test ! -d $(NZA_PATCH_DIR) ; then \
		echo "'$(NZA_PATCHES)' not found in '$(NZA_ROOT)'!"; \
		exit 1; \
	fi; \
	touch $@

clonning: checktools
	if test ! -d $(CODEMGR_WS) ; then \
		hg clone $(NZA_KERNEL_PATH) $(CODEMGR_WS); \
		cd $(CODEMGR_WS); \
		hg up $(NZA_KERNEL_REV) -C; \
	else \
		cd $(CODEMGR_WS); \
		hg pull -u; \
		hg up $(NZA_KERNEL_REV) -C; \
	fi
	if test ! -d $(CODEMGR_WS)/usr/$(NZA_CLOSED); then \
		hg clone $(NZA_CLOSED_PATH) $(CODEMGR_WS)/usr/$(NZA_CLOSED); \
		cd $(CODEMGR_WS)/usr/$(NZA_CLOSED); \
		hg up $(NZA_CLOSED_REV) -C; \
	else \
		cd $(CODEMGR_WS)/usr/$(NZA_CLOSED); \
		hg pull -u; \
		hg up $(NZA_CLOSED_REV) -C; \
	fi
	cd $(CODEMGR_WS) && hg id -i > $(CUR_REV)
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
	touch $@

adjust-scripts: copy-tools
	sed -i 's/export GATE=.*//' $(CODEMGR_WS)/illumos.sh
	sed -i 's/export CODEMGR_WS=.*//' $(CODEMGR_WS)/illumos.sh
	echo "export PKGS_TYPE='deb'" >> $(CODEMGR_WS)/illumos.sh
	echo "export DEB_VERSION='$(DEB_VERSION)'" >> $(CODEMGR_WS)/illumos.sh
	echo "export DEB_MAINTAINER='$(DEB_MAINTAINER)'" >> $(CODEMGR_WS)/illumos.sh
	echo "export DPKG_BUILD_FLAGS='-b -d -uc'" >> $(CODEMGR_WS)/illumos.sh
	echo "export PKGARCHIVEAPT='${CODEMGR_WS}/packages/${MACH}/apt'" >> $(CODEMGR_WS)/illumos.sh
	touch $@

setrelease: adjust-scripts
	sed -i "s/export NIGHTLY_OPTIONS='-FnCDlmprt'/export NIGHTLY_OPTIONS='-nCmprt'/" $(CODEMGR_WS)/illumos.sh
	touch $@

setdebug: adjust-scripts
	sed -i "s/export NIGHTLY_OPTIONS='-FnCDlmprt'/export NIGHTLY_OPTIONS='-nFDCmprt'/" $(CODEMGR_WS)/illumos.sh
	touch $@

setss: adjust-scripts
	echo "export GCC_ROOT='/usr'" >> $(CODEMGR_WS)/illumos.sh
	touch $@

setgcc: adjust-scripts
	echo "export GCC_ROOT='/usr/gcc/4.4'" >> $(CODEMGR_WS)/illumos.sh
	echo "export CW_GCC_DIR='/usr/gcc/4.4/bin'" >> $(CODEMGR_WS)/illumos.sh
	echo "export __GNUC=''" >> $(CODEMGR_WS)/illumos.sh
	echo "export __GNUC4=''" >> $(CODEMGR_WS)/illumos.sh
	touch $@

build-releasekernel: hacking setup-closed setrelease setss
	$(buildkernel)
	touch $@

build-releasekernel-gcc: hacking setup-closed setrelease setgcc
	$(buildkernel)
	touch $@

build-debugkernel: hacking setup-closed setdebug setss
	$(buildkernel)
	touch $@

build-debugkernel-gcc: hacking setup-closed setdebug setgcc
	$(buildkernel)
	touch $@

build-releasepackages:
	if test ! -d $(CODEMGR_WS)/proto; then \
		echo "Run \"make build-releasekernel or build-releasekernel-gcc\" first!"; \
		exit 1; \
	fi; \
	$(buildpackages)
	touch $@

build-debugpackages:
	if test ! -d $(CODEMGR_WS)/proto; then \
		echo "Run \"make build-debugkernel or build-debugkernel-gcc\" first!"; \
		exit 1; \
	fi; \
	$(buildpackages)
	touch $@


.PHONY: all clean clean_patches help

clean:
	rm -f checktools clonning setup-closed patching hacking setrelease setdebug
	rm -f copy-tools adjust-scripts build-releasekernel build-debugkernel
	rm -f build-releasepackages build-debugpackages
	rm -f build-releasekernel-gcc build-debugkernel-gcc
	rm -f setss setgcc
	rm -rf $(CODEMGR_WS)

clean_patches:
	cd $(CODEMGR_WS) && hg qpop -a
	rm -f patching

help:
	@echo ""
	@echo "Usage: make [build-releasekernel|build-releasekernel-gcc|build-debugkernel|build-debugkernel-gcc|build-releasepackages|build-debugpackages|clean|clean_patches|help]"
	@echo ""
	@echo "DEB_VERSION:"
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
	@echo "NZA_KERNEL_REV:"
	@echo "           Revision for $(NZA_KERNEL)"
	@echo "           Is 'tip' on default. Change it if you need to build another revision of nza_kernel"
	@echo "NZA_CLOSED_REV:"
	@echo "           Revision for $(NZA_CLOSED)"
	@echo "           Is 'tip' on default. Change it if you need to use another revision of nza_closed"
	@echo "DEB_MAINTAINER:"
	@echo "           Crafter of packages"
	@echo "	   It is \"Nexenta Systems <maintainer@nexenta.com>\" on default."
	@echo ""
