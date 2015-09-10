use std::collections::HashMap;
use std::hash::Hash;

trait Intersectable<T> {
    fn intersect<'a>(&'a self, other: &'a Vec<T>) -> Vec<T>;
}

// Naïve implementation.
//
impl<T: Hash+Eq+Copy> Intersectable<T> for Vec<T> {
    fn intersect<'a>(&'a self, other: &'a Vec<T>) -> Vec<T> {
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

fn process() {
    let vec1: Vec<i16> = vec![1,2,3,4,5,6,7,8,9,10];
    let vec2: Vec<i16> = vec![2,3];

    let vec3 = vec1.intersect(&vec2);
    
    println!("{:?}", vec3);
}

fn main() {
    process();
}