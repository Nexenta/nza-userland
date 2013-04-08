# Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved.


include ../../../make-rules/shared-macros.mk

COMPILER = studio

PATH=$(SPRO_VROOT)/bin:/usr/bin:/usr/gnu/bin:/usr/perl5/bin

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

# OpenSSL does not use autoconf but its own configure system.
CONFIGURE_SCRIPT = $(SOURCE_DIR)/Configure

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
CONFIGURE_OPTIONS += no-static

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
    ( $(CLONEY) $(SOURCE_DIR) $(BUILD_DIR)/$(MACH$(BITS)); )

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
	
# OpenSSL does not install into <dir>/$(MACH64) for 64-bit install so no such
# directory is created and Userland install code would fail when installing lint
# libraries.
COMPONENT_PRE_INSTALL_ACTION = ( $(MKDIR) $(PROTO_DIR)/usr/lib/$(MACH64); )


$(INSTALL_64): COMPONENT_INSTALL_ARGS += DESTDIR=$(BUILD_DIR)/proto/64

build:		$(BUILD_32_and_64)
install:	$(INSTALL_32)
test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

