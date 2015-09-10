trait Intersectable {
    fn intersect<'a>(&'a self, other: &'a [i16]) -> &[i16]; // <T: FixedSizeArray>
}

impl Intersectable for [i16] {
    fn intersect<'a>(&'a self, other: &'a [i16]) -> &[i16] {
        other
    }
}

fn main() {
    let ary1: [i16; 3] = [1,2,3];
    let ary2: [i16; 3] = [2,3,4];

    let ary3 = ary1.intersect(&ary2);
    
    println!("{:?}", ary3);
}