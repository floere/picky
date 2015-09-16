use std::collections::HashMap;
use std::hash::Hash;
use std::mem;

extern crate libc;

use libc::types::common::c95::c_void;
use libc::types::common::c99::uint16_t;
use libc::types::common::c99::uint32_t;
use libc::types::common::c99::uint64_t;
use libc::size_t;

pub struct CompactArray<T> {
    vec: Vec<T>,
}

impl<T> CompactArray<T> {
    fn new() -> CompactArray<T> {
        CompactArray {
            vec: Vec::<T>::new(),
        }
    }
    
    fn append(&mut self, item: T) {
        self.vec.push(item)
    }
    
    fn first(&self) -> &T {
        &self.vec[0]
    }
}

#[no_mangle]
pub fn rust_array_new() -> *mut CompactArray<u32> {
    unsafe {
        mem::transmute(Box::new(CompactArray::<u32>::new()))
    }
}

#[no_mangle]
pub fn rust_array_free(ptr: *mut CompactArray<u32>) {
    if ptr.is_null() { return }
    let _: Box<CompactArray<u32>> = unsafe {
        mem::transmute(ptr)
    };
}

#[no_mangle]
pub fn rust_array_append(ptr: *const CompactArray<u32>, item: *const uint32_t) {
    let array = unsafe {
        assert!(!ptr.is_null());
        &*ptr
    };
    let item = unsafe {
        assert!(!item.is_null());
        &*item
    };
    // let zip_str = str::from_utf8(zip.to_bytes()).unwrap();
    array.append(*item)
}

#[no_mangle]
pub fn rust_array_first(ptr: *mut CompactArray<u32>) -> uint32_t {
    let array = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    *array.first()
}