#![feature(libc)]

// #![crate_type = "dylib"]

extern crate libc;
use std::ffi::CString;
pub use libc::types::os::arch::c95::c_char;
pub use libc::types::os::arch::c99::uintptr_t;

#[link(name = "ruby")]
extern {
  // static rb_cObject: &'static libc::c_void;
  fn rb_define_module(name: *const libc::c_char) -> libc::uintptr_t;
  // fn rb_define_class_under(
  //   module: libc::uintptr_t,
  //   name: *const libc::c_char,
  //   klass: &libc::c_void
  // ) -> libc::uintptr_t;
  // fn rb_define_method(
  //   klass: libc::uintptr_t,
  //   name: *const libc::c_char,
  //   function: extern fn(libc::uintptr_t),
  //   argc: libc::c_int
  // );
  // fn rb_define_singleton_method(
  //   klass: libc::uintptr_t,
  //   name: *const libc::c_char,
  //   callback: extern fn(libc::uintptr_t),
  //   argc: libc::c_int
  // );
}

fn main() {
  
  let rust_module = unsafe {
    let rust_module_name = CString::new("Rust").unwrap().as_ptr();
    // println!("{:?}", CString::new("Rust").unwrap());
    rb_define_module(rust_module_name)
  };
  println!("{:?}", rust_module);
}