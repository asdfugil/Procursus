#ifndef MOBILEKEYBAG_MOBILEKEYBAG_H
#define MOBILEKEYBAG_MOBILEKEYBAG_H

#include <stdint.h>
#include <CoreFoundation/CoreFoundation.h>

#define kMobileKeyBagLockStatusNotificationID "com.apple.keystore.lockstatus"
#define getkMKBDeviceModeKey() kMKBDeviceModeKey
#define getkMKBDeviceModeSharedIPad() kMKBDeviceModeSharedIPad

typedef void* MKBKeyBagHandleRef;

int MKBKeyBagUnlock(MKBKeyBagHandleRef keybag, CFDataRef _Nullable passcode);
int MKBKeyBagGetAKSHandle(MKBKeyBagHandleRef _Nonnull keybag, int32_t *_Nullable handle);
int MKBGetDeviceLockState(CFDictionaryRef _Nullable options);
CF_RETURNS_RETAINED CFDictionaryRef _Nullable MKBUserTypeDeviceMode(CFDictionaryRef _Nullable options, CFErrorRef _Nullable * _Nullable error);
int MKBForegroundUserSessionID( CFErrorRef _Nullable * _Nullable error);

extern CFTypeRef kMKBDeviceModeKey;
extern CFTypeRef kMKBDeviceModeSharedIPad;

#endif
