var array;
describe(
  "Array",
  function() {
	  array = [1,2,3,4,5];
  },
  function() {
    describe(
      "index",
		  null,
		  function() {
	      it("indexes correctly", function() {
	        return array.index(0) == null;
	      });
        it("indexes correctly", function() {
	        return array.index(3) == 2;
	      });
	    }
	  );
    describe(
      "include",
		  null,
		  function() {
	      it("is correct", function() {
	        return !array.include(0);
	      });
        it("is correct", function() {
	        return array.include(3);
	      });
	    }
	  );
    describe(
      "compare",
		  null,
		  function() {
	      it("is correct", function() {
	        return [].compare([]);
	      });
        it("is correct", function() {
          return [1,2,3].compare([1,2,3]);
	      });
	    }
	  );
    describe(
      "include",
		  null,
		  function() {
	      it("is correct", function() {
	        return array.remove(0).compare([2,3,4,5]);
	      });
        it("is correct", function() {
          return array.remove(3).compare([2,3,4]);
	      });
	    }
	  );
  }
);
