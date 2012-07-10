#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license
# at http://www.opensource.org/licenses/CDDL-1.0
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each file.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright (C) 2012, Nexenta Systems, Inc. All rights reserved.
#

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME     :=  kerberos
COMPONENT_VERSION  :=  1.1.1
COMPONENT_SRC      :=  $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  :=  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH := sha1:305cc1ea1e7a209402bca30fbb74a2ca8f2f539d
COMPONENT_ARCHIVE_URL  := http://pypi.python.org/packages/source/k/$(COMPONENT_NAME)/$(COMPONENT_ARCHIVE)

################# NOTICE ###################
# Illumos kerberos is not compatible with
# this python bindings, which largely relies
# on GSS API. So we use MIT Kerberos here,
# but only *static* *PIC* libraries
############### THANK YOU! #################

KRB_VER := 1.10
KRB_VERSION := $(KRB_VER).2
MIT_KRB_SRC := krb5-$(KRB_VERSION)-signed.tar
COMPONENT_ARCHIVE_HASH_1 := sha1:8b6e2c5bf0c65aacd368b3698add7888f2a7332d
COMPONENT_ARCHIVE_URL_1 := http://web.mit.edu/kerberos/dist/krb5/$(KRB_VER)/$(MIT_KRB_SRC)


include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/setup.py.mk

krb_libs = libgssapi_krb5.a libkrb5.a libk5crypto.a libcom_err.a libkrb5support.a
sys_libs = -lsocket -lnsl -lresolv

build-krb-stamp:
	mkdir -p _krb
	cd _krb && \
		tar xf ../$(MIT_KRB_SRC) && \
		tar xf krb5-$(KRB_VERSION).tar.gz && \
		cd krb5-$(KRB_VERSION)/src && \
			./configure --disable-shared --enable-static CC="$(CC)" CFLAGS="$(CFLAGS) -fPIC" && \
			$(MAKE) -C util && \
			$(MAKE) -C include && \
			$(MAKE) -C lib && \
			cp lib/lib*.a $(SOURCE_DIR)/ && \
			cp -r include $(SOURCE_DIR)/krb5
	touch $@

clean::
	rm -rf _krb
	rm -f *-stamp

patch-for-local-krb-stamp:
	sed -i $(COMPONENT_SRC)/setup.py \
		-e 's#extra_link_args.*#extra_link_args="$(krb_libs) $(sys_libs)".split(),#' \
		-e 's#extra_compile_args.*#extra_compile_args="-I$(SOURCE_DIR)/krb5".split(),#'


build: $(BUILD_32)
$(BUILD_32): build-krb-stamp patch-for-local-krb-stamp

install: $(INSTALL_32)

test: $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

