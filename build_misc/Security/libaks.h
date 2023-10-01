#ifndef LIBAKS_H
#define LIBAKS_H

#include <TargetConditionals.h>
#include <stdint.h>
#include <mach/mach.h>
#include <mach/error.h>
#include <IOKit/IOReturn.h>

#define kAKSReturnSuccess	KERN_SUCCESS
#define kAKSReturnError		kIOReturnError
#define kAKSReturnBadArgument 	kIOReturnBadArgument
#define kAKSReturnNoPermission	kIOReturnNotPermitted
#define kAKSReturnBusy		kIOReturnBusy

#define kAKSAssertTypeOther 			0
#define kAppleKeyStoreAsymmetricBackupBag 	4

#define bad_keybag_handle 	-1
#define device_keybag_handle 	0
#define session_keybag_handle 	0
#define key_class_last 		0x1f

enum keybag_state {
    keybag_state_unlocked = 0,
    keybag_state_locked = 1 << 0,
    keybag_state_no_pin = 1 << 1,
    keybag_state_been_unlocked = 1 << 2,
};

typedef int32_t AKSAssertionType_t;
typedef int32_t keybag_handle_t;
typedef int keyclass_t;
typedef int aks_system_key_type_t;
typedef int aks_system_key_operation_t;
typedef int aks_system_key_generation_t;
typedef int aks_key_type_t;
typedef int keybag_type_t;
typedef uint32_t keybag_state_t;
typedef int generation_option_t;
typedef void** aks_params_t;
typedef void* aks_ref_key_t;
/* this is a struct */
typedef void aks_device_state_s;
struct backup_keypair;

typedef enum {
	aks_params_key_access_groups = 1,
	aks_params_key_external_data = 2,
	aks_params_key_acm_handle = 3,
	aks_params_key_salt = 4,
	aks_params_key_data = 5,
	aks_params_key_ecdh_seed = 6,
	aks_params_key_ecdh_iv = 7,
	aks_params_key_raw_output = 8,
	aks_params_key_options = 9,
	aks_params_key_shared_info = 10,
	aks_params_key_shared_info2 = 11,
	aks_params_key_transcode_shared_info = 12,
	aks_params_key_transcode_shared_info2 = 13,
	aks_params_key_transcode_ecdh_seed = 14,
	aks_params_key_persona_uuid = 15,
	aks_params_key_type = 16,
	aks_params_key_client_seed = 17,
	aks_params_key_system_key_options = 18,
	aks_params_key_system_key_no_img4 = 19,
	aks_params_key_remote_session_signing_key_type = 20,
	aks_params_key_remote_session_signing_key_certificate = 21,
	aks_params_key_gid_ref_key_options = 22,
	aks_params_key_pka_flags = 23,
	aks_params_key_volume_uuid = 24,
	aks_params_key_seed = 25,
	aks_params_key_test_flags = 26
} aks_params_key_t;

__BEGIN_DECLS

kern_return_t
aks_load_bag(const void * data, int length, keybag_handle_t* handle);

kern_return_t
aks_create_bag(const void * passcode, int length, keybag_type_t type, keybag_handle_t* handle);

kern_return_t
aks_unload_bag(keybag_handle_t handle);

kern_return_t
aks_invalidate_bag(const void *data, int length);

kern_return_t
aks_save_bag(keybag_handle_t handle, void ** data, int * length);

kern_return_t
aks_get_system(keybag_handle_t special_handle, keybag_handle_t *handle);

kern_return_t
aks_get_bag_uuid(keybag_handle_t handle, uuid_t uuid);

kern_return_t
aks_kc_backup_get_uuid(keybag_handle_t handle, uuid_t uuid);

kern_return_t aks_lock_bag(keybag_handle_t handle);

kern_return_t aks_unlock_bag(keybag_handle_t handle, const void *passcode, int length);

kern_return_t aks_get_lock_state(keybag_handle_t handle, keybag_state_t *state);

kern_return_t
aks_wrap_key(const void * key, int key_size, keyclass_t key_class, keybag_handle_t handle, void * wrapped_key, int * wrapped_key_size_inout, keyclass_t * class_out);

kern_return_t
aks_kc_backup_wrap_key(keybag_handle_t keybag_handle, const uint8_t *key, size_t key_size, uint8_t *wrapped_key, size_t *wrapped_key_size);

kern_return_t aks_kc_backup_open_keybag(const uint8_t *backup_bag_data, size_t backup_bag_len,
                                        const uint8_t *backup_secret_data, size_t backup_secret_len,
                                        keybag_handle_t *backup_handle, struct backup_keypair *keypair);

kern_return_t aks_kc_backup_unwrap_key(const struct backup_keypair *backup_key, const uint8_t *wrapped_key, size_t wrapped_key_size, uint8_t *key, size_t *key_size);

kern_return_t
aks_unwrap_key(const void * wrapped_key, int wrapped_key_size, keyclass_t key_class, keybag_handle_t handle, void * key, int * key_size_inout);

int
aks_ref_key_create(keybag_handle_t handle, keyclass_t key_class, aks_key_type_t type, const uint8_t *params, size_t params_len, aks_ref_key_t *ot);

