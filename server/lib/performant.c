#include "ruby.h"

static inline VALUE ary_make_hash(ary1, ary2)
    VALUE ary1, ary2;
{
    VALUE hash = rb_hash_new();
    long i;

    for (i=0; i<RARRAY_LEN(ary1); i++) {
        rb_hash_aset(hash, rb_ary_entry(ary1,i), Qtrue);
    }
    if (ary2) {
        for (i=0; i<RARRAY_LEN(ary2); i++) {
            rb_hash_aset(hash, rb_ary_entry(ary2, i), Qtrue);
        }
    }
    return hash;
}
static inline VALUE rb_ary_length(VALUE ary) {
  long length = RARRAY_LEN(ary);
  return LONG2NUM(length);
}

// This version:
//  * orders the arrays by ascending size, small to large.
//  * calls the & consecutively for all arrays.
//
static inline VALUE memory_efficient_intersect(VALUE self, VALUE unsorted_array_of_arrays) {
  // Counters.
  //
  long i, j;

  // Vars.
  //
  VALUE rb_array_of_arrays;
  VALUE smallest_array;
  VALUE current_array;
  VALUE hash;

  // Temps.
  //
  VALUE v;

  // Conversions & presorting.
  //
  rb_array_of_arrays = rb_block_call(unsorted_array_of_arrays, rb_intern("sort_by!"), 0, 0, rb_ary_length, 0);
  smallest_array     = rb_ary_dup(rb_ary_entry(rb_array_of_arrays, 0));

  // Iterate through all arrays.
  //
  for (i = 1; i < RARRAY_LEN(rb_array_of_arrays); i++) {
    // Break if the smallest array is empty
    //
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
    current_array = rb_ary_entry(rb_array_of_arrays, i);
    for (j = 0; j < RARRAY_LEN(current_array); j++) {
      v = rb_ary_entry(current_array, j);
      if (rb_hash_delete(hash, v) != Qnil) {
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
