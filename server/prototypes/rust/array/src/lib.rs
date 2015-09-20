extern crate libc;

use libc::{c_char, uint16_t, uint64_t, size_t};
use std::{mem, str};
use std::ffi::CStr;

macro_rules! dereflegate {
    ($pointer_type:ident, $from:ident, $to:ident, $ret:ident) => {
        #[no_mangle] pub extern
        // concat_idents! does not work here.
        fn $from(ptr: *const $pointer_type) -> $ret {
            let data = unsafe {
                assert!(!ptr.is_null());
                &*ptr
            };
            *data.$to()
        }
    };
}
macro_rules! delegate {
    ($pointer_type:ident, $from:ident, $to:ident, $ret:ident) => {
        #[no_mangle] pub extern
        // concat_idents! does not work here.
        fn $from(ptr: *const $pointer_type) -> $ret {
            let data = unsafe {
                assert!(!ptr.is_null());
                &*ptr
            };
            data.$to()
        }
    };
}

// Load the pure Rust array.
pub mod arrays;
use arrays::Array;

#[no_mangle] pub extern
fn rust_array_new() -> *mut Array {
    unsafe {
        mem::transmute(Box::new(Array::new()))
    }
}

#[no_mangle] pub extern
fn rust_array_free(ptr: *mut Array) {
    if ptr.is_null() { return }
    let _: Box<Array> = unsafe {
        mem::transmute(ptr)
    };
}

#[no_mangle] pub extern
fn rust_array_append(ptr: *mut Array, item: uint16_t) -> uint16_t {
    let data = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    data.append(item)
}

#[no_mangle] pub extern
fn rust_array_length(ptr: *const Array) -> size_t {
    let data = unsafe {
        assert!(!ptr.is_null());
        &*ptr
    };
    data.length() as size_t
}

// TODO Make it first/last/... only.
dereflegate!(Array, rust_array_first, first, uint16_t);
dereflegate!(Array, rust_array_last, last, uint16_t);
// delegate!(Array, rust_array_length, length, size_t);

// Load the pure Rust Hash.
mod hashes;
use hashes::Hash;

#[no_mangle] pub extern
fn rust_hash_new() -> *mut Hash {
    unsafe {
        mem::transmute(Box::new(Hash::new()))
    }
}

#[no_mangle] pub extern
fn rust_hash_free(ptr: *mut Hash) {
    if ptr.is_null() { return }
    let _: Box<Hash> = unsafe {
        mem::transmute(ptr)
    };
}

#[no_mangle] pub extern
fn rust_hash_set(ptr: *mut Hash, key: *const c_char, value: *const Array) -> *const Array {
    let hash = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    let transformed_key = unsafe {
        assert!(!key.is_null());
        CStr::from_ptr(key)
    };
    let value: Box<Array> = unsafe {
        assert!(!value.is_null());
        // &*value
        mem::transmute(value)
    };
    
    let key_str = str::from_utf8(transformed_key.to_bytes()).unwrap();
    hash.set(key_str, value);
    
    rust_hash_get(ptr, key)
}

#[no_mangle] pub extern
fn rust_hash_get(ptr: *const Hash, key: *const c_char) -> *const Array {
    let hash = unsafe {
        assert!(!ptr.is_null());
        &*ptr
    };
    let key = unsafe {
        assert!(!key.is_null());
        CStr::from_ptr(key)
    };
    let key_str = str::from_utf8(key.to_bytes()).unwrap();
    match hash.get(key_str) {
        Some(value) => unsafe {
            mem::transmute(value)
        },
        None => std::ptr::null() // TODO Automatic default!
    }
}

#[no_mangle] pub extern
fn rust_hash_length(ptr: *const Hash) -> size_t {
    let data = unsafe {
        assert!(!ptr.is_null());
        &*ptr
    };
    data.length() as size_t
}

// delegate!(Hash, rust_hash_length, length, size_t);