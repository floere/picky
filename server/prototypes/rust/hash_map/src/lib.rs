extern crate libc;

use libc::{c_char, uint32_t};
use std::{mem, str};
use std::collections::HashMap;
use std::ffi::CStr;

pub struct Database {
    data: HashMap<String, u32>,
}

impl Database {
    fn new() -> Database {
        Database {
            data: HashMap::new(),
        }
    }

    fn set(&mut self, key: &str, number: u32) -> u32 {
        let key = String::from(key);
        self.data.insert(key, number);
        number
    }

    fn get(&self, key: &str) -> u32 {
        self.data.get(key).cloned().unwrap_or(0)
    }
}

#[no_mangle]
pub fn rust_hash_map_new() -> *mut Database {
    unsafe {
        mem::transmute(Box::new(Database::new()))
    }
}

#[no_mangle]
pub fn rust_hash_map_free(ptr: *mut Database) {
    if ptr.is_null() { return }
    let _: Box<Database> = unsafe {
        mem::transmute(ptr)
    };
}

#[no_mangle]
pub fn rust_hash_map_set(ptr: *mut Database, key: *const c_char, value: uint32_t) -> uint32_t {
    let database = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    let key = unsafe {
        assert!(!key.is_null());
        CStr::from_ptr(key)
    };
    let key_str = str::from_utf8(key.to_bytes()).unwrap();
    database.set(key_str, value)
}

#[no_mangle]
pub fn rust_hash_map_get(ptr: *const Database, key: *const c_char) -> uint32_t {
    let database = unsafe {
        assert!(!ptr.is_null());
        &*ptr
    };
    let key = unsafe {
        assert!(!key.is_null());
        CStr::from_ptr(key)
    };
    let key_str = str::from_utf8(key.to_bytes()).unwrap();
    database.get(key_str)
}