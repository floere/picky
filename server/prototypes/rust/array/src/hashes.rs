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
    
    pub fn append_to(&mut self, key: &str, item: u16) {
        match self.data.get_mut(key) {
            Some(array) => array.append(item),
            None => {
                let ary = Box::new(Array::new_with_init(item));
                let key = String::from(key);
                self.data.insert(key, ary);
                item
            }
        };
    }

    pub fn set(&mut self, key: &str, value: Box<Array>) {
        let key = String::from(key);
        self.data.insert(key, value);
    }

    pub fn get(&self, key: &str) -> Option<&Box<Array>> {
        self.data.get(key)
    }
    
    pub fn length(&self) -> usize {
        self.data.len()
    }
}