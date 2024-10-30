.POSIX:
.SUFFIX:
HARE=hare
HAREFLAGS=

DESTDIR=
PREFIX=/usr/local
BINDIR=$(PREFIX)/bin

all: ignore

ignore: cmd/ignore/main.ha
	hare build  -o ignore cmd/ignore/main.ha

check:
	$(HARE) test $(HAREFLAGS)
clean:
	 rm -f ignore

install:
	install -Dm755 cmd $(DESTDIR)$(BINDIR)/cmd

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/cmd

.PHONY: all check clean install uninstall
