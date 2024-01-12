ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += security
SECURITY_VERSION := 61040.1.3
DEB_SECURITY_V   ?= $(SECURITY_VERSION)

COMMONCRYPTO_WITH_LIBDER_VERSION := 60027

ifeq ($(shell [ "$(CFVER_WHOLE)" -lt 1900 ] && echo 1),1)
SECURITY_LDFLAGS := $(BUILD_MISC)/security/stubs.c $(BUILD_MISC)/Security/libellekit.tbd
SECURITY_LDFLAGS += -rpath $(MEMO_PREFIX)/Library/Frameworks -rpath /cores/binpack/Library/Frameworks
SECURITY_LDFLAGS += -rpath $(MEMO_PREFIX)/basebin/fallback -rpath /binpack/Library/Frameworks
ifneq ($(MEMO_PREFIX),)
SECURITY_LDFLAGS += -rpath /Library/Frameworks
endif

else
SECURITY_LDFLAGS := -framework AppleKeyStore OSX/sec/ipc/client.c featureflags/featureflags.c
SECURITY_LDFLAGS += OSX/utilities/SecFileLocations.c
endif

security-setup: setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,Security,$(SECURITY_VERSION),Security-$(SECURITY_VERSION))
	$(call GITHUB_ARCHIVE,apple-oss-distributions,CommonCrypto,$(COMMONCRYPTO_WITH_LIBDER_VERSION),CommonCrypto-$(COMMONCRYPTO_WITH_LIBDER_VERSION))
	$(call EXTRACT_TAR,Security-$(SECURITY_VERSION).tar.gz,Security-Security-$(SECURITY_VERSION),security)
	$(call EXTRACT_TAR,CommonCrypto-$(COMMONCRYPTO_WITH_LIBDER_VERSION).tar.gz,CommonCrypto-CommonCrypto-$(COMMONCRYPTO_WITH_LIBDER_VERSION),security/CommonCrypto)
	sed -i '/command unavailable/d' $(BUILD_WORK)/security/SecurityTool/sharedTool/SecurityTool.c
	sed -i 's/#include "security\.h"/#include <Security\/Security.h>/' $(BUILD_WORK)/security/SecurityTool/sharedTool/{keychain_add,show_certificates,keychain_util}.c
	sed -i 's/#import <SecurityFoundation\/SFKeychain\.h>/#include <SecurityFoundation\/SecurityFoundation\.h>/' $(BUILD_WORK)/security/SecurityTool/sharedTool/keychain_find.m
	sed -i 's|#import <Foundation/NSXPCConnection_Private\.h>|#import <Foundation/NSXPCConnection.h>|' $(BUILD_WORK)/security/{SecurityTool/sharedTool/{sos,KeychainCheck}.m,keychain/SecureObjectSync/SOSCloudCircle.m}
	sed -i 's|#import <CloudKit/CKContainer_Private\.h>|#import <CloudKit/CKContainer.h>|' $(BUILD_WORK)/security/SecurityTool/sharedTool/policy_dryrun.m
	sed -i '/#\(import\|include\) <SoftLinking\/SoftLinking\.h>/d'  $(BUILD_WORK)/security/OSX/utilities/{simulate_crash.m,SecFileLocations.c}
	sed -i '/context\.force = true;/d' $(BUILD_WORK)/security/keychain/SecureObjectSync/Tool/recovery_key.m
	sed -i '/#import "NSFileHandle+Formatting\.h"/d'  $(BUILD_WORK)/security/{SecurityTool/sharedTool/NSFileHandle+Formatting.m,keychain/SecureObjectSync/Tool/keychain_sync_test.m}
	sed -i 's/#include <MobileGestalt\.h>//' $(BUILD_WORK)/security/keychain/ot/OTConstants.m
	sed -i 's|#include <security_utilities/debugging.h>|#include "$(BUILD_WORK)/security/OSX/utilities/debugging.h"|g' $(BUILD_WORK)/security/featureflags/featureflags.c
	sed -i '/#import <AppleFeatures\/AppleFeatures\.h>/d' $(BUILD_WORK)/security/keychain/ot/OTConstants.h
	sed -i 's/\^(xpc_object_t/^bool(xpc_object_t/' $(BUILD_WORK)/security/keychain/SecureObjectSync/SOSCloudCircle.m
	sed -i 's/extern const CFStringRef kCKKSViewPhotos/static const CFStringRef kCKKSViewPhotos = CFSTR("Photos")/g' $(BUILD_WORK)/security/keychain/SecureObjectSync/SOSCloudCircle.h
	sed -i 's/extern const CFStringRef kCKKSViewGroups/static const CFStringRef kCKKSViewGroups = CFSTR("Groups")/g' $(BUILD_WORK)/security/keychain/SecureObjectSync/SOSCloudCircle.h
	sed -i --follow-symlinks -e 's/, bridgeos([0-9]*\.[0-9]*)//g' -e 's/, bridgeos(NA)//g' -e 's/API_UNAVAILABLE(bridgeos)//g' -e 's/bridgeos,//g' $$(find $(BUILD_WORK)/security/header_symlinks -name '*.h' -type l)
	sed -i -e 's|@implementation SecSOSStatus|/*|g' -e 's|^SOSCCGetStatusObject|*/static id<SOSControlProtocol> SOSCCGetStatusObject|g' $(BUILD_WORK)/security/keychain/SecureObjectSync/SOSCloudCircle.m
	mkdir -p $(BUILD_STAGE)/security/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{bin,share/man/man1}

