use std::collections::HashMap;
use arrays::Array;

pub struct Hash {
    data: HashMap<String, Box<Array>>,
}

impl Hash {
    pub fn new() -> Hash {
        Hash {
            data: HashMap::new(),
        }
    }

    pub fn set(&mut self, key: &str, value: Box<Array>) {
        let key = String::from(key);
        self.data.insert(key, value);
    }

    pub fn get(&self, key: &str) -> Option<&Box<Array>> {
        self.data.get(key)
    }
    
    pub fn length(&self) -> usize {
        println!("{:?}", self.data.len());
        self.data.len()
    }
}