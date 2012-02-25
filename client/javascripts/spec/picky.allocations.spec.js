var allocations;
describe(
  "Empty allocations",
  function() {
	  allocations = new Allocations([]);
  },
  function() {
    describe(
      "length",
		  null,
		  function() {
	      it("is correct", function() {
	        return allocations.length == 0;
	      });
	    }
	  );
    describe(
      "each",
		  null,
		  function() {
	      it("is correct", function() {
         	var result = true;
			    allocations.each(function() {
			      result = false; // It should not be called.
			    });
          return result;
	      });
	    }
	  );
  }
);
describe(
  "Non-Empty allocations",
  function() {
	  allocations = new Allocations(
      [
        [
          'test',
          3.14,
          123,
          [['attr1', 'Original1', 'parsed1'], ['attr2', 'Original2', 'parsed2']],
          [1,2,3]
        ]
      ]
    );
  },
  function() {
    describe(
      "length",
		  null,
		  function() {
	      it("is correct", function() {
	        return allocations.length == 1;
	      });
	    }
	  );
    //     describe(
    //       "remove",
    //       null,
    //       function() {
    //     it("is correct", function() {
    //       return allocations.remove(0) == [];
    //     });
    //   }
    // );
    describe(
      "each",
		  null,
		  function() {
	      it("is correct", function() {
          var result = false;
	        allocations.each(function() {
	          result = true;
	        });
          return result; // Needs to be called.
	      });
	    }
	  );
  }
);