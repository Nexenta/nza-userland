#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright (c) 2011, Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME         = nginx
COMPONENT_VERSION      = 1.1.8
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL  = http://nginx.org
COMPONENT_ARCHIVE      = $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:e93c4b48379c0240fd4c7af8982faa3c4a7c834f
COMPONENT_ARCHIVE_URL  = http://nginx.org/download/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
CONFIGURE_DEFAULT_DIRS = no
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk

COMPONENT_PRE_CONFIGURE_ACTION = $(CLONEY) $(SOURCE_DIR) $(@D);

#SBIN.32 = /usr/sbin/$(MARCH)/nginx
SBIN.32 = /usr/sbin/nginx
SBIN.64 = /usr/sbin/$(MARCH64)/nginx

CONFIGURE_ENV += CFLAGS="$(CFLAGS)"

CONFIGURE_OPTIONS  = --prefix=/etc/nginx
CONFIGURE_OPTIONS += --sbin-path=$(SBIN.$(BITS))
CONFIGURE_OPTIONS += --user=webservd
CONFIGURE_OPTIONS += --group=webservd
CONFIGURE_OPTIONS += --conf-path=/etc/nginx/nginx.conf
CONFIGURE_OPTIONS += --error-log-path=/var/log/nginx/error.log
CONFIGURE_OPTIONS += --http-client-body-temp-path=/var/lib/nginx/body
CONFIGURE_OPTIONS += --http-fastcgi-temp-path=/var/lib/nginx/fastcgi
CONFIGURE_OPTIONS += --http-log-path=/var/log/nginx/access.log
CONFIGURE_OPTIONS += --http-proxy-temp-path=/var/lib/nginx/proxy
CONFIGURE_OPTIONS += --http-scgi-temp-path=/var/lib/nginx/scgi
CONFIGURE_OPTIONS += --http-uwsgi-temp-path=/var/lib/nginx/uwsgi
CONFIGURE_OPTIONS += --lock-path=/var/lock/nginx.lock
CONFIGURE_OPTIONS += --pid-path=/var/run/nginx.pid
CONFIGURE_OPTIONS += --with-http_addition_module
#CONFIGURE_OPTIONS += --with-geoip_module
CONFIGURE_OPTIONS += --with-http_dav_module
CONFIGURE_OPTIONS += --with-http_gzip_static_module
CONFIGURE_OPTIONS += --with-http_image_filter_module
CONFIGURE_OPTIONS += --with-http_realip_module
CONFIGURE_OPTIONS += --with-http_stub_status_module
CONFIGURE_OPTIONS += --with-http_ssl_module
CONFIGURE_OPTIONS += --with-http_sub_module
CONFIGURE_OPTIONS += --with-http_xslt_module
CONFIGURE_OPTIONS += --with-ipv6
CONFIGURE_OPTIONS += --with-sha1=/usr/include/openssl
CONFIGURE_OPTIONS += --with-md5=/usr/include/openssl
CONFIGURE_OPTIONS += --with-mail
CONFIGURE_OPTIONS += --with-mail_ssl_module 

# Not all libs have 64-bits versions
build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk
