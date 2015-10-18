use std::fmt;

use std::collections::HashMap;
use std::hash::Hash;
use std::cmp::Ordering;

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
    
    pub fn shift_amount(&mut self, amount: usize) -> Array {
        let mut actual_amount = amount;
        if self.data.len() < actual_amount {
            actual_amount = self.data.len();
        }
        Array {
            // Upper bound is exclusive
            data: self.data.drain(0..actual_amount).collect()
        }
    }
    
    pub fn unshift(&mut self, item: u16) -> u16 {
        self.data.insert(0, item);
        item
    }
    
    pub fn intersect(&self, other: &Array) -> Array {
        Array {
            data: self.data.intersect(&other.data)
        }
    }
    
    pub fn sort_by<F>(&mut self, compare: F) -> Array
        where F : FnMut(&u16, &u16) -> Ordering {
        let mut vector = self.data.to_vec(); // TODO Do not copy.
        vector.sort_by(compare);
        Array {
            data: vector
        }
    }
    
    // TODO Could be improved in speed (set capacity etc.).
    pub fn plus(&self, other: &Array) -> Array {
        let mut vector = vec![];
        vector.extend(self.data.iter());
        vector.extend(other.data.iter());
        Array {
            data: vector
        }
    }
    
    // TODO Could be much improved in speed (set capacity etc.).
    pub fn minus(&self, other: &Array) -> Array {
        let mut vector = self.data.to_vec();
        vector.retain(|&item| !other.data.contains(&item));
        Array {
            data: vector
        }
    }
    
    pub fn slice_bang(&mut self, offset: usize, amount: usize) -> Array {
        let mut actual_amount = amount;
        if self.data.len() < offset + actual_amount {
            actual_amount = self.data.len() - offset;
        }
        Array {
            data: self.data.drain(offset..offset+actual_amount).collect()
        }
    }

    pub fn first(&self) -> Option<&u16> {
        self.data.first()
    }
    
    pub fn first_amount(&mut self, mut amount: usize) -> Array {
        // Check for length.
        let length = self.length();
        if amount > length { amount = length; }
        let mut vector = Vec::with_capacity(amount);
        vector.extend(self.data[0..amount].iter().cloned());
        Array {
            data: vector
        }
    }

    pub fn last(&self) -> Option<&u16> {
        self.data.last()
    }
    
    pub fn length(&self) -> usize {
        self.data.len()
    }
    
    pub fn empty(&self) -> bool {
        self.data.is_empty()
    }
    
    pub fn include(&self, item: u16) -> bool {
        self.data.contains(&item)
    }
    
    // Creates a copy.
    pub fn dup(&self) -> Array {
        Array {
            data: self.data.to_vec()
        }
    }
}

impl PartialEq for Array {
    fn eq(&self, other: &Array) -> bool {
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
    
    assert_eq!(expected, ary.slice_bang(3,5));
}
#[test]
pub fn short_slice() {
    let mut ary = Array { data: vec![1,2,3,4] };
    let expected = Array { data: vec![2,3] };
    
    assert_eq!(expected, ary.slice_bang(1,2));
}