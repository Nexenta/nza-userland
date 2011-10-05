
# shared-macros.mk and ips.mk must be included before

DEBMAKER = $(WS_TOOLS)/debmaker.pl
DEBVERSION ?= ips

# Where to find binaries
# (like debian/tmp):
PROTO_DIRS = $(PKG_PROTO_DIRS:%=-d %)

# Where to create package contents
# and debs (like debian/pkg-name)
DEBS_DIR = $(PROTO_DIR)/debs

$(DEBS_DIR):
	$(MKDIR) $@

# Actually we need $(RESOLVED),
# but pkgdepend resolve does not work:
deb: build install $(DEPENDED) $(DEBS_DIR)
	$(DEBMAKER) -V $(DEBVERSION) -D $(DEBS_DIR) $(PROTO_DIRS) $(DEPENDED)


