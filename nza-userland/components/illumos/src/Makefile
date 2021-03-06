# Copyright (c) 2014, Nexenta Systems, Inc. All rights reserved.

NZA_KERNEL       = nza-kernel
NZA_CLOSED       = nza-closed
SUNSTUDIO_PATH   = /opt/SUNWspro
SUN_GATE         = http://napalm.nexenta.com/internal/closed/latest
CLOSED_BINARY1   = on-closed-bins.i386.tar.bz2
CLOSED_BINARY2   = on-closed-bins-nd.i386.tar.bz2

export DEB_VERSION     ?= 40-0-0
export DEB_MAINTAINER  ?= Nexenta Systems <maintainer@nexenta.com>

NZA_ROOT         = $(CURDIR)
CODEMGR_WS       = $(NZA_ROOT)/$(NZA_KERNEL)
NZA_KERNEL_PATH ?= ssh://git@stash.nexenta.com:7999/os/nza-kernel.git
NZA_CLOSED_PATH ?= ssh://git@stash.nexenta.com:7999/os/nza-closed.git

# Override this, i.e. with stable-4.0
NZA_BRANCH_SPEC ?= master
NZA_CLOSED_BRANCH_SPEC ?= master
CUR_REV          = $(CODEMGR_WS)/.rev

VERSION   = NexentaOS_4:$(shell cat $(CUR_REV))
RELEASE_CM= \"@(\#)SunOS '\$$RELEASE' '\$$VERSION' '\$$RELEASE_DATE'\"
DEV_CM    = \"@(\#)SunOS Developer: '\$$LOGNAME' '\$$GATE' $(shell date +%Y-%m-%d)\"


DPKG_MAX_JOBS ?= 7

define buildkernel
	REV=`cat $(CUR_REV)`; \
	cd $(CODEMGR_WS) && CODEMGR_WS='$(CODEMGR_WS)' GATE=$$REV ksh93 bldenv.sh -d illumos.sh -c 'cd usr/src && dmake setup' 1>&2; \
	cd $(CODEMGR_WS) && CODEMGR_WS='$(CODEMGR_WS)' GATE=$$REV ./nightly.sh illumos.sh
	if grep -q "^*** Error" $(CODEMGR_WS)/usr/src/install-*i386.out; then \
		echo "Build not successfull, check nightly.log"; \
		exit 1; \
	fi;
endef

all:
	@echo "Please, select 'build-releasekernel' or 'build-debugkernel'!"

checktools:
	if test ! -d $(SUNSTUDIO_PATH)/bin ; then \
		echo "Sunstudio is not installed!"; \
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

hacking: clonning
	sed -i 's/^#define HAVE_CPP_UNDERBAR_FUNCTION_DEFINED 1/\/\*#define HAVE_CPP_UNDERBAR_FUNCTION_DEFINED 1\*\//' /usr/include/net-snmp/net-snmp-config.h
	touch $@

copy-tools:
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
	echo "export JAVA_ROOT='/usr/jdk/instances/openjdk1.7.0'" >> $(CODEMGR_WS)/illumos.sh
	touch $@

setrelease: adjust-scripts
	sed -i "s/^.*export NIGHTLY_OPTIONS.*/export NIGHTLY_OPTIONS='-nCmrt'/" $(CODEMGR_WS)/illumos.sh
	touch $@

setdebug: adjust-scripts
	sed -i "s/^.*export NIGHTLY_OPTIONS.*/export NIGHTLY_OPTIONS='-nFDCmrt'/" $(CODEMGR_WS)/illumos.sh
	touch $@

setss: adjust-scripts
	echo "export GCC_ROOT='/opt/gcc/4.4.4'" >> $(CODEMGR_WS)/illumos.sh
	touch $@

setgcc: adjust-scripts
	echo "export GCC_ROOT='/opt/gcc/4.4.4'" >> $(CODEMGR_WS)/illumos.sh
	echo "export CW_GCC_DIR='/opt/gcc/4.4.4/bin'" >> $(CODEMGR_WS)/illumos.sh
	echo "export CW_NO_SHADOW='1'" >> $(CODEMGR_WS)/illumos.sh
	echo "export __GNUC=''" >> $(CODEMGR_WS)/illumos.sh
	echo "export ONLY_LINT_DEFS='-I$(SUNSTUDIO_PATH)/sunstudio12.1/prod/include/lint'" >> $(CODEMGR_WS)/illumos.sh
	echo "export VERSION='$(VERSION)'" >> $(CODEMGR_WS)/illumos.sh
	echo "export RELEASE_CM='$(RELEASE_CM)'" >> $(CODEMGR_WS)/illumos.sh
	echo "export DEV_CM='$(DEV_CM)'" >> $(CODEMGR_WS)/illumos.sh
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

.SILENT: build-packages build-onepackage

build-packages:
	if test ! -d $(CODEMGR_WS)/proto; then \
		echo "Run \"make build-releasekernel-gcc or build-debugkernel-gcc\" first!"; \
		exit 1; \
	fi; \
	$(MAKE) -s -j$(DPKG_MAX_JOBS) -f Makefile.deb pkgallbuild
	touch $@

build-onepackage:
	if test ! -d $(CODEMGR_WS)/proto; then \
		echo "Run \"make build-releasekernel or build-debugkernel\" first!"; \
		exit 1; \
	fi; \
	$(MAKE) -s -f Makefile.deb onedeb DEB=$(DEB)

.PHONY: all clean help

clean:
	rm -f checktools clonning setup-closed hacking setrelease setdebug
	rm -f copy-tools adjust-scripts build-releasekernel build-debugkernel
	rm -f build-packages
	rm -f build-releasekernel-gcc build-debugkernel-gcc
	rm -f setss setgcc
	$(MAKE) -f Makefile.deb clean
	rm -rf $(CODEMGR_WS)

help:
	@echo ""
	@echo "Usage: gmake [ action ]
	@echo ""
	@echo "       actions:  build-releasekernel
	@echo "                 build-releasekernel-gcc
	@echo "                 build-debugkernel
	@echo "                 build-debugkernel-gcc
	@echo "                 build-packages
	@echo "                 build-onepackage DEB=PACKAGE_NAME
	@echo "                 clean
	@echo "                 help"
	@echo ""
	@echo "DEB_VERSION:"
	@echo "	   Version of Kernel deb packages. Must be set for 'build-packages'"
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
	@echo "DEB:"
	@echo "           Name of package, i.e. \"gmake build-onepackage DEB=system-tnf\""
	@echo ""
