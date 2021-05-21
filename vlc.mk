ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS += vlc
VLC_VERSION := 3.0.14
DEB_VLC_V   ?= $(VLC_VERSION)

vlc-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download.videolan.org/vlc/$(VLC_VERSION)/vlc-$(VLC_VERSION).tar.xz
	$(call EXTRACT_TAR,vlc-$(VLC_VERSION).tar.xz,vlc-$(VLC_VERSION),vlc)
	#$(call DO_PATCH,vlc,vlc,-p1)

ifneq ($(wildcard $(BUILD_WORK)/vlc/.build_complete),)
vlc:
	@echo "Using previously built vlc."
else
vlc: aom dav1d ffmpeg fontconfig freetype frei0r gnutls lame libarchive libass libdvdcss libdvdnav libdvdread libsoxr libssh libvidstab libvorbis libvpx libopencore-amr openjpeg libopus libx11 libxft lua5.4 rav1e rtmpdump rubberband sdl2 libsnappy libspeex libsrt tesseract libtheora libwebp x264 x265 libxvidcore xz vlc-setup
	cd $(BUILD_WORK)/vlc && LDFLASS=-lCoreFoundation ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-qt \
		--disable-bluray \
		--disable-vcd \
		--disable-dbus \
		--enable-archive \
		--enable-dvdnav \
		--enable-dvdread \
		--enable-static \
		--enable-shared \
		--enable-sftp \
		--enable-run-as-root \
		--enable-x264 \
		--enable-x265 \
		--with-x \
		--with-libintl-prefix=$(BUILD_BASE) \
		--enable-neon \
		--disable-mmx \
		--disable-sse \
		--enable-arm64 \
		--disable-altivec \
		--disable-live555 \
		--disable-dc1394 \
		--disable-dv1394 \
		--disable-linsys \
		--disable-lua \
		--disable-opencv \
		--disable-smbclient \
		--disable-libcddb \
		--disable-vnc \
		--disable-tiger \
		--enable-kate \
		--enable-css \
		--enable-xcb \
		--enable-xvideo \
		--enable-freetype \
		--enable-fontconfig \
		--disable-svg \
		--disable-alsa \
		--disable-sndio \
		--disable-a52 \
		--disable-kate \
		--disable-macosx
	+$(MAKE) -C $(BUILD_WORK)/vlc
	+$(MAKE) -C $(BUILD_WORK)/vlc install \
		DESTDIR=$(BUILD_STAGE)/vlc
	touch $(BUILD_WORK)/vlc/.build_complete
endif

vlc-package: vlc-stage
	# vlc.mk Package Structure
	rm -rf $(BUILD_DIST)/vlc
	mkdir -p $(BUILD_DIST)/vlc
	
	# vlc.mk Prep vlc
	cp -a $(BUILD_STAGE)/vlc $(BUILD_DIST)
	
	# vlc.mk Sign
	$(call SIGN,vlc,general.xml)
	
	# vlc.mk Make .debs
	$(call PACK,vlc,DEB_VLC_V)
	
	# vlc.mk Build cleanup
	rm -rf $(BUILD_DIST)/vlc

.PHONY: vlc vlc-package