NZA_KERNEL       = nza-kernel
NZA_CLOSED       = nza-closed
NZA_PATCHES      = nza-patches
SUNSTUDIO_PATH   = /opt/SUNWspro
SUN_GATE         = http://dlc.sun.com/osol/on/downloads/20100817
CLOSED_BINARY1   = on-closed-bins.i386.tar.bz2
CLOSED_BINARY2   = on-closed-bins-nd.i386.tar.bz2

export DEB_VERSION     ?= 40-0-21
export DEB_MAINTAINER  ?= Nexenta Systems <maintainer@nexenta.com>

NZA_ROOT         = $(CURDIR)
CODEMGR_WS       = $(NZA_ROOT)/$(NZA_KERNEL)
NZA_KERNEL_PATH ?= ssh://git@stash.nexenta.com:7999/os/nza-kernel.git
NZA_CLOSED_PATH ?= ssh://git@stash.nexenta.com:7999/os/nza-closed.git

# Override this, i.e. with stable-4.0
NZA_BRANCH_SPEC ?= master
NZA_CLOSED_BRANCH_SPEC ?= master
NZA_PATCH_DIR    = $(NZA_ROOT)/$(NZA_PATCHES)
CUR_REV          = $(CODEMGR_WS)/.rev

define buildkernel
	REV=`cat $(CUR_REV)`; \
	cd $(CODEMGR_WS) && CODEMGR_WS='$(CODEMGR_WS)' GATE=$$REV ksh93 bldenv.sh -d illumos.sh -c 'cd usr/src && dmake setup' 1>&2; \
	cd $(CODEMGR_WS) && CODEMGR_WS='$(CODEMGR_WS)' GATE=$$REV ./nightly.sh illumos.sh
endef

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
		git clone $(NZA_KERNEL_PATH) $(CODEMGR_WS); \
	fi
	cd $(CODEMGR_WS) && ( \
		git checkout -f $(NZA_BRANCH_SPEC); \
	)
	if test ! -d $(CODEMGR_WS)/usr/$(NZA_CLOSED); then \
		git clone $(NZA_CLOSED_PATH) $(CODEMGR_WS)/usr/$(NZA_CLOSED); \
	fi
	cd $(CODEMGR_WS)/usr/$(NZA_CLOSED) && ( \
		git checkout -f $(NZA_CLOSED_BRANCH_SPEC); \
	)
	cd $(CODEMGR_WS) && git rev-parse --short=10 HEAD > $(CUR_REV)
	touch $@

setup-closed: clonning
	wget -c $(SUN_GATE)/$(CLOSED_BINARY1) --directory-prefix=$(CODEMGR_WS)
	wget -c $(SUN_GATE)/$(CLOSED_BINARY2) --directory-prefix=$(CODEMGR_WS)
	tar xvpf $(CODEMGR_WS)/$(CLOSED_BINARY1) -C $(CODEMGR_WS)
	tar xvpf $(CODEMGR_WS)/$(CLOSED_BINARY2) -C $(CODEMGR_WS)
	touch $@

patching: clonning
	cd $(CODEMGR_WS) && \
	for p in $(shell cat $(NZA_PATCH_DIR)/series); \
	do \
		patch -N -p1 < $(NZA_PATCH_DIR)/$$p; \
	done
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
	sed -i "s/export NIGHTLY_OPTIONS='-FnCDlmprt'/export NIGHTLY_OPTIONS='-nCmrt'/" $(CODEMGR_WS)/illumos.sh
	touch $@

setdebug: adjust-scripts
	sed -i "s/export NIGHTLY_OPTIONS='-FnCDlmprt'/export NIGHTLY_OPTIONS='-nFDCmrt'/" $(CODEMGR_WS)/illumos.sh
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
	$(MAKE) -f Makefile.deb apt
	touch $@

build-debugpackages:
	if test ! -d $(CODEMGR_WS)/proto; then \
		echo "Run \"make build-debugkernel or build-debugkernel-gcc\" first!"; \
		exit 1; \
	fi; \
	$(MAKE) -f Makefile.deb apt
	touch $@


.PHONY: all clean clean_patches help

clean:
	rm -f checktools clonning setup-closed patching hacking setrelease setdebug
	rm -f copy-tools adjust-scripts build-releasekernel build-debugkernel
	rm -f build-releasepackages build-debugpackages
	rm -f build-releasekernel-gcc build-debugkernel-gcc
	rm -f setss setgcc
	$(MAKE) -f Makefile.deb clean
	rm -rf $(CODEMGR_WS)

clean_patches:
	cd $(CODEMGR_WS) && \
	for p in $(shell /usr/bin/rev -l $(NZA_PATCH_DIR)/series); \
	do \
	patch -N -p1 -R < $(NZA_PATCH_DIR)/$$p; \
	done
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
	@echo "	   It points to mercurial repo by default."
	@echo "	   However you can re-export this var to clone"
	@echo "	   $(NZA_KERNEL) from your locally shared place."
	@echo "NZA_CLOSED_PATH:"
	@echo "           Path to $(NZA_CLOSED) repo."
	@echo "	   It points to mercurial repo by default."
	@echo "	   However you can re-export this var to clone"
	@echo "	   $(NZA_CLOSED) from your locally shared place."
	@echo "NZA_BRANCH_SPEC:"
	@echo "           Branch/Tag/Revision for $(NZA_KERNEL)"
	@echo "           Is 'master' by default. Change it if you need to build another branch/tag/revision of nza_kernel"
	@echo "NZA_CLOSED_BRANCH_SPEC:"
	@echo "           Branch/Tag/Revision for $(NZA_CLOSED)"
	@echo "           Is 'master' by default. Change it if you need to use another branch/tag/revision of nza_closed"
	@echo "DEB_MAINTAINER:"
	@echo "           Crafter of packages"
	@echo "	   It is \"Nexenta Systems <maintainer@nexenta.com>\" by default."
	@echo ""
