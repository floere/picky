var allocation;
describe(
  "Empty allocation",
  function() {
	allocation = new Allocation(
	    'test',
	    3.14,
	    123,
	    [['attr1', 'Original1', 'parsed1'], ['attr2', 'Original2', 'parsed2']],
	    [1,2,3],
	    ['a', 'b', 'c']
	  );
  },
  function() {
    describe(
      "type", null,
		  function() {
	      it("is correct", function() {
	        return allocation.type == 'test';
	      });
	    }
	  );
    describe(
      "weight", null,
		  function() {
	      it("is correct", function() {
	        return allocation.weight == 3.14;
	      });
	    }
	  );
    describe(
      "count", null,
		  function() {
	      it("is correct", function() {
	        return allocation.count == 123;
	      });
	    }
	  );
    describe(
      "ids", null,
		  function() {
	      it("is correct", function() {
	        return allocation.ids[1] == 2;
	      });
	    }
	  );
    describe(
      "rendered", null,
		  function() {
	      it("is correct", function() {
	        return allocation.rendered[1] == 'b';
	      });
	    }
	  );
    describe(
      "isType",
		  null,
		  function() {
	      it("is correct", function() {
	        return allocation.isType('test');
	      });
	    }
	  );
  }
);
