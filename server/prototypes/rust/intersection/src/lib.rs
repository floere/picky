use std::collections::HashMap;

trait Intersectable {
    fn intersect<'a>(&'a self, other: &'a Vec<i16>) -> Vec<i16>;
}

// Naïve implementation.
//
impl Intersectable for [i16] {
    fn intersect<'a>(&'a self, other: &'a Vec<i16>) -> Vec<i16> {
        let mut result: Vec<i16> = vec![];
        let mut map = HashMap::new();
        
        for item in self.iter() {
            map.insert(item, item);
        }
        
        for item in other.iter() {
            match map.get(item) {
                Some(&res) => result.push(*res),
                _ => {},
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