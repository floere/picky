#![feature(drain)]

extern crate libc;

use libc::{c_char, uint16_t, size_t};
use std::{mem,str};
use std::ffi::{CStr,CString};

macro_rules! dereflegate {
    ($pointer_type:ident, $from:ident, $to:ident, $ret:ident) => {
        #[no_mangle] pub extern
        // concat_idents! does not work here.
        fn $from(array: &$pointer_type) -> $ret {
            array.$to()
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

#[no_mangle] pub extern "C"
fn rust_array_new() -> Box<Array> {
    Box::new(Array::new())
}

#[no_mangle] pub extern
fn rust_array_free(ptr: *const Array) {
    if ptr.is_null() { return }
    // TODO Why is there a double free happening? Because the Hash frees its components?
    let _: Box<Array> = unsafe { mem::transmute(ptr) };
    // println!("Array freed: {:?}", ptr);
}

#[no_mangle] pub extern "C"
fn rust_array_append(array: &mut Array, item: uint16_t) -> uint16_t {
    array.append(item)
}

#[no_mangle] pub extern "C"
fn rust_array_shift(array: &mut Array) -> Option<uint16_t> {
    array.shift()
}


#[no_mangle] pub extern "C"
fn rust_array_intersect(ary1: &Array, ary2: &Array) -> Box<Array> {
    Box::new(ary1.intersect(ary2))
}

#[no_mangle] pub extern
fn rust_array_slice_bang(array: &mut Array, offset: usize, amount: usize) -> Box<Array> {
    Box::new(array.slice_bang(offset, amount))
}


#[no_mangle] pub extern "C"
fn rust_array_length(array: &Array) -> size_t {
    array.length() as size_t
}

#[no_mangle] pub extern "C"
fn rust_array_first(array: &Array) -> size_t {
    array.first() as size_t
}

#[no_mangle] pub extern "C"
fn rust_array_last(array: &Array) -> size_t {
    array.last() as size_t
}

#[no_mangle] pub extern "C"
fn rust_array_inspect(array: &Array) -> *const libc::c_char {
    CString::new(format!("{:?}", array)).unwrap().into_raw()
}

// TODO Make it first/last/... only.
// dereflegate!(Array, rust_array_first, first, uint16_t);
// dereflegate!(Array, rust_array_last, last, uint16_t);
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

// #[no_mangle] pub extern
// fn rust_hash_append_to(ptr: *mut Hash, key: *const c_char, item: uint16_t) -> uint16_t {
//     let hash = unsafe { &mut *ptr };
//     let key = unsafe { CStr::from_ptr(key) };
//
//     let key_str = str::from_utf8(key.to_bytes()).unwrap();
//     // let key_str = key.to_str().unwrap();
//
//     hash.append_to(key_str, item);
//
//     item
// }

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