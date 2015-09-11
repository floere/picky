use std::collections::HashMap;
use std::hash::Hash;

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
pub extern "C" fn rust_array_append(inst: &mut Vec<u16>, item: u16) -> &Vec<u16> {
    println!("{:?} << {:?}", inst, item);
    
    inst.push(item);
    
    println!("{:?}", inst);
    
    inst
}

#[no_mangle]
pub extern "C" fn rust_array_init() ->*const u16 {
    Vec::<u16>::new().as_ptr()
}

#[no_mangle]
pub extern "C" fn rust_print() -> *const u8 {
    "Hello, world!\0".as_ptr()
}