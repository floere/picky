use std::collections::HashMap;
use std::hash::Hash;
// use std::mem;

extern crate libc;

use libc::types::common::c95::c_void;
use libc::types::common::c99::uint16_t;

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
pub extern "C" fn rust_array_first(ptr: *mut uint16_t) -> uint16_t {        
    // println!("0 {}", unsafe { *ptr });
    // println!("2 {}", unsafe { *ptr.offset(1) });
    // println!("4 {}", unsafe { *ptr.offset(2) });
    
    unsafe { *ptr }
}

#[no_mangle]
pub extern "C" fn rust_array_alloc() -> *const u16 {
    // Alloc space on the heap.
    let mut obj = Box::new(Vec::<u16>::new());
    
    // Add values (manual test).
    obj.push(7);
    obj.push(8);
    obj.push(9);
    
    println!("obj[0] {:?}", obj[0]);
    println!("obj[1] {:?}", obj[1]);
    println!("obj[2] {:?}", obj[2]);
    println!("&obj {:?}", &obj);
    
    let ptr = (*obj).as_ptr();
    
    // let ptr = obj.as_mut_ptr();
    // let len = obj.len();
    // let cap = obj.capacity();
    
    ::std::mem::forget(obj);
    
    ptr
}