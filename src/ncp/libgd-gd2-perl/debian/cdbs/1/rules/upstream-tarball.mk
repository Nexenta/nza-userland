# -*- mode: makefile; coding: utf-8 -*-
# Copyright © 2007-2008 Jonas Smedegaard <dr@jones.dk>
# Description: Convenience rules for dealing with upstream tarballs
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307 USA.

_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class

ifndef _cdbs_rules_upstream_tarball
_cdbs_rules_upstream_tarball := 1

include $(_cdbs_rules_path)/buildvars.mk$(_cdbs_makefile_suffix)

CDBS_BUILD_DEPENDS := $(CDBS_BUILD_DEPENDS), cdbs (>= 0.4.39)

# Prefix for upstream location of all upstream tarballs (mandatory!)
#DEB_UPSTREAM_URL = 

DEB_UPSTREAM_PACKAGE = $(DEB_SOURCE_PACKAGE)
DEB_UPSTREAM_TARBALL_VERSION = $(if $(strip $(DEB_UPSTREAM_REPACKAGE_EXCLUDE)),$(DEB_UPSTREAM_VERSION:$(DEB_UPSTREAM_REPACKAGE_DELIMITER)$(DEB_UPSTREAM_REPACKAGE_TAG)=),$(DEB_UPSTREAM_VERSION))
DEB_UPSTREAM_TARBALL_EXTENSION = tar.gz
# Checksum to ensure integrity of downloadeds using get-orig-source (optional)
#DEB_UPSTREAM_TARBALL_MD5 = 

DEB_UPSTREAM_WORKDIR = ../tarballs

# Perl regexp to change locally used string into that in upstream URL and srcdir
#DEB_UPSTREAM_TARBALL_VERSION_MANGLE
cdbs_upstream_tarball_version_mangled = $(if $(strip $(DEB_UPSTREAM_TARBALL_VERSION_MANGLE)),$(shell echo '$(DEB_UPSTREAM_TARBALL_VERSION)' | perl -pe '$(DEB_UPSTREAM_TARBALL_VERSION_MANGLE)'),$(DEB_UPSTREAM_TARBALL_VERSION))

# Base filename (without extension) as used in upstream URL
DEB_UPSTREAM_TARBALL_BASENAME = $(DEB_UPSTREAM_PACKAGE)-$(cdbs_upstream_tarball_version_mangled)

# Base directory within tarball
DEB_UPSTREAM_TARBALL_SRCDIR = $(DEB_UPSTREAM_PACKAGE)-$(cdbs_upstream_tarball_version_mangled)

# Space-delimited list of directories and files to strip (optional)
#DEB_UPSTREAM_REPACKAGE_EXCLUDE = CVS .cvsignore doc/rfc*.txt doc/draft*.txt
DEB_UPSTREAM_REPACKAGE_TAG = dfsg
DEB_UPSTREAM_REPACKAGE_DELIMITER = ~

cdbs_upstream_tarball = $(DEB_UPSTREAM_TARBALL_BASENAME).$(DEB_UPSTREAM_TARBALL_EXTENSION)
cdbs_upstream_local_tarball = $(DEB_SOURCE_PACKAGE)_$(DEB_UPSTREAM_TARBALL_VERSION).orig.$(if $(findstring $(DEB_UPSTREAM_TARBALL_EXTENSION),tgz),tar.gz,$(DEB_UPSTREAM_TARBALL_EXTENSION))
cdbs_upstream_repackaged_basename = $(DEB_SOURCE_PACKAGE)_$(DEB_UPSTREAM_TARBALL_VERSION)$(DEB_UPSTREAM_REPACKAGE_DELIMITER)$(DEB_UPSTREAM_REPACKAGE_TAG).orig
cdbs_upstream_uncompressed_tarball = $(DEB_SOURCE_PACKAGE)_$(DEB_UPSTREAM_TARBALL_VERSION).orig.tar

# # These variables are deprecated
_cdbs_deprecated_vars += DEB_UPSTREAM_TARBALL DEB_UPSTREAM_LOCAL_TARBALL DEB_UPSTREAM_REPACKAGE_TARBALL
_cdbs_deprecated_vars += DEB_UPSTREAM_REPACKAGE_EXCLUDES
DEB_UPSTREAM_REPACKAGE_EXCLUDE += $(DEB_UPSTREAM_REPACKAGE_EXCLUDES)

print-version:
	@@echo "Debian version:          $(DEB_VERSION)"
	@@echo "Upstream version:        $(DEB_UPSTREAM_TARBALL_VERSION)"

