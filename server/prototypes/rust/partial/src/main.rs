fn addition<T>(a: i32, fun: T) -> Box<Fn(i32) -> i32>
    where T : Fn(i32) -> i32 + 'static {
        Box::new(move |b| a + fun(b))
}

fn main() {
    let c = 100;
    let fun1 = move |b| b + c;
    let fun2 = addition(10, fun1);
    
    // println!("{}", &fun2(1));
}