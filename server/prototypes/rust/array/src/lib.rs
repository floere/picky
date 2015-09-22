extern crate libc;

use libc::{c_char, uint16_t, size_t};
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
            let data = unsafe { &*ptr };
            data.$to()
        }
    };
}

// Load the pure Rust array.
pub mod arrays;
use arrays::Array;

#[no_mangle] pub extern
fn rust_array_new() -> *const Array {
    unsafe { mem::transmute(Box::new(Array::new())) }
}

#[no_mangle] pub extern
fn rust_array_free(ptr: *const Array) {
    if ptr.is_null() { return }
    let _: Box<Array> = unsafe { mem::transmute(ptr) };
    // println!("Array freed: {:?}", ptr);
}

#[no_mangle] pub extern
fn rust_array_append(ptr: *mut Array, item: uint16_t) -> uint16_t {
    let array = unsafe { &mut *ptr };
    array.append(item)
}

#[no_mangle] pub extern
fn rust_array_length(ptr: *const Array) -> size_t {
    let array = unsafe { &*ptr };
    array.length() as size_t
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
    unsafe { mem::transmute(Box::new(Hash::new())) }
}

#[no_mangle] pub extern
fn rust_hash_free(ptr: *mut Hash) {
    if ptr.is_null() { return }
    let _: Box<Hash> = unsafe { mem::transmute(ptr) };
    // println!("Hash freed: {:?}", ptr);
}

#[no_mangle] pub extern
fn rust_hash_set(ptr: *mut Hash, key: *const c_char, value: *const Array) -> *const Array {
    let hash = unsafe { &mut *ptr };
    let transformed_key = unsafe { CStr::from_ptr(key) };
    let boxed_value: Box<Array> = unsafe { mem::transmute(value) };
    
    let key_str = str::from_utf8(transformed_key.to_bytes()).unwrap();
    
    hash.set(key_str, boxed_value);
    
    value
}

#[no_mangle] pub extern
fn rust_hash_get(ptr: *const Hash, key: *const c_char) -> *const Array {
    let hash = unsafe { &*ptr };
    let key = unsafe { CStr::from_ptr(key) };
    let key_str = str::from_utf8(key.to_bytes()).unwrap();
    
    rust_hash_internal_get(hash, key_str)
}

fn rust_hash_internal_get(hash: &Hash, key_str: &str) -> *const Array {
    let opt = hash.get(key_str);
    match opt {
        Some(boxed) => { &**boxed },
        None => std::ptr::null()
    }
}

#[no_mangle] pub extern
fn rust_hash_length(ptr: *const Hash) -> size_t {
    let hash = unsafe { &*ptr };
    hash.length() as size_t
}

// delegate!(Hash, rust_hash_length, length, size_t);