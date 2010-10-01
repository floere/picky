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

  // // Sort sorts the allocations according to their weight.
  // // The byWeight function is the sorting function.
  // //
  // var byWeight = function(a1, a2) {
  //   return a2.weight - a1.weight;
  // };
  // this.sort = function() {
  //   self.allocations = self.allocations.sort(byWeight);
  // };
  // this.sort();
};

// Container for the types.
//
// data:
//   offset: X
//   duration: X
//   company: true|false
//   person: true|false
//   total: X
//   allocations:
//     Allocation[] of [weight, count, combination, Entry[] of [id, content]]
//   top: rendered [x,y,z]
//   ad:  rendered w
//
//
// TODO Expose method.
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
  this.offset      = offset;
  this.allocations = allocations;

  this.company  = data.company; // TODO Remove.
  this.person   = data.person;  // TODO Remove.
  this.top      = data.top;
  this.ad       = data.ad;
  this.detailed = data.detailed;
  this.similar  = data.similar;
};
