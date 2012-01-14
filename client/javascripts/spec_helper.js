// This file defines global helper functions for specs
//
// js specs are intended to be run with the mozilla js standalone lib:
// http://www.ossp.org/pkg/lib/js/
//
// Output is intended to be used in a html wrapper, as in TextMate.

// The tester function.
//
it = function(should, callback) {
  var result = callback();
  if (result) {
    print('.');
  } else {
    print('F - was not ' + should + ' : ' + callback);
  };
};

// For defining a context.
//
context = function(description, setup, specs, breakdown) {
  var old_description = this.context_description;
  var pre_description = old_description ? old_description + ' ' : '';

  // framework setup
  this.context_description = pre_description + description; // sets the description on the global object
  
  if (setup)     { setup(); };
  specs();
  if (breakdown) { breakdown(); };

  // framework breakdown
  this.context_description = old_description;
};

// Alias describe to context.
//
describe = context;