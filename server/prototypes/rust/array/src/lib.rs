extern crate libc;

use libc::uint16_t;
use std::mem;

pub struct Data {
    data: Vec<u16>,
}

impl Data {
    fn new() -> Data {
        Data {
            data: Vec::new(),
        }
    }

    fn append(&mut self, item: u16) -> u16 {
        self.data.push(item);
        item
    }

    fn first(&self) -> &u16 {
        self.data.first().unwrap()
    }
    
    fn last(&self) -> &u16 {
        self.data.last().unwrap()
    }
}

#[no_mangle] pub extern
fn rust_array_new() -> *mut Data {
    unsafe {
        mem::transmute(Box::new(Data::new()))
    }
}

#[no_mangle] pub extern
fn rust_array_free(ptr: *mut Data) {
    if ptr.is_null() { return }
    let _: Box<Data> = unsafe {
        mem::transmute(ptr)
    };
}

#[no_mangle] pub extern
fn rust_array_append(ptr: *mut Data, item: uint16_t) -> uint16_t {
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
        fn $from(ptr: *const Data) -> uint16_t {
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