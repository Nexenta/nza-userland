# Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved.


include ../../../make-rules/shared-macros.mk

COMPILER = studio

PATH=$(SPRO_VROOT)/bin:/usr/bin:/usr/gnu/bin:/usr/perl5/bin
DEBVERSION = 40-0-8
COMPONENT_NAME =	openssl
COMPONENT_VERSION =	0.9.8y
IPS_COMPONENT_VERSION = 0.9.8.25
COMPONENT_SRC =		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE =	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:32ec994d626555774548c82e48c5d220bec903c4
COMPONENT_ARCHIVE_URL =	http://www.openssl.org/source/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/lint-libraries.mk

PATH=$(SPRO_VROOT)/bin:/usr/bin:/usr/gnu/bin:/usr/perl5/bin

# OpenSSL does not use autoconf but its own configure system.
CONFIGURE_SCRIPT = $(SOURCE_DIR)/Configure

# This is to force OpenSSL's Configure script to use gmake for 'make links'..
# Otherwise it fails with:
#     mksh: Fatal error in reader: Unmatched `(' on line
CONFIGURE_ENV += MAKE="$(GMAKE)"

PKCS11_LIB32 = /usr/lib/libpkcs11.so.1
PKCS11_LIB64 = /usr/lib/64/libpkcs11.so.1

ENGINESDIR_32 = /lib/openssl/engines
ENGINESDIR_64 = /lib/openssl/engines/64

CONFIGURE_OPTIONS =  -DSOLARIS_OPENSSL -DNO_WINDOWS_BRAINDEATH
CONFIGURE_OPTIONS += --openssldir=/etc/openssl
CONFIGURE_OPTIONS += --prefix=/usr
CONFIGURE_OPTIONS += --install_prefix=$(PROTO_DIR)
CONFIGURE_OPTIONS += no-ec
CONFIGURE_OPTIONS += no-ecdh
CONFIGURE_OPTIONS += no-ecdsa
CONFIGURE_OPTIONS += no-rc3
CONFIGURE_OPTIONS += no-rc5
CONFIGURE_OPTIONS += no-mdc2
CONFIGURE_OPTIONS += no-idea
CONFIGURE_OPTIONS += no-hw_4758_cca
CONFIGURE_OPTIONS += no-hw_aep
CONFIGURE_OPTIONS += no-hw_atalla
CONFIGURE_OPTIONS += no-hw_chil
CONFIGURE_OPTIONS += no-hw_gmp
CONFIGURE_OPTIONS += no-hw_ncipher
CONFIGURE_OPTIONS += no-hw_nuron
CONFIGURE_OPTIONS += no-hw_padlock
CONFIGURE_OPTIONS += no-hw_sureware
CONFIGURE_OPTIONS += no-hw_ubsec
CONFIGURE_OPTIONS += no-hw_cswift
CONFIGURE_OPTIONS += threads
CONFIGURE_OPTIONS += shared

CONFIGURE_OPTIONS32_i386 =	solaris-x86-cc-sunw
CONFIGURE_OPTIONS64_i386 =	solaris64-x86_64-cc-sunw

CONFIGURE_OPTIONS += --pk11-libname=$(PKCS11_LIB$(BITS))
CONFIGURE_OPTIONS += --enginesdir=$(ENGINESDIR_$(BITS))
CONFIGURE_OPTIONS += $(CONFIGURE_OPTIONS$(BITS)_$(MACH))

# OpenSSL has its own configure system which must be run from the fully
# populated source code directory. However, the Userland configuration phase is
# run from the build directory. The easiest way to workaround it is to copy all
# the source files there.
COMPONENT_PRE_CONFIGURE_ACTION = \
	(	$(CLONEY) $(SOURCE_DIR) $(BUILD_DIR)/$(MACH$(BITS)); \
	cd $(BUILD_DIR)/$(MACH$(BITS))/include/openssl && rm cmac.h modes.h srp.h srtp.h ts.h whrlpool.h; \
	)


