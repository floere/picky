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
pub extern "C" fn rust_array_first(
    ptr: *mut uint64_t,
    len: *mut size_t,
    cap: *mut size_t) -> uint64_t {
    
    let vec = unsafe { Vec::from_raw_parts(ptr, len as usize, cap as usize) };
    
    println!("first: {:?}", vec);
    
    vec[0] as uint64_t
}

#[no_mangle]
pub extern "C" fn rust_array_append(
    ptr: *mut uint64_t,
    len: *mut size_t,
    cap: *mut size_t,
    item: *mut uint64_t) -> *mut uint64_t {
    
    // It is possible it has not been allocated yet!
    // 
    println!("ptr: {:?}", ptr);
    let mut vec = unsafe { Vec::<u64>::from_raw_parts(ptr, *len as usize, *cap as usize) };
    
    // // The vector will not allocate until elements are pushed onto it.
    // println!("vec is empty {}", vec.is_empty());
    // if vec.len() == 0 {
    //     vec = internal_array_alloc();
    // }
    
    println!("pushing {:?}", item as u64);
    vec.push(item as u64);
    println!("pushed onto {:?}", vec.as_ptr());
    
    println!("vec: {:?}", vec);
    
    unsafe {
        // *ptr = vec.as_ptr() as uint64_t;
        *len = vec.len() as size_t;
        *cap = vec.capacity() as size_t;
    }
    
    ::std::mem::forget(vec);
    
    item
}

#[no_mangle]
pub extern "C" fn rust_array_alloc(
        ptr: *mut uint64_t,
        len: *mut size_t,
        cap: *mut size_t) -> *mut uint64_t {
    let mut vec = internal_array_alloc();
    
    // Add value (manual test).
    vec.push(27);
    
    unsafe {
        *ptr = vec.as_ptr() as uint64_t;
        *len = vec.len() as size_t;
        *cap = vec.capacity() as size_t;
    }
    
    ::std::mem::forget(vec);
    
    ptr
}

fn internal_array_alloc() -> Vec<u64> {
    // Alloc space on the heap.
    Vec::<u64>::new()
}