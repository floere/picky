use std::collections::HashMap;
use std::hash::Hash;
use std::fmt::Debug;

trait Intersectable<T> {
    fn intersect<'a>(&'a self, other: &'a Vec<T>) -> Vec<T>;
}

// Naïve implementation.
//
impl<T: Hash+Eq+Debug> Intersectable<T> for Vec<T> {
    fn intersect<'a>(&'a self, other: &'a Vec<T>) -> Vec<T> {
        let mut result: Vec<T> = vec![];
        let mut map = HashMap::new();
        
        for item in self.iter() {
            map.insert(item, item);
        }
        
        for item in other.iter() {
            match map.get(item) {
                Some(&res) => {
                    result.push(*res);
                },
                None => (),
            }
        }
        
        result
    }
}

fn main() {
    let vec1: Vec<i16> = vec![1,2,3,4,5,6,7,8,9,10];
    let vec2: Vec<i16> = vec![2,3,4,5,6,7,8,9,10,11];

    let vec3 = vec1.intersect(&vec2);
    
    println!("{:?}", vec3);
}