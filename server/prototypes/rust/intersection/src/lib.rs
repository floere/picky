trait Intersectable {
    fn intersect(&self) -> &[i16]; // <T: FixedSizeArray>
}

impl Intersectable for [i16] {
    fn intersect(&self, other: [i16]) -> &[i16] {
        self
    }
}

fn main() {
    let ary1: [i16; 3] = [1,2,3];
    // let ary2: [i16; 3] = [2,3,4];

    let ary3 = ary1.intersect();
    
    println!("{:?}", ary3);
}