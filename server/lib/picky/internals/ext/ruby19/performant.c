#include "ruby.h"

// Copying internal ruby methods.
//
static inline VALUE rb_ary_elt(ary, offset)
    VALUE ary;
    long offset;
{
    if (RARRAY_LEN(ary) == 0) return Qnil;
    if (offset < 0 || RARRAY_LEN(ary) <= offset) {
        return Qnil;
    }
    return RARRAY_PTR(ary)[offset];
}
static VALUE ary_make_hash(ary1, ary2)
    VALUE ary1, ary2;
{
    VALUE hash = rb_hash_new();
    long i;

    for (i=0; i<RARRAY_LEN(ary1); i++) {
        rb_hash_aset(hash, RARRAY_PTR(ary1)[i], Qtrue);
    }
    if (ary2) {
        for (i=0; i<RARRAY_LEN(ary2); i++) {
            rb_hash_aset(hash, RARRAY_PTR(ary2)[i], Qtrue);
        }
    }
    return hash;
}

// This version just calls the & consecutively for all arrays.
// 
// The arrays need to be pre-sorted small to large.
// 
inline VALUE memory_efficient_intersect(VALUE self, VALUE length_sorted_array_of_arrays) {
  // Counters.
  //
  long i, j;
  
  // Vars.
  //
  struct RArray *rb_array_of_arrays;
  VALUE smallest_array;
  VALUE current_array;
  VALUE hash;
  
  // Temps.
  //
  VALUE v, vv;
  
  // Conversions.
  //
  rb_array_of_arrays = RARRAY(length_sorted_array_of_arrays);
  smallest_array     = (VALUE) RARRAY(rb_ary_dup(RARRAY_PTR(rb_array_of_arrays)[0]));
  
  // Iterate through all arrays.
  //
  for (i = 1; i < RARRAY_LEN(rb_array_of_arrays); i++) {
    // Break if the smallest array is empty
    if (RARRAY_LEN(smallest_array) == 0) {
      break;
    }
    
    // Make a hash from the currently smallest version.
    //
    hash = ary_make_hash(smallest_array, 0);
    
    // Clear for use as temp array.
    //
    rb_ary_clear(smallest_array);
    
    // Iterate through all array elements.
    //
    current_array = RARRAY_PTR(rb_array_of_arrays)[i];
    for (j = 0; j < RARRAY_LEN(current_array); j++) {
      v = vv = rb_ary_elt(current_array, j);
      if (st_delete(RHASH_TBL(hash), (unsigned long*)&vv, 0)) {
        rb_ary_push(smallest_array, v);
      }
    }
  }
  
  return smallest_array;
}

VALUE p_mPerformant, p_cArray;

void Init_performant() {
  p_mPerformant = rb_define_module("Performant");
  p_cArray = rb_define_class_under(p_mPerformant, "Array", rb_cObject);
  rb_define_singleton_method(p_cArray, "memory_efficient_intersect", memory_efficient_intersect, 1);
}