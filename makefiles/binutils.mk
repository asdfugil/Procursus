fneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += binutils
BINUTILS_VERSION := 2.36.1
DEB_BINUTILS_V   ?= $(BINUTILS_VERSION)

BINUTILS_TARGETS := aarch64-linux-gnu aarch64-linux-musl alpha-linux-gnu alpha-linux-musl arm-linux-gnueabi arm-linux-gnueabihf arm-linux-musl i686-kfreebsd-gnu i686-linux-gnu i686-linux-musl ia64-linux-gnu ia64-linux-musl m68k-linux-gnu m68k-linux-musl mips64el-linux-gnuabi64 mips64el-linux-musl mipsel-linux-gnu mipsel-linux-musl powerpc-linux-gnu powerpc-linux-musl powerpc64-linux-gnu powerpc64-linux-musl powerpc64le-linux-gnu powerpc64le-linux-musl riscv64-linux-gnu riscv64-linux-musl s390x-linux-gnu s390x-linux-musl sh4-linux-gnu sh4-linux-musl sparc64-linux-gnu sparc64-linux-musl x86_64-linux-gnu x86_64-linux-musl powerpc-apple-darwin x86_64-apple-darwin i686-apple-darwin arm-apple-darwin aarch64-apple-darwin i686-hurd-gnu

BINUTILS_CONFARGS := --enable-obsolete \
	--enable-shared \
	--enable-plugins \
	--enable-threads \
	--with-system-zlib \
	--enable-deterministic-archives \
	--disable-compressed-debug-sections \
	--enable-new-dtags \
	--disable-x86-used-note \
	--with-pkgversion="GNU Binutils for Procursus" \
	--enable-ld=default \
	--enable-gold \
	--enable-default-hash-style=gnu

binutils-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://ftpmirror.gnu.org/binutils/binutils-$(BINUTILS_VERSION).tar.xz{,.sig}
	$(call PGP_VERIFY,binutils-$(BINUTILS_VERSION).tar.xz)
	$(call EXTRACT_TAR,binutils-$(BINUTILS_VERSION).tar.xz,binutils-$(BINUTILS_VERSION),binutils)
	$(call DO_PATCH,binutils,binutils,-p1)

ifneq ($(wildcard $(BUILD_WORK)/binutils/.build_complete),)
binutils:
	@echo "Using previously built binutils."
else
binutils: binutils-setup $(patsubst %,%-binutils-target,$(BINUTILS_TARGETS))
	touch $(BUILD_WORK)/binutils/.build_complete
endif

%-binutils-target: binutils-setup gettext
	target=$$(echo $@ | rev | cut -d- -f3- | rev); \
	if [ "$$GNU_HOST_TRIPLE" = "$$target" ]; then \
		binutils_extra_flags=--program-prefix=g; \
	fi; \
	if [ -f $(BUILD_WORK)/binutils/$$target/.build_complete ]; then \
		echo "Using previously built $$target binutils"; \
	else \
		mkdir -p $(BUILD_WORK)/binutils/$$target; \
		cd $(BUILD_WORK)/binutils/$$target && ../configure -C \
			--build=$$($(BUILD_MISC)/config.guess) \
			--host=$(GNU_HOST_TRIPLE) \
			--prefix=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX) \
			--libdir=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/$(GNU_HOST_TRIPLE)/$$target/lib \
			--includedir=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/$(GNU_HOST_TRIPLE)/$$target/include \
			--target=$$target \
			$(BINUTILS_CONFARGS) $$binutils_extra_flags; \
		$(MAKE) -C $(BUILD_WORK)/binutils/$$target; \
		$(MAKE) -C $(BUILD_WORK)/binutils/$$target install \
			DESTDIR=$(BUILD_STAGE)/binutils/$$target; \
		touch $(BUILD_WORK)/binutils/$$target/.build_complete; \
	fi

binutils-package: binutils-stage
	# binutils.mk Package Structure
	for target in $(BINUTILS_TARGETS); do \
		rm -rf $(BUILD_DIST)/binutils-$$target; \
		rm -rf $(BUILD_INFO)/binutils-$$($(SED) 's/_/-/g' <<< "$$target").control; \
	done
	rm -rf $(BUILD_DIST)/binutils{,-common}
	mkdir -p $(BUILD_DIST)/binutils
	mkdir -p $(BUILD_DIST)/binutils-common/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)
	
	#  binutils.mk Prep binutils-*
	for target in $(BINUTILS_TARGETS); do \
		cp -r $(BUILD_STAGE)/binutils/$$target $(BUILD_DIST)/binutils-$$($(SED) -e 's/_/-/g' <<< "$$target"); \
		$(SED) -e "s/@TARGET@/$$($(SED) -e 's/_/-/g' <<< "$$target")/g" $(BUILD_INFO)/binutils.control.in > $(BUILD_INFO)/binutils-$$($(SED) -e 's/_/-/g' <<< "$$target").control; \
	done
	for target in $(BINUTILS_TARGETS); do \
		for pkg in $(BUILD_DIST)/binutils-$$target; do \
			for man in $$pkg/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man1/*; do \
				$(LN) -sf binutils-$$(basename $$man .1 | rev | cut -d- -f1 | rev ).1.zst $$man; \
			done; \
			rm -rf $$pkg/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/{locale,info}; \
		done; \
	done
	cp -r $(BUILD_STAGE)/binutils/x86_64-linux-gnu/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share $(BUILD_DIST)/binutils-common/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)
	for man in $(BUILD_DIST)/binutils-common/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man1/*; do \
		mv $$man $(BUILD_DIST)/binutils-common/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man1/binutils-$$(basename $$man .1 | rev | cut -d- -f1 | rev ).1; \
	done
	# binutils.mk Prep binutils
	# No architecure-specific control mechanism in PACK, sorry.
	$(SED) -e "s/@TARGET@/$$($(SED) -e 's/_/-/g' <<< "$(GNU_HOST_TRIPLE)")/g" $(BUILD_INFO)/binutils-native.control.in > $(BUILD_INFO)/binutils.control
	
	# binutils.mk Sign
	for target in $(BINUTILS_TARGETS); do \
		$(call SIGN,binutils-$$target,general.xml);\
	done
	
	# Make control files with:
	# sed "s/@TARGET@/$(sed 's/_/-/g' <<< "$target")/g" binutils.control.in > binutils-$target.control
	
	# binutils.mk Make .debs
	-for target in $(BINUTILS_TARGETS); do \
		$(patsubst -if,if,$(call PACK,binutils-$$($(SED) -e 's/_/-/g' <<< "$$target"),DEB_BINUTILS_V)); \
	done
	$(call PACK,binutils,DEB_BINUTILS_V)
	$(call PACK,binutils-common,DEB_BINUTILS_V)
	
	# binutils.mk Build cleanup
	for target in $(BINUTILS_TARGETS); do \
		rm -rf $(BUILD_DIST)/binutils-$$target; \
		rm $(BUILD_INFO)/binutils-$$($(SED) 's/_/-/g' <<< "$$target").control; \
	done
	rm -rf $(BUILD_DIST)/binutils{,-common}
	rm $(BUILD_INFO)/binutils.control

.PHONY: binutils binutils-package