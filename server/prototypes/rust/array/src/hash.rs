use std::collections::HashMap;

pub struct Data {
    data: HashMap<String, u32>,
}

impl Data {
    pub fn new() -> Data {
        Data {
            data: HashMap::new(),
        }
    }

    pub fn set(&mut self, key: &str, number: u32) -> u32 {
        let key = String::from(key);
        self.data.insert(key, number);
        number
    }

    pub fn get(&self, key: &str) -> u32 {
        self.data.get(key).cloned().unwrap_or(0)
    }
}