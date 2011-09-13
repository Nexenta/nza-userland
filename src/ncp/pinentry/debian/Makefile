packages = $(addprefix pinentry-, curses)
binaries = $(addprefix pinentry-, curses)
suffixes = install manpages postinst prerm README.Debian
targets = $(foreach suffix,$(suffixes),$(foreach package,$(packages),$(package).$(suffix))) \
	$(foreach binary,$(binaries),$(binary).1)


all: $(targets)

pinentry-curses.%: pinentry.%.in
	m4 -P -Dflavor=curses $< >$@


clean:
	rm -f $(targets)


.PHONY: all clean