ifneq ($(wildcard $(BUILD_WORK)/security/.build_complete),)
security:
	@echo "Using previously built security."
else
security: security-setup
	mkdir -p $(BUILD_STAGE)/security/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{bin,share/man/man1/}
	cd $(BUILD_WORK)/security/CommonCrypto/Source/libDER; \
		$(CC) $(CFLAGS) -c libDER/*.c libDERUtils/*.c -IlibDER; \
		$(AR) cru libDER.a *.o
	cd $(BUILD_WORK)/security; \
	$(CC) $(CFLAGS) $(LDFLAGS) -I. -IOSX -IOSX/utilities -IOSX/sec -Iheader_symlinks{,/iOS} -ICommonCrypto/Source/libDER -IOSX/sec/Security -ICommonCrypto/include/Private -D'soft_WriteStackshotReport(...)=' \
		-Iheader_symlinks/Security -Iheader_symlinks/Security/SecureObjectSync -D'SOFT_LINK_OPTIONAL_FRAMEWORK(...)=' -D'SOFT_LINK_FUNCTION(...)=' -D'isCrashReporterSupportAvailable()=0'\
		-DTARGET_OS_BRIDGE=0 -D__ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES -D__OS_EXPOSE_INTERNALS__ -DPRIVATE -DTPPBPeerStableInfoUserControllableViewStatus_UNKNOWN=0 -D'soft_SimulateCrash(...)='\
		-D'CC_NONNULL_TU(x)=' -D'CC_NONNULL2=' -D'CC_NONNULL3=' -D'CC_NONNULL4=' -D'CC_NONNULL5=' -framework LocalAuthentication -framework CFNetwork -framework CloudKit -framework CoreCDP \
		CommonCrypto/Source/libDER/libDER.a -F$(BUILD_MISC)/PrivateFrameworks -framework Security -framework CoreFoundation -framework Foundation -framework TrustedPeers $(SECURITY_LDFLAGS)  -lobjc \
		SecurityTool/sharedTool/{*.c,*.m} OSX/utilities/{debugging.c,SecCFWrappers.c,simulate_crash.m,SecAKSWrappers.c,fileIo.c,SecBuffer.c,SecCFError.c} keychain/SecureObjectSync/Tool/{*.m,*.c} \
		-dead_strip keychain/ot/OTConstants.m keychain/SecureObjectSync/{SOSUserKeygen,SOSCloudCircle}.m OSX/sec/Security/SecuritydXPC.c -D'SOFT_LINK_CONSTANT(...)=' \
		-Dsoft_MKBUserTypeDeviceMode=MKBUserTypeDeviceMode -framework MobileKeyBag \
		-o $(BUILD_STAGE)/security/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/security;
	$(INSTALL) -m644 $(BUILD_WORK)/security/SecurityTool/sharedTool/iOS/security.1 $(BUILD_STAGE)/security/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man1
	$(call AFTER_BUILD)
endif

security-package: security-stage
	# security.mk Package Structure
	rm -rf $(BUILD_DIST)/security

	# security.mk Prep security
	cp -a $(BUILD_STAGE)/security $(BUILD_DIST)

	# security.mk Sign
	$(LDID) -Icom.apple.security -S$(BUILD_MISC)/entitlements/security.xml $(BUILD_DIST)/security/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/security

	# security.mk Make .debs
	$(call PACK,security,DEB_SECURITY_V)

	# security.mk Build cleanup
	rm -rf $(BUILD_DIST)/security

.PHONY: security security-package
