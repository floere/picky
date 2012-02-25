var data;
describe(
  "Empty non-rendered Data",
  function() {
	  data = new PickyData({
		  total: 0,
		  duration: 0.000123,
		  offset: 12,
		  allocations: []
	  });
  },
  function() {
    describe(
      "isEmpty",
		  null,
		  function() {
	      it("is correct", function() {
	        return data.isEmpty();
	      });
	    }
	  );
    describe(
      "renderedAmount",
		  null,
		  function() {
	      it("is correct", function() {
	        return data.renderedAmount() == 0;
	      });
	    }
	  );
  }
);
describe(
  "Non-Empty non-rendered Data",
  function() {
	  data = new PickyData({
		  total: 123,
		  duration: 0.000123,
		  offset: 12,
		  allocations: [['test', 3.14, 123, [['attr1', 'Original1', 'parsed1'], ['attr2', 'Original2', 'parsed2']], [1,2,3]]]
	  });
  },
  function() {
    describe(
      "isEmpty",
		  null,
		  function() {
	      it("is correct", function() {
	        return !data.isEmpty();
	      });
	    }
	  );
    describe(
      "renderedAmount",
		  null,
		  function() {
	      it("is correct", function() {
	        return data.renderedAmount() == 0;
	      });
	    }
	  );
  }
);
describe(
  "Non-Empty non-rendered Data",
  function() {
	  data = new PickyData({
		  total: 123,
		  duration: 0.000123,
		  offset: 12,
		  allocations: [['test', 3.14, 123, [['attr1', 'Original1', 'parsed1'], ['attr2', 'Original2', 'parsed2']], [1,2,3], ['a', 'b', 'c']]]
	  });
  },
  function() {
    describe(
      "isEmpty",
		  null,
		  function() {
	      it("is correct", function() {
	        return !data.isEmpty();
	      });
	    }
	  );
    describe(
      "renderedAmount",
		  null,
		  function() {
	      it("is correct", function() {
	        return data.renderedAmount() == 3;
	      });
	    }
	  );
  }
);

