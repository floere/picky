#![feature(test)]

extern crate test;
extern crate time;

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

pub fn process() {
    let vec1: Vec<u16> = (1..253).collect(); // Only creates a 1..252 Vec.
    let vec2: Vec<u16> = (2..252).collect();

    println!("{:?}", vec1);
    println!("{:?}", vec2);

    let t1 = time::now();
    let vec3 = vec1.intersect(&vec2);
    let t2 = time::now();
    
    println!("{:?}", t2 - t1);
    
    println!("{:?}", vec3);
}

fn main() {
    process();
}


#[cfg(test)]
mod tests {
    use test::Bencher;
    
    use Intersectable;

    #[test]
    fn it_works() {
        let vec1: Vec<u16> = (0..10).collect();
        let vec2: Vec<u16> = (0..10000).collect();
        
        let expected: Vec<u16> = (0..10).collect();
        
        assert_eq!(expected, vec1.intersect(&vec2));
    }

    #[bench]
    fn bench_process(b: &mut Bencher) {
        let vec1: Vec<u16> = (0..10).collect();
        let vec2: Vec<u16> = (0..10000).collect();
        
        b.iter(|| vec1.intersect(&vec2) );
    }
}