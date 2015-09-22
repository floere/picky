use std::collections::HashMap;
use arrays::Array;

pub struct Hash {
    data: HashMap<String, Array>,
}

impl Hash {
    pub fn new() -> Hash {
        Hash {
            data: HashMap::new(),
        }
    }

    pub fn set(&mut self, key: &str, value: Array) {
        let key = String::from(key);
        println!("set key: {}", key);
        self.data.insert(key, value);
    }

    pub fn get(&self, key: &str) -> Option<&Array> {
        println!("get key: {}", key);
        let res = self.data.get(key);
        println!("res: {:?}", res);
        res
    }
    
    pub fn length(&self) -> usize {
        self.data.len()
    }
}