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

    pub fn set(&mut self, key: &str, array: Array) {
        let key = String::from(key);
        self.data.insert(key, array);
    }

    pub fn get(&self, key: &str) -> Option<&Array> {
        self.data.get(key)
    }
}