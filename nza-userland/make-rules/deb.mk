# Copyright (c) 2012, Nexenta Systems, Inc. All rights reserved.

# shared-macros.mk and ips.mk must be included before

DEBMAKER = $(WS_TOOLS)/debmaker.pl
DEBVERSION ?= 40-0-$(VCS_REV_NUM)

# Where to find binaries
# (like debian/tmp):
PROTO_DIRS = $(PKG_PROTO_DIRS:%=-d %)

# See in make-rules/ips.mk
# Do not use PKG_OPTIONS here cause it may not be limited to '-D's
DEFINES = $(PKG_MACROS:%=-D %)

# Where to create package contents
# and debs (like debian/pkg-name)
OUTDIR = $(COMPONENT_DIR)/debs

ALLDEB_DIR ?= $(WS_TOP)/debs

deb: build install __deb

DEB_STAMP = $(BUILD_DIR)/.deb
__deb: $(DEB_STAMP)
$(DEB_STAMP): $(DEBMAKER) $(MANGLED)
	$(RM) -r $(OUTDIR)
	$(MKDIR) $(OUTDIR)
	$(DEBMAKER) \
		-S $(COMPONENT_NAME) \
		-N $(CONSOLIDATION) \
		-V $(DEBVERSION) \
		-O $(OUTDIR) \
		$(PROTO_DIRS) \
		$(DEFINES) \
		$(MANGLED)
#	$(CP) $(OUTDIR)/*.{deb,changes} $(ALLDEB_DIR)/
	$(TOUCH) $@

clean::
	$(RM) -r $(OUTDIR)

NABAT_HOST    ?= 10.3.10.2
NABAT_USER    ?= changeme_by_NABAT_USER
NABAT_DIST    ?= base
NABAT_REPO    ?= unstable
NABAT_DESTDIR ?= pkg_upload

nabat-upload:
	@if ls $(OUTDIR)/*.deb 2>/dev/null 1>/dev/null ; then \
		echo uploading to $(NABAT_USER)@$(NABAT_HOST):$(NABAT_DESTDIR)/$(NABAT_DIST)-$(NABAT_REPO)/ ; \
		scp $(OUTDIR)/*.{deb,changes} \
			$(NABAT_USER)@$(NABAT_HOST):$(NABAT_DESTDIR)/$(NABAT_DIST)-$(NABAT_REPO)/ ; \
	else \
		echo "make deb first" ; \
	fi

nabat-push:
	ssh $(NABAT_USER)@$(NABAT_HOST) "touch '$(NABAT_DESTDIR)/$(NABAT_DIST)-$(NABAT_REPO)/packages.fini'"


