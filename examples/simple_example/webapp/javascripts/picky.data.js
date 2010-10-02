// The data is basically the model behind the search.
//

// Container for an allocation.
//
function Allocation(type, weight, count, combination, ids, rendered) {
  var self = this;

  this.type        = type;        // 'books'
  this.weight      = weight;      // 5.14
  this.count       = count;       // 14
  this.combination = combination; // [['title', 'Old', 'old'], ['title', 'Man', 'man']]
  this.ids         = ids || [];
  this.rendered    = rendered || [];
  this.entries     = this.rendered;

  this.isType = function(name) {
    return name == self.type;
  };
};

// Container for the allocations.
//
// allocs (should) come preordered by weight.
//
function Allocations(allocations) {
  var self = this;

  this.allocations = [];

  // Wrap and save the allocations.
  //
  for (var i = 0, l = allocations.length; i < l; i++) {
    var alloc = allocations[i];
    var new_allocation = new Allocation(alloc[0], alloc[1], alloc[2], alloc[3], alloc[4], alloc[5]);
    this.allocations.push(new_allocation);
  }
  this.length = this.allocations.length;
  
  this.each = function(callback) {
    return $.each(this.allocations, callback);
  };
};

// Container for the types.
//
// data:
//   offset: X
//   duration: X
//   total: X
//   allocations:
//     Allocation[] of [weight, count, combination, Entry[] of [id, content]]
//
function Data(data) {
  var self = this;

  // Attributes.
  //
  var total       = data.total;
  var duration    = data.duration;
  var offset      = data.offset;
  var allocations = new Allocations(data.allocations || []);

  // Expose some attributes.
  //
  this.total       = total;
  this.duration    = duration;
  this.offset      = offset;
  this.allocations = allocations;
};