# We deliver only one opensslconf.h file which must be suitable for both 32 and
# 64 bits. Depending on the configuration option, OpenSSL's Configure script
# creates opensslconf.h for either 32 or 64 bits. A patch makes the resulting
# header file usable on both architectures. The patch was generated against the
# opensslconf.h version from the 32 bit build.
COMPONENT_POST_CONFIGURE_ACTION = \
    ( [ $(BITS) -eq 32 ] && $(GPATCH) -p1 $(@D)/crypto/opensslconf.h \
      patches-post-config/opensslconf.patch; cd $(@D); $(MAKE) depend; )

# We do not ship our engines as patches since it would be more difficult to
# update the files which have been under continuous development. We rather copy
# the files to the right directories and let OpenSSL makefiles build it.
COMPONENT_PRE_BUILD_ACTION = \
	(	$(CP) -fp engines/devcrypto/*.[ch]	$(@D)/engines; \
		$(CP) -fp engines/pkcs11/*.[ch]		$(@D)/crypto/engine; \
  	)

build:		$(BUILD_32_and_64)
		(    elfedit -e 'cap:hw1 -and -cmp sse2' -e 'cap:hw1 -and -cmp mmx' $(BUILD_DIR_32)/libcrypto.so.0.9.8; )

# OpenSSL uses sections man[1357] by default so we must create the man
# directories we use for OpenSSL man pages in Solaris. Note that we patch the
# OpenSSL man page install script to use the correct directories.
MANDIR_SECTIONS =  $(PROTO_DIR)/usr/share/man/man1openssl
MANDIR_SECTIONS += $(PROTO_DIR)/usr/share/man/man3openssl
MANDIR_SECTIONS += $(PROTO_DIR)/usr/share/man/man5openssl
MANDIR_SECTIONS += $(PROTO_DIR)/usr/share/man/man7openssl

# We must create man page directories manually since we patched OpenSSL install
# code to install into manXopenssl instead of manX. Also, OpenSSL does not
# install into <dir>/$(MACH64) for 64-bit install so no such directory is
# created and Userland install code would fail when installing lint libraries.
COMPONENT_PRE_INSTALL_ACTION = ( $(MKDIR) $(MANDIR_SECTIONS); \
    $(MKDIR) $(PROTO_DIR)/usr/lib/$(MACH64); )

# We need patched opensslconf in package
$(INSTALL_64): COMPONENT_POST_INSTALL_ACTION= \
		(	$(CP) $(BUILD_DIR)/$(MACH32)/crypto/opensslconf.h \
				$(PROTO_DIR)/usr/include/openssl; )

# The install_docs target will install man pages into $(PROTO_DIR)/$(MANDIR). We
# also add /usr/perl5/bin to PATH so that OpenSSL install code can locate the
# system pod2man. If not set, OpenSSL make would use an internal implementation
# from the tarball which would corrupt some man pages.
COMPONENT_INSTALL_ARGS += PATH=$(PATH) MANDIR=/usr/share/man

install:	$(INSTALL_32)

# We need to modify the default lint flags to include patched opensslconf.h from
# the build directory. If we do not do that, lint will complain about md2.h
# which is not enabled by default but it is in our opensslconf.h.
LFLAGS_32 := -I$(BUILD_DIR_32)/include $(LINT_FLAGS)
LFLAGS_64 := -I$(BUILD_DIR_64)/include $(LINT_FLAGS)

# Set modified lint flags for our lint library targets.
$(BUILD_DIR_32)/llib-lcrypto.ln: LINT_FLAGS=$(LFLAGS_32)
$(BUILD_DIR_32)/llib-lssl.ln: LINT_FLAGS=$(LFLAGS_32)
$(BUILD_DIR_64)/llib-lcrypto.ln: LINT_FLAGS=$(LFLAGS_64)
$(BUILD_DIR_64)/llib-lssl.ln: LINT_FLAGS=$(LFLAGS_64)

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

