extern crate libc;

use libc::{c_char, uint16_t, uint32_t};
use std::{mem, str};
use std::ffi::CStr;

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

macro_rules! delegate {
    ($from:ident, $to:ident) => {
        #[no_mangle] pub extern
        // concat_idents! does not work here.
        fn $from(ptr: *const Array) -> uint16_t {
            let data = unsafe {
                assert!(!ptr.is_null());
                &*ptr
            };
            *data.$to()
        }
    };
}

// TODO Make it first/last only.
delegate!(rust_array_first, first);
delegate!(rust_array_last, last);

// Load the pure Rust Hash.
mod hashes;

#[no_mangle] pub extern
fn rust_hash_new() -> *mut hashes::Hash {
    unsafe {
        mem::transmute(Box::new(hashes::Hash::new()))
    }
}

#[no_mangle] pub extern
fn rust_hash_free(ptr: *mut hashes::Hash) {
    if ptr.is_null() { return }
    let _: Box<hashes::Hash> = unsafe {
        mem::transmute(ptr)
    };
}

#[no_mangle] pub extern
fn rust_hash_set(ptr: *mut hashes::Hash, key: *const c_char, value: Array)  {
    let hash = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    let key = unsafe {
        assert!(!key.is_null());
        CStr::from_ptr(key)
    };
    let key_str = str::from_utf8(key.to_bytes()).unwrap();
    hash.set(key_str, value);
}

#[no_mangle] pub extern
fn rust_hash_get<'a>(ptr: *const hashes::Hash, key: *const c_char) {
    let hash = unsafe {
        assert!(!ptr.is_null());
        &*ptr
    };
    let key = unsafe {
        assert!(!key.is_null());
        CStr::from_ptr(key)
    };
    let key_str = str::from_utf8(key.to_bytes()).unwrap();
    hash.get(key_str);
}