#include <CoreFoundation/CoreFoundation.h>
#include  <stdbool.h>
#include <libaks.h>
#include <stdlib.h>
#include <assert.h>
#include <mach/mach.h>

CFStringRef kCKKSViewMail 		= CFSTR("Mail");
CFStringRef kCKKSViewContacts 		= CFSTR("Contacts");
CFStringRef kCKKSViewGroups	 	= CFSTR("Groups");
CFStringRef kCKKSViewPhotos	 	= CFSTR("Photos");


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
	*handle = 17;
	return 0;
}

kern_return_t
aks_save_bag(keybag_handle_t handle, void ** data, int * length)
{
    assert(handle != bad_keybag_handle);
    assert(data);
    assert(length);

    *data = calloc(1, 19);
    memcpy(*data, "procursusabcd1234", 19);
    *length = 19;

    return kAKSReturnSuccess;
}

kern_return_t
aks_unload_bag(keybag_handle_t handle)
{
    return kAKSReturnSuccess;
}


