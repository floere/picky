#include <stdlib.h>
#include <ruby.h>

static VALUE rb_mRust;
static VALUE rb_cRustArray;

extern void* rust_array_alloc();
extern uint16_t rust_array_first(void*, size_t, size_t);
extern VALUE rust_array_append(VALUE self, VALUE item);

struct rust_array {
  void* ptr;
  size_t len;
  size_t cap;
};

static void rary_mark(void *ptr)
{
  // struct rust_array *rary = ptr;
}

static void rary_free(void *ptr)
{
  struct rust_array *rary = ptr;
  xfree(rary);
}

static size_t rary_memsize(const void *ptr)
{
  return ptr ? sizeof(struct rust_array) : 0;
}

static const rb_data_type_t rust_array_data_type = {
  "rust_array",
  {rary_mark, rary_free, rary_memsize,},
};

static VALUE rary_alloc(VALUE klass) {
  VALUE obj;
  
  struct rust_array *rary_ptr;
  
  void *ptr = 0;
  size_t len = 11;
  size_t cap = 12;
  
  rust_array_alloc(&ptr, &len, &cap);
  
  printf("C: ptr %p\n", ptr);
  printf("C: len %lu\n", len);
  printf("C: cap %lu\n", cap);

  obj = TypedData_Make_Struct(klass, struct rust_array, &rust_array_data_type, rary_ptr);
  
  rary_ptr->ptr = ptr;
  rary_ptr->len = len;
  rary_ptr->cap = cap;
  
  printf("C: Ruby obj %p\n", (void *) obj);
  
  return obj;
};

static void*
rary_get_ptr(VALUE obj) 
{ 
  printf("obj#get_ptr %p\n", (void *) obj);
  
  struct rust_array *ptr = 0;
  
  TypedData_Get_Struct(obj, struct rust_array, &rust_array_data_type, ptr);

  printf("ptr#get_ptr %p\n", ptr);

  return ptr; 
}

extern VALUE ruby_rust_array_first(VALUE self) {
  VALUE obj;
  struct rust_array *rary = rary_get_ptr(self);
  
  printf("ptr#first %p\n", rary->ptr);
  printf("len#first %lu\n", rary->len);
  printf("cap#first %lu\n", rary->cap);
    
  uint16_t num = rust_array_first(rary->ptr, rary->len, rary->cap);
  
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