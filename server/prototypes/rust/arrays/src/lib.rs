// #![crate_type = "dylib"]
extern crate libc;
pub use libc::types::os::arch::c95::c_char;
pub use libc::types::os::arch::c99::uintptr_t;

// A simple array-like thing that holds i16 numbers.
//

#[no_mangle]
pub extern "C" fn append(other: i16) {
  
}

#[no_mangle]
pub extern "C" fn intersect(other: Vec<i16>) -> Vec<i16> {
  
}

#[link(name = "ruby")]
extern {
  static rb_cObject: libc::c_void;
  fn rb_define_module(name: *const libc::c_char) -> libc::uintptr_t;
  fn rb_define_class_under(
    module: libc::uintptr_t,
    name: *const libc::c_char,
    klass: libc::uintptr_t
  );
  fn rb_define_method(
    klass: libc::uintptr_t,
    name: *const libc::c_char,
    function: extern fn(libc::uintptr_t),
    argc: libc::c_int
  );
  fn rb_define_singleton_method(
    klass: libc::uintptr_t,
    name: *const libc::c_char,
    callback: extern fn(libc::uintptr_t),
    argc: libc::c_int
  );
}

#[no_mangle]
pub extern fn Init_picky() {
  // Module/Class structure.
  let rust_module = unsafe { rb_define_module("Rust".to_c_str().as_ptr()) };
  let rust_array  = unsafe { rb_define_class_under(rust_module, "Array".to_c_str().as_ptr(), rb_cObject) };
  
  // Ruby methods.
  unsafe { rb_define_method(rust_array, "intersect".to_c_str().as_ptr(), intersect, 1) }
}