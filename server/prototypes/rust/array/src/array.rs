pub struct Data {
    data: Vec<u16>,
}

impl Data {
    pub fn new() -> Data {
        Data {
            data: Vec::new(),
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
}