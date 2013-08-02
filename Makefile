# Makefile
#
RAND := $(shell echo $$RANDOM)
BUILDDIR := "/tmp/$(RAND)"

all: ruby

ruby: setup
	cd $(BUILDDIR)/ruby; make pkg
	@cd $(BUILDDIR) ; installer -pkg *.pkg -target /
	touch ruby

setup:
	mkdir -p $(BUILDDIR)
	cp -pr ruby $(BUILDDIR)
	touch setup
