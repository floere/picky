extern crate libc;

use libc::{c_char, uint32_t};
use std::{mem, str};
use std::collections::HashMap;
use std::ffi::CStr;

pub struct Database {
    data: Vec<u32>,
}

impl Database {
    fn new() -> Database {
        Database {
            data: Vec::new(),
        }
    }

    fn append(&mut self, item: u32) -> u32 {
        self.data.push(item);
        item
    }

    fn first(&self) -> &u32 {
        self.data.first().unwrap()
    }
    
    fn last(&self) -> &u32 {
        self.data.last().unwrap()
    }
}

#[no_mangle]
pub fn rust_array_new() -> *mut Database {
    unsafe {
        mem::transmute(Box::new(Database::new()))
    }
}

#[no_mangle]
pub fn rust_array_free(ptr: *mut Database) {
    if ptr.is_null() { return }
    let _: Box<Database> = unsafe {
        mem::transmute(ptr)
    };
}

#[no_mangle]
pub fn rust_array_append(ptr: *mut Database, item: uint32_t) -> uint32_t {
    let database = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    database.append(item)
}

macro_rules! delegate {
    ($from:ident, $to:ident) => {
        #[no_mangle]
        pub fn $from(ptr: *const Database) -> uint32_t {
            let database = unsafe {
                assert!(!ptr.is_null());
                &*ptr
            };
            *database.$to()
        }
    }
}

// TODO Make it first/last only.
delegate!(rust_array_first, first);
delegate!(rust_array_last, last);

// #[no_mangle]
// pub fn rust_array_first(ptr: *const Database) -> uint32_t {
//     let database = unsafe {
//         assert!(!ptr.is_null());
//         &*ptr
//     };
//     *database.first()
// }
//
// #[no_mangle]
// pub fn rust_array_last(ptr: *const Database) -> uint32_t {
//     let database = unsafe {
//         assert!(!ptr.is_null());
//         &*ptr
//     };
//     *database.last()
// }