#include <stdlib.h>
#include <ruby.h>

static VALUE rb_mRust;
static VALUE rb_cRustArray;

extern VALUE rust_array_init();
extern VALUE rust_array_append(VALUE self, VALUE item);

// Test method.
extern char *rust_print(void);
VALUE print(void) {
    char *text = rust_print();
    printf("%s\n", text);

    return Qnil;
}

void
Init_integration() {
  rb_mRust = rb_define_module("Rust");
  rb_cRustArray = rb_define_class_under(rb_mRust, "Array", rb_cObject);
 
  rb_define_method(rb_cRustArray, "initialize", rust_array_init, 0);
  rb_define_method(rb_cRustArray, "<<", rust_array_append, 1);
  
  // Test method.
  rb_define_method(rb_cRustArray, "print", print, 0);
}