# Install path prefix
# To install to /bin, set this to /.
ifndef PREFIX
    PREFIX = /usr
endif

all:
	csc urlextend.scm

clean:
	rm urlextend

install:
	cp urlextend $(PREFIX)/bin/urlextend

uninstall:
	rm $(PREFIX)/bin/urlextend
