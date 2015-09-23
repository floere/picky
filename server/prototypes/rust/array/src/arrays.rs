use std::fmt;

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

    pub fn first(&self) -> &u16 {
        self.data.first().unwrap()
    }

    pub fn last(&self) -> &u16 {
        self.data.last().unwrap()
    }
    
    pub fn length(&self) -> usize {
        self.data.len()
    }
}

impl fmt::Debug for Array {
    fn fmt(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
        write!(formatter, "{:?}", self.data)
    }
}