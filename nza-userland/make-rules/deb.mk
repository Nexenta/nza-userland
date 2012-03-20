# Copyright (c) 2012, Nexenta Systems, Inc. All rights reserved.

# shared-macros.mk and ips.mk must be included before

DEBMAKER = $(WS_TOOLS)/debmaker.pl
DEBVERSION ?= 40-0-$(VCS_REV_NUM)

# Where to find binaries
# (like debian/tmp):
PROTO_DIRS = $(PKG_PROTO_DIRS:%=-d %)

# Where to create package contents
# and debs (like debian/pkg-name)
DEBS_DIR = $(COMPONENT_DIR)/debs

ALLDEB_DIR ?= $(WS_TOP)/debs

deb: build install __deb

DEB_STAMP = $(BUILD_DIR)/.deb
__deb: $(DEB_STAMP)
$(DEB_STAMP): $(DEBMAKER) $(MANGLED)
	$(RM) -r $(DEBS_DIR)
	$(MKDIR) $(DEBS_DIR)
	$(DEBMAKER) \
		-S $(COMPONENT_NAME) \
		-N $(CONSOLIDATION) \
		-V $(DEBVERSION) \
		-D $(DEBS_DIR) \
		$(PROTO_DIRS) $(MANGLED)
#	$(CP) $(DEBS_DIR)/*.{deb,changes} $(ALLDEB_DIR)/
	$(TOUCH) $@

clean::
	$(RM) -r $(DEBS_DIR)

NABAT_HOST    ?= 10.3.10.2
NABAT_USER    ?= changeme_by_NABAT_USER
NABAT_DIST    ?= base
NABAT_REPO    ?= unstable
NABAT_DESTDIR ?= pkg_upload

nabat-upload:
	@if ls $(DEBS_DIR)/*.deb 2>/dev/null 1>/dev/null ; then \
		echo uploading to $(NABAT_USER)@$(NABAT_HOST):$(NABAT_DESTDIR)/$(NABAT_DIST)-$(NABAT_REPO)/ ; \
		scp $(DEBS_DIR)/*.{deb,changes} \
			$(NABAT_USER)@$(NABAT_HOST):$(NABAT_DESTDIR)/$(NABAT_DIST)-$(NABAT_REPO)/ ; \
	else \
		echo "make deb first" ; \
	fi

nabat-push:
	ssh $(NABAT_USER)@$(NABAT_HOST) "touch '$(NABAT_DESTDIR)/$(NABAT_DIST)-$(NABAT_REPO)/packages.fini'"


