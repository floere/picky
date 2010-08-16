// Note: This is the Ruby 1.9 version.
//
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
VALUE rb_ary_make_hash(VALUE, VALUE);
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

// Comparison functions.
//
inline int intvaluecmp(VALUE a, VALUE b) {
  return FIX2INT(a) - FIX2INT(b);
}
inline int intcmp(const int * a, const int * b) {
  return (*a - *b);
}
inline long longcmp(const void * a, const void * b) {
  return (*(long*) a - *(long*) b);
}

// This version just calls the & consecutively for all arrays.
//
inline VALUE memory_efficient_intersect(VALUE self, VALUE length_sorted_array_of_arrays) {
  // counters
  long i, j;

  // structs
  struct RArray *rb_array_of_arrays;
  struct RArray *smallest_array;
  struct RArray *current_array;
  VALUE hash;

  // temps
  VALUE v, vv;

  // conversions
  rb_array_of_arrays = RARRAY(length_sorted_array_of_arrays);
  smallest_array     = RARRAY(rb_ary_dup(RARRAY_PTR(rb_array_of_arrays)[0]));

  // iterate through all arrays
  for (i = 1; i < RARRAY_LEN(rb_array_of_arrays); i++) {
    // Break if the smallest array is empty
    if (RARRAY_LEN(smallest_array) == 0) {
      break;
    }

    // make a hash from the currently smallest version
    hash = ary_make_hash(smallest_array, 0);
    // clear for use as temp array
    rb_ary_clear(smallest_array);

    current_array = RARRAY_PTR(rb_array_of_arrays)[i];
    // iterate through all array elements
    for (j = 0; j < RARRAY_LEN(current_array); j++) {
      v = vv = rb_ary_elt(current_array, j);
      if (st_delete(RHASH_TBL(hash), (unsigned long*)&vv, 0)) {
        rb_ary_push(smallest_array, v);
      }
    }
  }

  return smallest_array;
}

// Brute force algorithm to find the intersection of an array of length sorted, unsorted arrays.
// This algorithm can be faster than others for small arrays.
//
// inline VALUE brute_force_intersect(VALUE self, VALUE length_sorted_array_of_arrays) {
//   // counters
//   long i, j, k;
//
//   // structs
//   struct RArray *rb_array_of_arrays;
//   struct RArray *candidate_answer_set;
//   struct RArray *current_set;
//
//   // conversions
//   rb_array_of_arrays = RARRAY(length_sorted_array_of_arrays);
//
//   // temps
//   VALUE e;
//   unsigned char found;
//
//   // Let the smallest set s[0] be the candidate answer set
//   // Note: Need a duplicate
//   candidate_answer_set = RARRAY(rb_ary_dup(rb_array_of_arrays->ptr[0]));
//
//   // For each entry in candidate anser set
//   // Get current value
//   for(i = 0; i < candidate_answer_set->len; i++) {
//     e = candidate_answer_set->ptr[i];
//
//     // Find the current value in other arrays
//     // if not found, break
//     for(j = 1; j < rb_array_of_arrays->len; j++) {
//       current_set = RARRAY(rb_array_of_arrays->ptr[j]);
//       found = 0;
//
//       // Find with a linear search
//       for(k = 0; k < current_set->len; k++) {
//         if (e == current_set->ptr[k]) {
//           found = 1;
//           break;
//         }
//       }
//
//       // break if not found
//       if (!found) {
//         break;
//       }
//     }
//
//     // remove from candidate answer set if not found
//     if (!found) {
//       candidate_answer_set->ptr[i] = Qnil;
//     }
//   }
//
//   // compact the candidate answer set
//   // rb_ary_compact_bang(candidate_answer_set);
//   rb_funcall(candidate_answer_set, rb_intern("compact!"), 0);
//
//   return candidate_answer_set;
// }

// inline VALUE intersect_unique(VALUE self, VALUE length_sorted_array_of_arrays) {
//   // VALUE length_sorted_array_of_arrays = (_length_sorted_array_of_arrays);
//
//   // structs
//   struct RArray *result;
//   struct RArray *rb_array_of_arrays;
//
//   // conversions
//   rb_array_of_arrays = RARRAY(length_sorted_array_of_arrays);
//
//   // TODO
//
//   return result;
// }

// Generates the intersection of multiple
//
// inline VALUE sorting_intersect_multiple(VALUE self, VALUE length_sorted_array_of_arrays) {
//   // TODO
// }

