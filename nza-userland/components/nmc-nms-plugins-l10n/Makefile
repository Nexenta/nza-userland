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
# Copyright (c) 2012, Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME = nmc-nms-plugins-l10n
COMPONENT_VERSION = 40-0-0

include $(WS_TOP)/make-rules/ips.mk

clean::
	rm -rf $(BUILD_DIR)
	find . -name "*.mo" | xargs rm -f

build:
	$(MKDIR) $(BUILD_DIR)

install:
	msgfmt nmc/de/LC_MESSAGES/nmc.po -o nmc/de/LC_MESSAGES/nmc.mo
	msgfmt nmc/ja/LC_MESSAGES/nmc.po -o nmc/ja/LC_MESSAGES/nmc.mo
	msgfmt nmc/ko/LC_MESSAGES/nmc.po -o nmc/ko/LC_MESSAGES/nmc.mo
	msgfmt nmc/ru/LC_MESSAGES/nmc.po -o nmc/ru/LC_MESSAGES/nmc.mo
	msgfmt nmc/zh_CN/LC_MESSAGES/nmc.po -o nmc/zh_CN/LC_MESSAGES/nmc.mo
	msgfmt nms/de/LC_MESSAGES/nms.po -o nms/de/LC_MESSAGES/nms.mo
	msgfmt nms/ja/LC_MESSAGES/nms.po -o nms/ja/LC_MESSAGES/nms.mo
	msgfmt nms/ko/LC_MESSAGES/nms.po -o nms/ko/LC_MESSAGES/nms.mo
	msgfmt nms/ru/LC_MESSAGES/nms.po -o nms/ru/LC_MESSAGES/nms.mo
	msgfmt nms/zh_CN/LC_MESSAGES/nms.po -o nms/zh_CN/LC_MESSAGES/nms.mo
	msgfmt nms-autosmart/de/LC_MESSAGES/nms-autosmart.po -o nms-autosmart/de/LC_MESSAGES/nms-autosmart.mo
	msgfmt nms-autosmart/ja/LC_MESSAGES/nms-autosmart.po -o nms-autosmart/ja/LC_MESSAGES/nms-autosmart.mo
	msgfmt nms-autosmart/ko/LC_MESSAGES/nms-autosmart.po -o nms-autosmart/ko/LC_MESSAGES/nms-autosmart.mo
	msgfmt nms-autosmart/ru/LC_MESSAGES/nms-autosmart.po -o nms-autosmart/ru/LC_MESSAGES/nms-autosmart.mo
	msgfmt nms-autosmart/zh_CN/LC_MESSAGES/nms-autosmart.po -o nms-autosmart/zh_CN/LC_MESSAGES/nms-autosmart.mo
	msgfmt nms-autosync/de/LC_MESSAGES/nms-autosync.po -o nms-autosync/de/LC_MESSAGES/nms-autosync.mo
	msgfmt nms-autosync/ja/LC_MESSAGES/nms-autosync.po -o nms-autosync/ja/LC_MESSAGES/nms-autosync.mo
	msgfmt nms-autosync/ko/LC_MESSAGES/nms-autosync.po -o nms-autosync/ko/LC_MESSAGES/nms-autosync.mo
	msgfmt nms-autosync/ru/LC_MESSAGES/nms-autosync.po -o nms-autosync/ru/LC_MESSAGES/nms-autosync.mo
	msgfmt nms-autosync/zh_CN/LC_MESSAGES/nms-autosync.po -o nms-autosync/zh_CN/LC_MESSAGES/nms-autosync.mo
	msgfmt nms-comstar/de/LC_MESSAGES/nms-comstar.po -o nms-comstar/de/LC_MESSAGES/nms-comstar.mo
	msgfmt nms-comstar/ja/LC_MESSAGES/nms-comstar.po -o nms-comstar/ja/LC_MESSAGES/nms-comstar.mo
	msgfmt nms-comstar/ko/LC_MESSAGES/nms-comstar.po -o nms-comstar/ko/LC_MESSAGES/nms-comstar.mo
	msgfmt nms-comstar/ru/LC_MESSAGES/nms-comstar.po -o nms-comstar/ru/LC_MESSAGES/nms-comstar.mo
	msgfmt nms-comstar/zh_CN/LC_MESSAGES/nms-comstar.po -o nms-comstar/zh_CN/LC_MESSAGES/nms-comstar.mo
	msgfmt nms-confguard/de/LC_MESSAGES/nms-confguard.po -o nms-confguard/de/LC_MESSAGES/nms-confguard.mo
	msgfmt nms-confguard/ja/LC_MESSAGES/nms-confguard.po -o nms-confguard/ja/LC_MESSAGES/nms-confguard.mo
	msgfmt nms-confguard/ko/LC_MESSAGES/nms-confguard.po -o nms-confguard/ko/LC_MESSAGES/nms-confguard.mo
	msgfmt nms-confguard/ru/LC_MESSAGES/nms-confguard.po -o nms-confguard/ru/LC_MESSAGES/nms-confguard.mo
	msgfmt nms-confguard/zh_CN/LC_MESSAGES/nms-confguard.po -o nms-confguard/zh_CN/LC_MESSAGES/nms-confguard.mo
	msgfmt nmu/de/LC_MESSAGES/nmu.po -o nmu/de/LC_MESSAGES/nmu.mo
	msgfmt nmu/ja/LC_MESSAGES/nmu.po -o nmu/ja/LC_MESSAGES/nmu.mo
	msgfmt nmu/ko/LC_MESSAGES/nmu.po -o nmu/ko/LC_MESSAGES/nmu.mo
	msgfmt nmu/ru/LC_MESSAGES/nmu.po -o nmu/ru/LC_MESSAGES/nmu.mo
	msgfmt nmu/zh_CN/LC_MESSAGES/nmu.po -o nmu/zh_CN/LC_MESSAGES/nmu.mo

test:

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk
