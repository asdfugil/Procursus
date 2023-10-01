ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += security
SECURITY_VERSION := 61040.1.3
DEB_SECURITY_V   ?= $(SECURITY_VERSION)

COMMONCRYPTO_WITH_LIBDER_VERSION := 60027

ifeq ($(shell [ "$(CFVER_WHOLE)" -lt 1900 ] && echo 1),1)
SECURITY_LDFLAGS := $(BUILD_MISC)/security/stubs.c
else
SECURITY_LDFLAGS := -framework AppleKeyStore
endif

security-setup: setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,Security,$(SECURITY_VERSION),Security-$(SECURITY_VERSION))
	$(call GITHUB_ARCHIVE,apple-oss-distributions,CommonCrypto,$(COMMONCRYPTO_WITH_LIBDER_VERSION),CommonCrypto-$(COMMONCRYPTO_WITH_LIBDER_VERSION))
	$(call EXTRACT_TAR,Security-$(SECURITY_VERSION).tar.gz,Security-Security-$(SECURITY_VERSION),security)
	$(call EXTRACT_TAR,CommonCrypto-$(COMMONCRYPTO_WITH_LIBDER_VERSION).tar.gz,CommonCrypto-CommonCrypto-$(COMMONCRYPTO_WITH_LIBDER_VERSION),security/CommonCrypto)
	sed -i '/command unavailable/d' $(BUILD_WORK)/Security/SecurityTool/sharedTool/SecurityTool.c
	sed -i 's/#include "security\.h"/#include <Security\/Security.h>/' $(BUILD_WORK)/Security/SecurityTool/sharedTool/{keychain_add,show_certificates,keychain_util}.c
	sed -i 's/#import <SecurityFoundation\/SFKeychain\.h>/#include <SecurityFoundation\/SecurityFoundation\.h>/' $(BUILD_WORK)/Security/SecurityTool/sharedTool/keychain_find.m
	sed -i 's|#import <Foundation/NSXPCConnection_Private\.h>|#import <Foundation/NSXPCConnection.h>|' $(BUILD_WORK)/Security/{SecurityTool/sharedTool/{sos,KeychainCheck}.m,keychain/SecureObjectSync/SOSCloudCircle.m}
	sed -i 's|#import <CloudKit/CKContainer_Private\.h>|#import <CloudKit/CKContainer.h>|' $(BUILD_WORK)/Security/SecurityTool/sharedTool/policy_dryrun.m
	sed -i '/#import <SoftLinking\/SoftLinking\.h>/d'  $(BUILD_WORK)/Security/OSX/utilities/simulate_crash.m
	sed -i '/context\.force = true;/d' $(BUILD_WORK)/Security/keychain/SecureObjectSync/Tool/recovery_key.m
	sed -i '/#import "NSFileHandle+Formatting\.h"/d'  $(BUILD_WORK)/Security/{SecurityTool/sharedTool/NSFileHandle+Formatting.m,keychain/SecureObjectSync/Tool/keychain_sync_test.m}
	sed -i 's/#include <MobileGestalt\.h>//' $(BUILD_WORK)/Security/keychain/ot/OTConstants.m
	sed -i '/#import <AppleFeatures\/AppleFeatures\.h>/d' $(BUILD_WORK)/Security/keychain/ot/OTConstants.h
	sed -i 's/\^(xpc_object_t/^bool(xpc_object_t/' $(BUILD_WORK)/Security/keychain/SecureObjectSync/SOSCloudCircle.m
	sed -i --follow-symlinks -e 's/, bridgeos([0-9]*\.[0-9]*)//g' -e 's/, bridgeos(NA)//g' -e 's/API_UNAVAILABLE(bridgeos)//g' -e 's/bridgeos,//g' $$(find $(BUILD_WORK)/Security/header_symlinks -name '*.h' -type l)
	mkdir -p $(BUILD_STAGE)/security/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{bin,share/man/man1}

ifneq ($(wildcard $(BUILD_WORK)/security/.build_complete),)
security:
	@echo "Using previously built security."
else
security: security-setup
	mkdir -p $(BUILD_STAGE)/security/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{bin,share/man/man1/}
	cd $(BUILD_WORK)/Security/CommonCrypto/Source/libDER; \
		$(CC) $(CFLAGS) -c libDER/*.c libDERUtils/*.c -IlibDER; \
		$(AR) cru libDER.a *.o
	cd $(BUILD_WORK)/Security; \
	$(CC) $(CFLAGS) $(LDFLAGS) -I. -IOSX -IOSX/utilities -IOSX/sec -Iheader_symlinks{,/iOS} -ICommonCrypto/Source/libDER -IOSX/sec/Security -ICommonCrypto/include/Private -D'soft_WriteStackshotReport(...)=' \
		-Iheader_symlinks/Security -Iheader_symlinks/Security/SecureObjectSync -D'SOFT_LINK_OPTIONAL_FRAMEWORK(...)=' -D'SOFT_LINK_FUNCTION(...)=' -D'isCrashReporterSupportAvailable()=0'\
		-DTARGET_OS_BRIDGE=0 -D__ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES -D__OS_EXPOSE_INTERNALS__ -DPRIVATE -DTPPBPeerStableInfoUserControllableViewStatus_UNKNOWN=0 -D'soft_SimulateCrash(...)='\
		-D'CC_NONNULL_TU(x)=' -D'CC_NONNULL2=' -D'CC_NONNULL3=' -D'CC_NONNULL4=' -D'CC_NONNULL5=' -framework LocalAuthentication -framework CFNetwork -framework CloudKit -framework CoreCDP \
		CommonCrypto/Source/libDER/libDER.a -F$(BUILD_MISC)/PrivateFrameworks -framework Security -framework CoreFoundation -framework Foundation -framework TrustedPeers $(SECURITY_LDFLAGS)  -lobjc \
		SecurityTool/sharedTool/{*.c,*.m} OSX/utilities/{debugging.c,SecCFWrappers.c,simulate_crash.m,SecAKSWrappers.c,fileIo.c,SecBuffer.c,SecCFError.c} keychain/SecureObjectSync/Tool/{*.m,*.c} \
		-dead_strip keychain/ot/OTConstants.m keychain/SecureObjectSync/{SOSUserKeygen,SOSCloudCircle}.m OSX/sec/Security/SecuritydXPC.c -o $(BUILD_STAGE)/security/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/security;
	$(INSTALL) -m644 $(BUILD_WORK)/Security/SecurityTool/sharedTool/iOS/security.1 $(BUILD_STAGE)/security/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man1
	$(call AFTER_BUILD)
endif

security-package: security-stage
	# security.mk Package Structure
	rm -rf $(BUILD_DIST)/security

	# security.mk Prep security
	cp -a $(BUILD_STAGE)/security $(BUILD_DIST)

	# security.mk Sign
	$(call SIGN,security,security.xml)

	# security.mk Make .debs
	$(call PACK,security,DEB_SECURITY_V)

	# security.mk Build cleanup
	rm -rf $(BUILD_DIST)/security

.PHONY: security security-package