// Generates the intersection of multiple length sorted, sorted arrays
//
// inline VALUE intersect_multiple_sorted(VALUE self, VALUE _length_sorted_array_of_arrays) {
//   VALUE length_sorted_array_of_arrays = (_length_sorted_array_of_arrays);
//
//   // counters
//   long i, j;
//   long current_set_position, current_answer_set_position;
//
//   // structs
//   struct RArray *rb_array_of_arrays;
//   struct RArray *candidate_answer_set;
//   struct RArray *current_set;
//
//   // temps
//   long e;
//
//   // conversions
//   rb_array_of_arrays = RARRAY(length_sorted_array_of_arrays);
//
//   // Let the smallest set s[0] be the candidate answer set
//   // Note: Need a duplicate
//   candidate_answer_set = RARRAY(rb_ary_dup(rb_array_of_arrays->ptr[0]));
//
//   // For each set s[i], i = 1 .. k do
//   for(i = 1; i < rb_array_of_arrays->len; i++) {
//     current_set = RARRAY(rb_array_of_arrays->ptr[i]);
//     current_set_position = 0;
//
//     // for each element e in the candidate answer set
//     for(j = 0; j < candidate_answer_set->len; j++) {
//       e = candidate_answer_set->ptr[j];
//
//       // search for e in the range l[i] to size(s[i])
//       // and update l[i] to the last position probed in the previous step
//       // if e was not found then
//       if (bsearch(
//         &e,
//         &current_set->ptr[current_set_position],
//         (current_set->len - current_set_position),
//         sizeof(VALUE), //sizeof(current_set->ptr[0]),
//         intcmp //longcmp
//       ) == NULL) {
//
//         // remove e from the candidate answer set
//         // and advance e to the next element in the answer set
//         // rb_ary_delete_at(candidate_answer_set, j);
//         candidate_answer_set->ptr[j] = Qnil;
//       }
//       current_set_position = j - 1;
//     }
//
//     // compact the candidate answer set
//     // rb_ary_compact_bang(candidate_answer_set);
//     rb_funcall(candidate_answer_set, rb_intern("compact!"), 0);
//   }
//
//   return candidate_answer_set;
// }

// Trying to make a custom version of Matz' ary &
//
// Differences:
//  * Multiple arrays
//  * No to_ary
//  * Smallest array is used to make hash
// Note: Assumes that whatever is given in as array of arrays is sorted by array sizes.
//
// static VALUE rb_ary_and(ary1, ary2) VALUE ary1, ary2; {
// static VALUE intersect_multiple_with_hash(VALUE self, VALUE _length_sorted_array_of_arrays) {
//   //    VALUE hash, ary3, v, vv;
//   //    long i;
//   //
//   //    ary2 = to_ary(ary2);
//   //    ary3 = rb_ary_new2(RARRAY(ary1)->len < RARRAY(ary2)->len ?
//   //            RARRAY(ary1)->len : RARRAY(ary2)->len);
//   //    hash = ary_make_hash(ary2, 0);
//   //
//   //    for (i=0; i<RARRAY(ary1)->len; i++) {
//   //        v = vv = rb_ary_elt(ary1, i);
//   //        if (st_delete(RHASH(hash)->tbl, (st_data_t*)&vv, 0)) {
//   //            rb_ary_push(ary3, v);
//   //        }
//   //    }
//   //
//   //    return ary3;
//   VALUE length_sorted_array_of_arrays = (_length_sorted_array_of_arrays);
//
//   // structs
//   struct RArray *candidate_answer_set;
//   struct RArray *current_set;
//
//   // temps
//   VALUE hash, v, vv;
//   long i, j, k;
//
//   // Get smallest array size
//   candidate_answer_set = rb_ary_new2((RARRAY(rb_array_of_arrays->ptr[0])->len);
//
//   hash = ary_make_hash(RARRAY(rb_array_of_arrays->ptr[0]), 0);
//
//   // For each entry in candidate answer set
//   // Get current value
//   for(i = 0; i < candidate_answer_set->len; i++) {
//     // e = candidate_answer_set->ptr[i];
//     v = vv = rb_ary_elt(candidate_answer_set, i);
//
//     // Find the current value in other arrays
//     // if not found, break
//     for(j = 1; j < rb_array_of_arrays->len; j++) {
//       current_set = RARRAY(rb_array_of_arrays->ptr[j]);
//       found = 0;
//
//       // Find with a linear search
//       for(k = 0; k < current_set->len; k++) {
//         // if (e == current_set->ptr[k]) {
//         if (st_delete(RHASH(hash)->tbl, (unsigned long*)&vv, 0))
//           found = 1;
//           break;
//         }
//       }
//
//       // break if not found
//       if (!found) {
//         break;
//       }
//     }
//
//     // remove from candidate answer set if not found
//     if (!found) {
//       rb_ary_push(result, v);
//       // candidate_answer_set->ptr[i] = Qnil;
//     }
//   }
//
//   // compact the candidate answer set
//   // rb_ary_compact_bang(candidate_answer_set);
//   rb_funcall(candidate_answer_set, rb_intern("compact!"), 0);
//
//   return candidate_answer_set;
// }

// VALUE rb_ary_clear_bang(ary) VALUE ary; {
//     rb_ary_modify(ary);
//     ARY_SET_LEN(ary, 0);
//     // capa stays the same
//     // if (ARY_DEFAULT_SIZE * 2 < RARRAY(ary)->aux.capa) {
//     //    REALLOC_N(RARRAY(ary)->ptr, VALUE, ARY_DEFAULT_SIZE * 2);
//     //    RARRAY(ary)->aux.capa = ARY_DEFAULT_SIZE * 2;
//     // }
//     return ary;
// }

VALUE p_mPerformant, p_cArray;

void Init_performant() {
  p_mPerformant = rb_define_module("Performant");
  p_cArray = rb_define_class_under(p_mPerformant, "Array", rb_cObject);
  // p_cArray = rb_define_module_under(p_mPerformant, "Array");

  // rb_define_method(rb_cArray, "clear!", rb_ary_clear_bang, 0);

  rb_define_singleton_method(p_cArray, "memory_efficient_intersect", memory_efficient_intersect, 1);
  // rb_define_singleton_method(p_cArray, "brute_force_intersect", brute_force_intersect, 1);
  // rb_define_singleton_method(p_cArray, "intersect_multiple_sorted", intersect_multiple_sorted, 1);
  // rb_define_singleton_method(p_cArray, "intersect_multiple_with_hash", intersect_multiple_sorted_with_hash, 1);
}