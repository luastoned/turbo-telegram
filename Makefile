#
# Makefile for module installation.
# Copyright (c) 2015 @LuaStoned
# See LICENSE file for license information.
#

CP = cp -r
RM = rm -f

PREFIX ?= /usr/local
FILENAME = telegram.lua

MAJVER = 1
MINVER = 0
MICVER = 0
ESNVER = $(MAJVER).$(MINVER).$(MICVER)

LUA_MODULEDIR = $(PREFIX)/share/lua/5.1

LUAJIT_VERSION ?= 2.0.4
LUAJIT_MODULEDIR = $(PREFIX)/share/luajit-$(LUAJIT_VERSION)

default: install
clean: uninstall

install:
	@echo "=== Installing $(FILENAME) v$(ESNVER) to: $(LUAJIT_MODULEDIR) ==="
	$(CP) $(FILENAME) $(LUA_MODULEDIR)
	$(CP) $(FILENAME) $(LUAJIT_MODULEDIR)
	@echo "=== Successfully installed $(FILENAME) ==="

uninstall:
	@echo "=== Uninstalling $(FILENAME) from: $(LUAJIT_MODULEDIR) ==="
	$(RM) $(LUA_MODULEDIR)/$(FILENAME)
	$(RM) $(LUAJIT_MODULEDIR)/$(FILENAME)
	@echo "=== Successfully uninstalled $(FILENAME) ==="
