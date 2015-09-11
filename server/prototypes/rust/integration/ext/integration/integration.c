#include <stdlib.h>
#include <ruby.h>

static VALUE rb_mRust;
static VALUE rb_cRustArray;

extern void* rust_array_alloc();
extern uint16_t rust_array_first(void*);
extern VALUE rust_array_append(VALUE self, VALUE item);

static void rary_mark(void *ptr)
{
  // struct rust_array *rary = ptr;
}

static void rary_free(void *ptr)
{
//   struct rust_array *rary = ptr;
//   xfree(rary);
}

static size_t rary_memsize(const void *ptr)
{
  return ptr ? sizeof(void*) : 0;
}

static const rb_data_type_t rust_array_data_type = {
  "rust_array",
  {rary_mark, rary_free, rary_memsize,},
};

static VALUE rary_alloc(VALUE klass) {
  VALUE obj;
  void *ptr  = rust_array_alloc();
  
  printf("ptr %p\n", ptr);

  obj = Data_Wrap_Struct(klass, &rary_mark, &rary_free, ptr);
  
  printf("obj %p\n", (void *) obj);
  
  return obj;
};

static void*
rary_get_ptr(VALUE obj) 
{
  void *ptr = 0; 
  
  printf("obj#get_ptr %p\n", (void *) obj);
  
  Data_Get_Struct(obj, void, ptr);

  printf("ptr#get_ptr %p\n", ptr);

  return ptr; 
}

extern VALUE ruby_rust_array_first(VALUE self) {
  VALUE obj;
  void *ptr = rary_get_ptr(self);
  
  printf("ptr#first %p\n", ptr);
    
  uint16_t num = rust_array_first(ptr);
  
  printf("NUM %d\n", num);

  return INT2NUM(num);
}

void
Init_integration() {
  rb_mRust = rb_define_module("Rust");
  rb_cRustArray = rb_define_class_under(rb_mRust, "Array", rb_cObject);
 
  rb_define_alloc_func(rb_cRustArray, rary_alloc);
  rb_define_method(rb_cRustArray, "first", ruby_rust_array_first, 0);
  rb_define_method(rb_cRustArray, "<<", rust_array_append, 1);
}