#!/usr/bin/make -f
# debian/rules for hplip
# GNU copyright 1997 to 1999 by Joey Hess.
# Copyright (c) 2003 Torsten Landschoff <torsten@debian.org>
# Copyright (c) 2004 Henrique de Moraes Holschuh <hmh@debian.org>

PACKAGE=hplip

# DPatch
DEB_SOURCE_PACKAGE:=$(PACKAGE)
include /usr/share/dpatch/dpatch.make

# DebHelper control
export DH_ALWAYS_EXCLUDE=CVS:.cvsignore
#export DH_VERBOSE=1

PKGTMP :=$(CURDIR)/debian/tmp
HPLIP_VERSION?=$(shell dpkg-parsechangelog | grep -E "^Version:" | \
	tr -d ' \t' | cut -d ':' -f 2-)
HPIJS_VERSION?=$(shell grep -E '[(][[:blank:]]*hpijs[[:blank:]]*,[[:blank:]]*[^[:blank:]]+[[:blank:]]*[)]' \
	prnt/hpijs/configure.in | tr -d ' \t()' | cut -d ',' -f 2)
HPIJS_PKG_VERSION:="$(HPIJS_VERSION)+$(HPLIP_VERSION)"
ifeq	(,$(HPLIP_VERSION))
	$(error Could not get debian package version from debian/changelog)
endif
ifeq	(,$(HPIJS_VERSION))
	$(error Could not get HPIJS upstream version from prnt/hpijs/Makefile)
endif

export DEB_HOST_GNU_TYPE  ?= $(shell dpkg-architecture -qDEB_HOST_GNU_TYPE)
export DEB_BUILD_GNU_TYPE ?= $(shell dpkg-architecture -qDEB_BUILD_GNU_TYPE)

# FOR AUTOCONF 2.52 AND NEWER ONLY
CONFFLAGS =
ifeq ($(DEB_BUILD_GNU_TYPE), $(DEB_HOST_GNU_TYPE))
  CONFFLAGS += --build $(DEB_HOST_GNU_TYPE)
else
  CONFFLAGS += --build $(DEB_BUILD_GNU_TYPE) --host $(DEB_HOST_GNU_TYPE)
endif

DEBUGFLAGS=-g
ifneq (,$(findstring noopt,$(DEB_BUILD_OPTIONS)))
	DEBUGFLAGS += -O0
else
	DEBUGFLAGS += -O2
endif

CFLAGS:=-Wall -pipe $(DEBUGFLAGS)
CXXFLAGS:=$(CFLAGS)

configure:
	chmod +x debian/autogen.sh
	debian/autogen.sh

configure-stamp: patch-stamp configure
	dh_testdir

	ln -sf /usr/share/misc/config.sub .
	ln -sf /usr/share/misc/config.guess .
	rm -f config.cache

	./configure CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" \
		$(CONFFLAGS) \
	 	--config-cache \
		--disable-dependency-tracking \
		--enable-rpm-install \
		--prefix=/usr \
		--mandir=\$${prefix}/share/man \
		--infodir=\$${prefix}/share/info \
		--datadir=\$${prefix}/share \
		--libexecdir=\$${prefix}/lib \
		--sysconfdir=/etc \
		--enable-debug \
		--disable-foomatic-install \
		--disable-cups-install \
		--enable-network-install

	touch configure-stamp

build: build-stamp
build-stamp: configure-stamp
	dh_testdir

	$(MAKE)

	touch build-stamp

# Clean everything up, including everything auto-generated
# at build time that needs not to be kept around in the Debian diff
clean: clean-patched unpatch

clean-patched: configure
	dh_testdir
	dh_testroot
	rm -f build-stamp configure-stamp

	-$(MAKE) clean
	-$(MAKE) distclean
	find -type d -name autom4te.cache -print0 | xargs -0 -r rm -rf \;
	-rm -f platform.h auto-include.h
	find -type d -name build -print0 | xargs -0 -r rm -rf \;
	find \( -name config.sub -o -name config.guess \) -print0 | xargs -0 -r rm -f \;

	# Fix permissions
	if [ -r debian/executable.files ] ; then \
		find -type d -print0 | xargs -0 -r chmod 755 ;\
		find -type f ! -name 'rules' -print0 | xargs -0 -r chmod 644 ;\
		xargs -t -r chmod +x < debian/executable.files ;\
	fi

	# Final static cleanups
	if [ -r debian/deletable.files ] ; then \
		xargs -t -r rm -f < debian/deletable.files ;\
	fi

	dh_clean

