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
  VALUE result_array;
  VALUE current_array;
  VALUE hash;
  VALUE ary;

  // Temps.
  //
  VALUE v;

  // Conversions & presorting.
  //
  rb_array_of_arrays = rb_block_call(unsorted_array_of_arrays, rb_intern("sort_by!"), 0, 0, rb_ary_length, 0);
  
  // Assume the smallest array is the result already.
  //
  result_array = rb_ary_dup(rb_ary_entry(rb_array_of_arrays, 0));

  // Iterate through all other arrays.
  //
  for (i = 1; i < RARRAY_LEN(rb_array_of_arrays); i++) {
    // Break if the result array is empty.
    // (Because intersecting anything with it will yield nothing)
    //
    if (RARRAY_LEN(result_array) == 0) {
      break;
    }
    
    // If the result array is currently larger than 10
    // entries, use a hash for intersection, else
    // use an array.
    //
    if (RARRAY_LEN(result_array) > 10) {
      // Make a hash from the currently smallest version.
      //
      hash = ary_make_hash(result_array, 0);

      // Clear for use as temp array.
      //
      rb_ary_clear(result_array);

      // Get the current array.
      //
      current_array = rb_ary_entry(rb_array_of_arrays, i);

      // Iterate through all array elements.
      //
      for (j = 0; j < RARRAY_LEN(current_array); j++) {
        v = rb_ary_entry(current_array, j);
        if (rb_hash_delete(hash, v) != Qnil) {
          rb_ary_push(result_array, v);
        }
      }
    } else {
      // Make a new array from the currently smallest version.
      //
      ary = rb_ary_dup(result_array);

      // Clear for use as temp array.
      //
      rb_ary_clear(result_array);

      // Get the current array.
      //
      current_array = rb_ary_entry(rb_array_of_arrays, i);

      // Iterate through all array elements.
      //
      for (j = 0; j < RARRAY_LEN(current_array); j++) {
        v = rb_ary_entry(current_array, j);
        if (rb_ary_delete(ary, v) != Qnil) {
          rb_ary_push(result_array, v);
        }
      }
    }
  }

  return result_array;
}

VALUE p_mPerformant, p_cArray;

void Init_picky() {
  p_mPerformant = rb_define_module("Performant");
  p_cArray = rb_define_class_under(p_mPerformant, "Array", rb_cObject);
  rb_define_singleton_method(p_cArray, "memory_efficient_intersect", memory_efficient_intersect, 1);
}
