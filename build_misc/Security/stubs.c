#include <CoreFoundation/CoreFoundation.h>
#include <stdbool.h>
#include <libaks.h>
#include <stdlib.h>
#include <assert.h>
#include <mach/mach.h>
#include "substrate.h"

CFStringRef kCKKSViewMail 		= CFSTR("Mail");
CFStringRef kCKKSViewContacts 		= CFSTR("Contacts");
CFStringRef kCKKSViewGroups	 	= CFSTR("Groups");
CFStringRef kCKKSViewPhotos	 	= CFSTR("Photos");

kern_return_t
(*aks_create_bag_p)(const void * passcode, int length, keybag_type_t type, keybag_handle_t* handle);
kern_return_t
(*aks_save_bag_p)(keybag_handle_t handle, void ** data, int * length);
kern_return_t
(*aks_unload_bag_p)(keybag_handle_t handle);

bool _SecSystemKeychainTranscrypt(CFErrorRef *error)
{
	return false;
}

OSStatus
_SecKeychainForceUpgradeIfNeeded(void)
{
	return 0;
}

kern_return_t
aks_create_bag(const void * passcode, int length, keybag_type_t type, keybag_handle_t* handle)
{
     if (aks_create_bag_p) return aks_create_bag_p(passcode, length, type, handle);
     return kAKSReturnError;
}

kern_return_t
aks_save_bag(keybag_handle_t handle, void ** data, int * length)
{
    if (aks_save_bag_p) return aks_save_bag_p(handle, data, length);
    return kAKSReturnError;
}

kern_return_t
aks_unload_bag(keybag_handle_t handle)
{
    if (aks_unload_bag_p) return aks_unload_bag_p(handle);
    return kAKSReturnError;
}

__attribute__((constructor)) void init_aks(void) {
    MSImageRef mobileKeyBagImage = MSGetImageByName("/System/Library/PrivateFrameworks/MobileKeyBag.framework/MobileKeyBag");
    if (!mobileKeyBagImage) return;
    aks_create_bag_p = MSFindSymbol(mobileKeyBagImage, "_aks_create_bag");
    aks_save_bag_p = MSFindSymbol(mobileKeyBagImage, "_aks_save_bag");
    aks_unload_bag_p = MSFindSymbol(mobileKeyBagImage, "_aks_unload_bag");
}
