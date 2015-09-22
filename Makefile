# Install path prefix
# To install to /bin, set this to /.
ifndef PREFIX
    PREFIX = /usr
endif

all:
	csc urlexpand.scm

clean:
	rm urlexpand

install:
	cp urlexpand $(PREFIX)/bin/urlexpand

uninstall:
	rm $(PREFIX)/bin/urlexpand
