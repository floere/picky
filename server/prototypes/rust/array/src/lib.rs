extern crate libc;

use libc::{c_char, uint16_t, uint32_t};
use std::{mem, str};
use std::ffi::CStr;

// Load the pure Rust array.
mod array;

#[no_mangle] pub extern
fn rust_array_new() -> *mut array::Data {
    unsafe {
        mem::transmute(Box::new(array::Data::new()))
    }
}

#[no_mangle] pub extern
fn rust_array_free(ptr: *mut array::Data) {
    if ptr.is_null() { return }
    let _: Box<array::Data> = unsafe {
        mem::transmute(ptr)
    };
}

#[no_mangle] pub extern
fn rust_array_append(ptr: *mut array::Data, item: uint16_t) -> uint16_t {
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
        fn $from(ptr: *const array::Data) -> uint16_t {
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
mod hash;

#[no_mangle] pub extern
fn rust_hash_map_new() -> *mut hash::Data {
    unsafe {
        mem::transmute(Box::new(hash::Data::new()))
    }
}

#[no_mangle] pub extern
fn rust_hash_map_free(ptr: *mut hash::Data) {
    if ptr.is_null() { return }
    let _: Box<hash::Data> = unsafe {
        mem::transmute(ptr)
    };
}

#[no_mangle] pub extern
fn rust_hash_map_set(ptr: *mut hash::Data, key: *const c_char, value: uint32_t) -> uint32_t {
    let data = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    let key = unsafe {
        assert!(!key.is_null());
        CStr::from_ptr(key)
    };
    let key_str = str::from_utf8(key.to_bytes()).unwrap();
    data.set(key_str, value)
}

#[no_mangle] pub extern
fn rust_hash_map_get(ptr: *const hash::Data, key: *const c_char) -> uint32_t {
    let data = unsafe {
        assert!(!ptr.is_null());
        &*ptr
    };
    let key = unsafe {
        assert!(!key.is_null());
        CStr::from_ptr(key)
    };
    let key_str = str::from_utf8(key.to_bytes()).unwrap();
    data.get(key_str)
}