install: build
	dh_testdir
	dh_testroot
	dh_clean -k
	dh_installdirs

	$(MAKE) install DESTDIR=$(PKGTMP)	\
		docdir=/usr/share/doc

	rm -f $(PKGTMP)/usr/share/hplip/data/hplip

	find $(PKGTMP)/usr/lib/hplip -type d -maxdepth 1 -mindepth 1 -print0 | \
		xargs -0 -r -i@ find @ -type f -name '*.py' -exec chmod a-x {} \;

	mkdir -p $(PKGTMP)/usr/share/pixmaps
	install -m 644 debian/hp-logo.xpm $(PKGTMP)/usr/share/pixmaps
	mkdir -p $(PKGTMP)/usr/share/applications
	install -m 644 debian/*.desktop $(PKGTMP)/usr/share/applications

	mkdir -p $(PKGTMP)/etc/sane.d/dll.d
	install -m 644 debian/hplip.sane $(PKGTMP)/etc/sane.d/dll.d/hplip

	# Lintian and linda overrides
	cd debian ; \
	for i in *.linda ; do \
	    [ -r "$$i" ] && { \
		mkdir -p "$${i%%.linda}/usr/share/linda/overrides" ;\
		install  -m 644 "$$i" "$${i%%.linda}/usr/share/linda/overrides/$${i%%.linda}" ;\
	    } ;\
	done ;\
	for i in *.lintian ; do \
	    [ -r "$$i" ] && { \
		mkdir -p "$${i%%.lintian}/usr/share/lintian/overrides" ;\
		install  -m 644 "$$i" "$${i%%.lintian}/usr/share/lintian/overrides/$${i%%.lintian}" ;\
	    } ;\
	done

	dh_install --sourcedir=$(PKGTMP)


# Build architecture-independent packages
binary-indep: build install
	dh_testdir -i
	dh_testroot
#	dh_installdebconf -i
#	dh_installdocs -i -Nhplip-data
#	dh_installexamples -i -Nhplip-data
#	dh_installmenu -i
#	dh_installlogrotate -i
#	dh_installemacsen -i
#	dh_installpam -i
#	dh_installmime -i
#	dh_installinit -i
#	dh_installcron -i
#	dh_installman -i
#	dh_installinfo -i
#	dh_installchangelogs -i ChangeLog -Nhplip-data
	dh_link -i
	dh_strip -i
	dh_compress -i
	dh_fixperms -i
#	dh_perl -i
#	dh_python -i
#	dh_makeshlibs -i
	dh_installdeb -i
	dh_shlibdeps -i
	dh_gencontrol -i
	dh_md5sums -i
	dh_builddeb -i

# Build architecture-dependent packages
binary-arch: build install
	dh_testdir -a
	dh_testroot
#	dh_installdebconf -a
	dh_installdocs -a
	dh_installexamples -a
	dh_installmenu -a
	dh_desktop -a
#	dh_installlogrotate -a
#	dh_installemacsen -a
#	dh_installpam -a
#	dh_installmime -a
	dh_installinit -phplip -- defaults 19
#	dh_installcron -a
	dh_installman -a
#	dh_installinfo -a
	dh_installchangelogs -a ChangeLog
	dh_python -a
#	dh_perl -a
	dh_link -a
	dh_strip -a
	dh_compress -a
	dh_fixperms -a
#	dh_makeshlibs -a
	dh_installdeb -a
	dh_shlibdeps -a
	dh_gencontrol -phpijs -- -v$(HPIJS_PKG_VERSION)
	dh_gencontrol -a -Nhpijs
	dh_md5sums -a
	dh_builddeb -a

binary: binary-indep binary-arch
.PHONY: build clean clean-patched binary-indep binary-arch binary install
