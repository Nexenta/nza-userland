
# shared-macros.mk and ips.mk must be included before

DEBMAKER = $(WS_TOOLS)/debmaker.pl
DEBVERSION ?= 40-0-$(VCS_REV_NUM)

# Where to find binaries
# (like debian/tmp):
PROTO_DIRS = $(PKG_PROTO_DIRS:%=-d %)

# Where to create package contents
# and debs (like debian/pkg-name)
DEBS_DIR = $(PROTO_DIR)/debs

deb: build install $(MANGLED) $(DEBMAKER)
	rm -rf $(DEBS_DIR)
	$(MKDIR) $(DEBS_DIR)
	$(DEBMAKER) \
		-S $(COMPONENT_NAME) \
		-N $(CONSOLIDATION) \
		-V $(DEBVERSION) \
		-D $(DEBS_DIR) \
		$(PROTO_DIRS) $(MANGLED)


