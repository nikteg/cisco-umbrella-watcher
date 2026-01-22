# Makefile for cisco-umbrella-watcher

BINARY = cisco-umbrella-watcher
SOURCE = cisco-umbrella-watcher.swift
PREFIX = /usr/local
BINDIR = $(PREFIX)/bin

SWIFTC = swiftc
SWIFTFLAGS = -O

.PHONY: all build install uninstall clean

all: build

build: $(BINARY)

$(BINARY): $(SOURCE)
	$(SWIFTC) $(SWIFTFLAGS) -o $(BINARY) $(SOURCE)

install: $(BINARY)
	install -d $(BINDIR)
	install -m 755 $(BINARY) $(BINDIR)/$(BINARY)

uninstall:
	rm -f $(BINDIR)/$(BINARY)

clean:
	rm -f $(BINARY)
