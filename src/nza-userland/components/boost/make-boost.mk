
PREFIX ?= /usr/local
LIBDIR ?= $(PREFIX)/lib

bjam = $(CURDIR)/bjam
bbv2dir = $(CURDIR)/tools/build/v2
JAM = $(bjam) -d2 $(JAM_OPT) \
	  --layout=system \
	  --ignore-site-config \
	  debug-symbols=on \
	  cxxflags="$(CPPFLAGS) $(CFLAGS) $(CXXFLAGS)"

userconfig := $(wildcard user-config.jam)
ifneq (,$(userconfig))
JAM += --user-config="$(CURDIR)/$(userconfig)"
endif

build: $(bjam) $(userconfig)
	$(JAM)
	cd $(bbv2dir) && ./bootstrap.sh
	cd tools/bcp && $(JAM)
	cd tools/inspect/build && $(JAM)
	cd tools/quickbook && $(JAM)
	cd tools/wave/build && $(JAM)
	cd tools/regression/build && $(JAM)
	cd libs/python/pyste/install && python setup.py build


$(bjam):
	./bootstrap.sh --with-icu --prefix=$(PREFIX) --libdir=$(LIBDIR) \
	  || cat bootstrap.log

install:
	$(JAM) --prefix=$(DESTDIR)$(PREFIX) --libdir=$(DESTDIR)$(LIBDIR) install

clean:
	$(bjam) clean

