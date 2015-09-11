use std::collections::HashMap;
use std::hash::Hash;
// use std::mem;

extern crate libc;

use libc::types::common::c95::c_void;
use libc::types::common::c99::uint16_t;
use libc::types::common::c99::uint32_t;
use libc::types::common::c99::uint64_t;
use libc::size_t;

trait Intersectable<T> {
    fn intersect(&self, other: &Vec<T>) -> Vec<T>;
}

// Naïve implementation.
//
impl<T: Hash+Eq+Copy> Intersectable<T> for Vec<T> {
    fn intersect(&self, other: &Vec<T>) -> Vec<T> {
        let mut result: Vec<T> = vec![];
        let mut map = HashMap::<T,()>::new();
        
        // Use the shorter Vector for the Hash.
        let longer;
        let shorter;
        
        if self.len() > other.len() {
            longer  = self;
            shorter = other;
        } else {
            longer  = other;
            shorter = self;
        }
        
        // Insert all items in the shorter Vector
        // into the Hash.
        for &item in shorter.iter() {
            map.insert(item, ());
        }
        
        // Iterate over the longer Vector to
        // fill result vector.
        for &item in longer.iter() {
            if map.contains_key(&item) {
                result.push(item);
            }
        }
        
        result
    }
}

#[no_mangle]
pub extern "C" fn rust_array_append(vec: *mut c_void, item: uint16_t) {
    let vec = unsafe { &mut *(vec as *mut Vec<u16>) };
    
    println!("{:?} << {:?}", vec, item);
    
    vec.push(item);
    
    println!("{:?}", vec);
}

#[no_mangle]
pub extern "C" fn rust_array_first(
    ptr: *mut uint16_t,
    len: *mut size_t,
    cap: *mut size_t) -> uint16_t {        
    
    println!("0 {}", unsafe { *ptr });
    println!("2 {}", unsafe { *ptr.offset(1) });
    println!("4 {}", unsafe { *ptr.offset(2) });
    
    let vec = unsafe { Vec::from_raw_parts(ptr, len as usize, cap as usize) };
    
    vec[0]
}

#[no_mangle]
pub extern "C" fn rust_array_alloc(
        ptr: *mut uint64_t,
        len: *mut size_t,
        cap: *mut size_t) -> *mut uint64_t {
    // Alloc space on the heap.
    let mut obj = Box::new(Vec::<u16>::new());
    
    // Add values (manual test).
    obj.push(7);
    obj.push(8);
    obj.push(9);
    obj.push(10);
    obj.push(11);
    
    println!("&obj {:?}", &obj);
    
    unsafe {
        *ptr = obj.as_ptr() as uint64_t;
        *len = obj.len() as size_t;
        *cap = obj.capacity() as size_t;
    }
    
    println!("Rust ptr {:?}", ptr);
    
    ::std::mem::forget(obj);
    
    ptr
}