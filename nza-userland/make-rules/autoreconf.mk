
$(SOURCE_DIR)/.prep: $(SOURCE_DIR)/.autoreconf

$(SOURCE_DIR)/.autoreconf: $(SOURCE_DIR)/.patched
	cd "$(dir $(CONFIGURE_SCRIPT))" && autoreconf -iv
	touch "$@"

