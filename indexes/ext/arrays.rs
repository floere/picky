use std::fmt;

use std::collections::HashMap;
use std::hash::Hash;

pub struct Array {
    data: Vec<u16>,
}

impl Array {
    pub fn new() -> Array {
        Array {
            data: Vec::new(),
        }
    }
    
    pub fn new_with_init(item: u16) -> Array {
        Array {
            data: vec![item],
        }
    }

    pub fn append(&mut self, item: u16) -> u16 {
        self.data.push(item);
        item
    }
    
    pub fn shift(&mut self) -> Option<u16> {
        if self.data.is_empty() {
            None
        } else {
            Some(self.data.remove(0))
        }
    }
    
    pub fn intersect(&self, other: &Array) -> Array {
        Array {
            data: self.data.intersect(&other.data)
        }
    }
    
    pub fn slice_bang(&mut self, offset: usize, amount: usize) -> Array {
        Array {
            data: self.data.drain(offset..offset+amount).collect()
        }
    }

    pub fn first(&self) -> Option<&u16> {
        self.data.first()
    }

    pub fn last(&self) -> Option<&u16> {
        self.data.last()
    }
    
    pub fn length(&self) -> usize {
        self.data.len()
    }
    
    pub fn eq(&self, other: &Array) -> bool {
        if self.data.len() == other.data.len() {
            // We need to check.
            for (a, b) in self.data.iter().zip(other.data.iter()) {
                if a != b {
                    return false;
                }
            }
            true
        } else {
            false
        }
    }
}

impl fmt::Debug for Array {
    fn fmt(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
        write!(formatter, "{:?}", self.data)
    }
}

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


#[test]
pub fn normal_intersection() {
    let ary1 = Array { data: vec![1,2,3,4] };
    let ary2 = Array { data: vec![1,4,7] };
    
    assert_eq!(vec![1,4], ary1.intersect(&ary2).data);
}
#[test]
pub fn left_empty_intersection() {
    let ary1 = Array { data: Vec::<u16>::new() };
    let ary2 = Array { data: vec![1,4,7] };
    
    assert_eq!(Vec::<u16>::new(), ary1.intersect(&ary2).data);
}
#[test]
pub fn right_empty_intersection() {
    let ary1 = Array { data: vec![1,2,3] };
    let ary2 = Array { data: Vec::<u16>::new() };
    
    assert_eq!(Vec::<u16>::new(), ary1.intersect(&ary2).data);
}

#[test]
pub fn normal_slice() {
    let mut ary = Array { data: vec![0,1,2,3,4,5,6,7,8,9] };
    let expected = Array { data: vec![3,4,5,6,7] };
    
    assert_eq!(expected.data, ary.slice_bang(3,5).data);
}
#[test]
pub fn short_slice() {
    let mut ary = Array { data: vec![1,2,3,4] };
    let expected = Array { data: vec![2,3] };
    
    assert_eq!(expected.data, ary.slice_bang(1,2).data);
}