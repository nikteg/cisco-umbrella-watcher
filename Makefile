# Makefile for cisco-umbrella-watcher

BINARY = cisco-umbrella-watcher
SOURCE = cisco-umbrella-watcher.swift
PREFIX = /usr/local
BINDIR = $(PREFIX)/bin

SWIFTC = swiftc
SWIFTFLAGS = -O

PLIST_NAME = com.local.cisco-umbrella-watcher.plist
PLIST_SRC = $(PLIST_NAME)
PLIST_DST = $(HOME)/Library/LaunchAgents/$(PLIST_NAME)

SUDOERS_FILE = /etc/sudoers.d/umbrellactl
UMBRELLACTL_SRC = umbrellactl
UMBRELLACTL_DST = $(BINDIR)/umbrellactl

.PHONY: all build install uninstall clean restart install-agent uninstall-agent setup-sudoers remove-sudoers install-umbrellactl uninstall-umbrellactl

all: build

build: $(BINARY)

$(BINARY): $(SOURCE)
	$(SWIFTC) $(SWIFTFLAGS) -o $(BINARY) $(SOURCE)

install: $(BINARY)
	@if [ $$(id -u) -ne 0 ]; then echo "Error: must run with sudo"; exit 1; fi
	install -d $(BINDIR)
	install -m 755 $(BINARY) $(BINDIR)/$(BINARY)

uninstall:
	@if [ $$(id -u) -ne 0 ]; then echo "Error: must run with sudo"; exit 1; fi
	rm -f $(BINDIR)/$(BINARY)

clean:
	rm -f $(BINARY)

restart:
	launchctl unload $(PLIST_DST) 2>/dev/null || true
	launchctl load $(PLIST_DST)

install-agent: $(PLIST_SRC)
	launchctl unload $(PLIST_DST) 2>/dev/null || true
	install -d $(HOME)/Library/LaunchAgents
	install -m 644 $(PLIST_SRC) $(PLIST_DST)
	launchctl load $(PLIST_DST)

uninstall-agent:
	launchctl unload $(PLIST_DST) 2>/dev/null || true
	rm -f $(PLIST_DST)

setup-sudoers:
	@if [ -z "$$SUDO_USER" ]; then echo "Error: must run with sudo"; exit 1; fi
	@echo "$$SUDO_USER ALL=(ALL) NOPASSWD: $(UMBRELLACTL_DST)" > $(SUDOERS_FILE)
	@chmod 0440 $(SUDOERS_FILE)
	@echo "Created $(SUDOERS_FILE) for user $$SUDO_USER"

remove-sudoers:
	@if [ $$(id -u) -ne 0 ]; then echo "Error: must run with sudo"; exit 1; fi
	rm -f $(SUDOERS_FILE)

install-umbrellactl: $(UMBRELLACTL_SRC)
	@if [ $$(id -u) -ne 0 ]; then echo "Error: must run with sudo"; exit 1; fi
	install -d $(BINDIR)
	install -m 755 $(UMBRELLACTL_SRC) $(UMBRELLACTL_DST)

uninstall-umbrellactl:
	@if [ $$(id -u) -ne 0 ]; then echo "Error: must run with sudo"; exit 1; fi
	rm -f $(UMBRELLACTL_DST)