int
aks_ref_key_encrypt(aks_ref_key_t handle,
                    const uint8_t *der_params, size_t der_params_len,
                    const void * data, size_t data_len,
                    void ** out_der, size_t * out_der_len);

int
aks_ref_key_create_and_encrypt(keybag_handle_t handle, keyclass_t key_class, aks_key_type_t type, const uint8_t *params, size_t params_len, const void *data, size_t data_len, aks_ref_key_t *ot, void **out_der, size_t *out_der_len);

int
aks_ref_key_decrypt(aks_ref_key_t handle,
                    const uint8_t *der_params, size_t der_params_len,
                    const void * data, size_t data_len,
                    void ** out_der, size_t * out_der_len);

int aks_ref_key_wrap(aks_ref_key_t handle,
                     uint8_t *der_params, size_t der_params_len,
                     const uint8_t *key, size_t key_len,
                     void **out_der, size_t *out_der_len);

int aks_ref_key_unwrap(aks_ref_key_t handle,
                       uint8_t *der_params, size_t der_params_len,
                       const uint8_t *wrapped, size_t wrapped_len,
                       void **out_der, size_t *out_der_len);

int
aks_ref_key_delete(aks_ref_key_t handle, const uint8_t *der_params, size_t der_params_len);

const uint8_t *
aks_ref_key_get_public_key(aks_ref_key_t handle, size_t *pub_key_len);

int
aks_operation_optional_params(const uint8_t * access_groups, size_t access_groups_len, const uint8_t * external_data, size_t external_data_len, const void * acm_handle, int acm_handle_len, void ** out_der, size_t * out_der_len);

int aks_ref_key_create_with_blob(keybag_handle_t keybag, const uint8_t *ref_key_blob, size_t ref_key_blob_len, aks_ref_key_t* handle);

const uint8_t * aks_ref_key_get_blob(aks_ref_key_t refkey, size_t *out_blob_len);

int
aks_ref_key_free(aks_ref_key_t* refkey);

const uint8_t *
aks_ref_key_get_external_data(aks_ref_key_t refkey, size_t *out_external_data_len);

kern_return_t
aks_assert_hold(keybag_handle_t handle, uint32_t type, uint64_t timeout);

kern_return_t
aks_assert_drop(keybag_handle_t handle, uint32_t type);

kern_return_t
aks_generation(keybag_handle_t handle,
               generation_option_t generation_option,
               uint32_t * current_generation);

kern_return_t
aks_get_device_state(keybag_handle_t handle, aks_device_state_s *device_state);

int
aks_system_key_get_public(aks_system_key_type_t type, aks_system_key_generation_t generation, const uint8_t *der_params, size_t der_params_len, uint8_t **pub_out, size_t *pub_len_out);

int
aks_system_key_operate(aks_system_key_type_t type, aks_system_key_operation_t operation, const uint8_t *der_params, size_t der_params_len);

int
aks_system_key_collection(aks_system_key_type_t type, aks_system_key_generation_t generation, const uint8_t *der_params, size_t der_params_len, uint8_t **out_der, size_t *out_der_len);

int
aks_system_key_attest(aks_system_key_type_t type, aks_system_key_generation_t generation, aks_ref_key_t ref_key, const uint8_t *der_params, size_t der_params_len, uint8_t **out_der, size_t *out_der_len);

int
aks_gid_attest(aks_ref_key_t handle, uint8_t *der_params, size_t der_params_len, void **out_der, size_t *out_der_len);

int
aks_sik_attest(aks_ref_key_t handle, uint8_t *der_params, size_t der_params_len, void **out_der, size_t *out_der_len);

int
aks_ref_key_compute_key(aks_ref_key_t handle, uint8_t *der_params, size_t der_params_len, const uint8_t *pub_key, size_t pub_key_len, void **out_der, size_t *out_der_len);

int
aks_ref_key_attest(aks_ref_key_t handle, uint8_t *der_params, size_t der_params_len, aks_ref_key_t handle2, void **out_der, size_t *out_der_len);

int
aks_ref_key_sign(aks_ref_key_t handle, uint8_t *der_params, size_t der_params_len, const uint8_t *digest, size_t digest_len, void **out_der, size_t *out_der_len);

int
aks_ref_key_ecies_transcode(aks_ref_key_t handle, uint8_t *der_params, size_t der_params_len, const uint8_t *public_key, size_t public_key_len, const uint8_t *cipher_txt_in, size_t cipher_txt_in_len, uint8_t **cipher_txt_out, size_t *cipher_txt_out_len);

keyclass_t
aks_ref_key_get_key_class(aks_ref_key_t handle);

aks_key_type_t
aks_ref_key_get_type(aks_ref_key_t handle);

aks_params_t aks_params_create(const uint8_t *der_params, size_t der_params_len);

int aks_params_free(aks_params_t *params);

int
aks_params_set_data(aks_params_t params, aks_params_key_t key, const void *value, size_t length);

int
aks_params_get_der(aks_params_t params, uint8_t **out_der, size_t *out_der_len);

int
aks_params_set_number(aks_params_t params, aks_params_key_t key, int64_t *num);

int
aks_ref_key_enable_test_keys(keybag_handle_t handle, const uint8_t *passcode, size_t passcode_len);

void
aks_dealloc(void *ptr, size_t size);
__END_DECLS

#endif /* LIBAKS_H */