get-orig-source:
	@@dh_testdir
	@@mkdir -p "$(DEB_UPSTREAM_WORKDIR)"

	@if [ ! -s "$(DEB_UPSTREAM_WORKDIR)/$(cdbs_upstream_local_tarball)" ] ; then \
		if [ -f "$(DEB_UPSTREAM_WORKDIR)/$(cdbs_upstream_local_tarball)" ] ; then \
			rm "$(DEB_UPSTREAM_WORKDIR)/$(cdbs_upstream_local_tarball)" ; \
		fi ; \
		echo "Downloading $(cdbs_upstream_local_tarball) from $(DEB_UPSTREAM_URL)/$(cdbs_upstream_tarball) ..." ; \
		wget -nv -T10 -t3 -O "$(DEB_UPSTREAM_WORKDIR)/$(cdbs_upstream_local_tarball)" "$(DEB_UPSTREAM_URL)/$(cdbs_upstream_tarball)" ; \
	else \
		echo "Upstream source tarball have been already downloaded: $(DEB_UPSTREAM_WORKDIR)/$(cdbs_upstream_local_tarball)" ; \
	fi

	@md5current=`md5sum "$(DEB_UPSTREAM_WORKDIR)/$(cdbs_upstream_local_tarball)" | sed -e 's/ .*//'`; \
	if [ -n "$(DEB_UPSTREAM_TARBALL_MD5)" ] ; then \
		if [ "$$md5current" != "$(DEB_UPSTREAM_TARBALL_MD5)" ] ; then \
			echo "Expecting upstream tarball md5sum $(DEB_UPSTREAM_TARBALL_MD5), but $$md5current found" ; \
			echo "Upstream tarball md5sum is NOT trusted! Possible upstream tarball forge!" ; \
			echo "Purging downloaded file. Try new download." ; \
			rm -f "$(DEB_UPSTREAM_WORKDIR)/$(cdbs_upstream_local_tarball)" ; \
			false ; \
		else \
			echo "Upstream tarball is trusted!" ; \
		fi; \
	else \
		echo "Upstream tarball NOT trusted (current md5sum is $$md5current)!" ; \
	fi

# TODO: Rewrite using make variables like cdbs_upstream_unpack_cmd and
# DEB_UPSTREAM_SUPPORTED_COMPRESSIONS (recent dpkg supports bz2)
	@untar="tar -x -C"; \
	case "$(cdbs_upstream_local_tarball)" in \
	    *.tar.gz)  unpack="gunzip -c";; \
	    *.tar.bz2) unpack="bunzip2 -c";    uncompress="bunzip2";; \
	    *.tar.Z)   unpack="uncompress -c"; uncompress="uncompress";; \
	    *.zip)     unpack="unzip -q";      uncompress="false";       untar="-d"; nopipe="true";; \
	    *.tar)     unpack="cat";           uncompress="true";; \
	    *) echo "Unknown extension for upstream tarball $(cdbs_upstream_local_tarball)"; false;; \
	esac && \
	if [ -n "$(strip $(DEB_UPSTREAM_REPACKAGE_EXCLUDE))" ] || [ "$$uncompress" = "false" ]; then \
		echo "Repackaging tarball ..." && \
		mkdir -p "$(DEB_UPSTREAM_WORKDIR)/$(DEB_UPSTREAM_REPACKAGE_TAG)" && \
		if [ -n "$$nopipe" ]; then \
			$$unpack "$(DEB_UPSTREAM_WORKDIR)/$(cdbs_upstream_local_tarball)" \
				$$untar "$(DEB_UPSTREAM_WORKDIR)/$(DEB_UPSTREAM_REPACKAGE_TAG)" $(patsubst %,--exclude='%',$(DEB_UPSTREAM_REPACKAGE_EXCLUDE)); \
		else \
			$$unpack "$(DEB_UPSTREAM_WORKDIR)/$(cdbs_upstream_local_tarball)" \
				| $$untar "$(DEB_UPSTREAM_WORKDIR)/$(DEB_UPSTREAM_REPACKAGE_TAG)" $(patsubst %,--exclude='%',$(DEB_UPSTREAM_REPACKAGE_EXCLUDE)); \
		fi && \
		if [ "$(DEB_UPSTREAM_TARBALL_SRCDIR)" != "$(cdbs_upstream_repackaged_basename)" ]; then \
			mv -T "$(DEB_UPSTREAM_WORKDIR)/$(DEB_UPSTREAM_REPACKAGE_TAG)/$(DEB_UPSTREAM_TARBALL_SRCDIR)" "$(DEB_UPSTREAM_WORKDIR)/$(DEB_UPSTREAM_REPACKAGE_TAG)/$(cdbs_upstream_repackaged_basename)"; \
		fi && \
		if [ -n "$(strip $(DEB_UPSTREAM_REPACKAGE_EXCLUDE))" ]; then \
			GZIP=-9 tar -b1 -czf "$(DEB_UPSTREAM_WORKDIR)/$(cdbs_upstream_repackaged_basename).tar.gz" -C "$(DEB_UPSTREAM_WORKDIR)/$(DEB_UPSTREAM_REPACKAGE_TAG)" "$(cdbs_upstream_repackaged_basename)"; \
		else \
			GZIP=-9 tar -b1 -czf "$(DEB_UPSTREAM_WORKDIR)/$(cdbs_upstream_uncompressed_tarball).gz" -C "$(DEB_UPSTREAM_WORKDIR)/$(DEB_UPSTREAM_REPACKAGE_TAG)" "$(cdbs_upstream_repackaged_basename)"; \
		fi && \
		echo "Cleaning up" && \
		rm -rf "$(DEB_UPSTREAM_WORKDIR)/$(DEB_UPSTREAM_REPACKAGE_TAG)"; \
	elif [ -n "$$uncompress" ]; then \
		echo "Recompressing tarball ..." && \
		$$uncompress "$(DEB_UPSTREAM_WORKDIR)/$(cdbs_upstream_local_tarball)"; \
		gzip -9 "$(DEB_UPSTREAM_WORKDIR)/$(cdbs_upstream_uncompressed_tarball)"; \
	fi

DEB_PHONY_RULES += print-version get-orig-source

endif
