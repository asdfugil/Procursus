ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += tigervnc
TIGERVNC_VERSION := 1.11.0
XORG_VERSION := 120
XORG-SERVER_VERSION := 1.20.10
DEB_TIGERVNC_V  ?= $(TIGERVNC_VERSION)

tigervnc-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/TigerVNC/tigervnc/archive/refs/tags/v1.11.0.tar.gz
	$(call EXTRACT_TAR,v$(TIGERVNC_VERSION).tar.gz,tigervnc-$(TIGERVNC_VERSION),tigervnc)
	$(call DO_PATCH,tigervnc,tigervnc,-p1)

ifneq ($(wildcard $(BUILD_WORK)/tigervnc/.build_complete),)
tigervnc:
	@echo "Using previously built tigervnc."
else
tigervnc: tigervnc-setup libx11 libxau libxmu xorgproto libpixman gnutls libjpeg-turbo openpam libxdamage libxfixes libxtst libxrandr libxfont2 mesa libgeneral libxkbfile
	cd $(BUILD_WORK)/tigervnc && cmake . \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CROSSCOMPILING=true \
	-DCMAKE_SYSTEM_NAME=Darwin \
	-DCMAKE_SYSTEM_PROCESSOR=$(shell echo $(GNU_HOST_TRIPLE) | cut -f1 -d-) \
	-DCMAKE_C_FLAGS="$(CFLAGS)" \
	-DCMAKE_CXX_FLAGS="$(CXXFLAGS)" \
	-DCMAKE_FIND_ROOT_PATH=$(BUILD_BASE) \
	-DCMAKE_INSTALL_NAME_TOOL=$(I_N_T) \
	-DCMAKE_INSTALL_PREFIX=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX) \
	-DCMAKE_INSTALL_NAME_DIR=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib \
	-DCMAKE_INSTALL_RPATH=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX) \
	-DCMAKE_INSTALL_SYSCONFDIR=$(MEMO_PREFIX)/etc \
	-DCMAKE_OSX_SYSROOT="$(TARGET_SYSROOT)" \
	-DCMAKE_OSX_ARCHITECTURES="$(MEMO_ARCH)" \
	-DBUILD_JAVA=TRUE
	+$(MAKE) -C $(BUILD_WORK)/tigervnc
	+$(MAKE) -C $(BUILD_WORK)/tigervnc install \
		DESTDIR=$(BUILD_STAGE)/tigervnc
	+$(MAKE) -C $(BUILD_WORK)/tigervnc install \
		DESTDIR=$(BUILD_BASE)
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/xserver/xorg-server-$(XORG-SERVER_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xorg-server-$(XORG-SERVER_VERSION).tar.gz)
	$(call EXTRACT_TAR,xorg-server-$(XORG-SERVER_VERSION).tar.gz,xorg-server-$(XORG-SERVER_VERSION),xorg-server-vnc)
	cp -R $(BUILD_WORK)/xorg-server-vnc/. $(BUILD_WORK)/tigervnc/unix/xserver
	wget -q -nc -P $(BUILD_BASE)/usr/include https://opensource.apple.com/source/X11/X11-0.40.2/xc/programs/Xserver/hw/darwin/quartz/xpr/Xplugin.h
	cd $(BUILD_WORK)/tigervnc/unix/xserver && patch -p1 < $(BUILD_WORK)/tigervnc/unix/xserver$(XORG_VERSION).patch && export ACLOCAL='aclocal -I $(BUILD_BASE)/usr/share/aclocal' && export gcc=cc && autoreconf -fiv && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var \
		--with-pic \
		--without-dtrace \
		--disable-static \
		--disable-dri \
		--enable-xinerama \
		--disable-xvfb \
		--disable-xnest \
		--disable-xorg \
		--disable-dmx \
		--disable-xwin \
		--disable-xephyr \
		--disable-xquartz \
		--disable-kdrive \
		--disable-config-dbus \
		--disable-config-hal \
		--disable-config-udev \
		--disable-dri2 \
		--enable-install-libxf86config \
		--enable-glx \
		--with-default-font-path="catalogue:/etc/X11/fontpath.d,built-ins" \
		--with-fontdir=/usr/share/X11/fonts \
		--with-xkb-path=/usr/share/X11/xkb \
		--with-xkb-output=/var/lib/xkb \
		--with-xkb-bin-directory=/usr/bin \
		--with-serverconfig-path=/usr/lib/xorg \
		--with-dri-driver-path=/usr/lib/dri
	cd $(BUILD_WORK)/tigervnc/unix/xserver && $(MAKE) TIGERVNC_SRCDIR=$(BUILD_WORK)/tigervnc
	+$(MAKE) -C $(BUILD_WORK)/tigervnc/unix/xserver install \
		DESTDIR=$(BUILD_STAGE)/tigervnc
	touch $(BUILD_WORK)/tigervnc/.build_complete
endif

tigervnc-package: tigervnc-stage
# tigervnc.mk Package Structure
	rm -rf $(BUILD_DIST)/tigervnc
	mkdir -p $(BUILD_DIST)/tigervnc-standalone-server/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	mkdir -p $(BUILD_DIST)/tigervnc-common/$(MEMO_PREFIX)/etc
	mkdir -p $(BUILD_DIST)/tigervnc-standalone-server/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{libexec,bin}
	
# tigervnc.mk Prep tigervnc-standalone-server
	rm -rf $(BUILD_STAGE)/tigervnc/usr/lib/xorg/protocol.txt
	rm -rf $(BUILD_STAGE)/tigervnc/usr/share/man/man1/Xserver.1
	cp -a $(BUILD_STAGE)/tigervnc/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/Xvnc $(BUILD_DIST)/tigervnc-standalone-server/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin

# tigervnc.mk Prep tigervnc-common
	cp -a $(BUILD_STAGE)/tigervnc/$(MEMO_PREFIX)/etc $(BUILD_DIST)/tigervnc-common$(MEMO_PREFIX)/etc

# tigervnc.mk Prep tigervnc-xorg-extension
	cp -a $(BUILD_STAGE)/tigervnc/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/xorg/modules/extensions/libvnc.so $(BUILD_DIST)/tigervnc-xorg-extension

# tigervnc.mk Prep tigervnc-standalone-server
	cp -a $(BUILD_STAGE)/tigervnc/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/{vncconfig,vncpasswd,x0vncserver} $(BUILD_DIST)tigervnc-standalone-server/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/
	cp -a $(BUILD_STAGE)/tigervnc/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/libexec $(BUILD_DIST)tigervnc-standalone-server/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/libexec

# tigervnc.mk Sign
	$(call SIGN,tigervnc-standalone-server,general.xml)
	$(call SIGN,tigervnc-xorg-extension,general.xml)
	$(call SIGN,tigervnc-standalone-server,general.xml)
	
# tigervnc.mk Make .debs
	$(call PACK,tigervnc-standalone-server,DEB_TIGERVNC_V)
	$(call PACK,tigervnc-xorg-extension,DEB_TIGERVNC_V)
	$(call PACK,tigervnc-standalone-server,DEB_TIGERVNC_V)
	$(call PACK,tigervnc-common,DEB_TIGERVNC_V)
	
# tigervnc.mk Build cleanup
	rm -rf $(BUILD_DIST)/tigervnc

.PHONY: tigervnc tigervnc-package