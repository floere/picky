var controller;
describe(
  "Mocked controller",
  function() {
	  controller = new PickyController({
	  	
	  });
  },
  function() {
    describe(
      "resend",
		  null,
		  function() {
	      it("delegates", function() {
	        return controller.resend();
	      });
	    }
	  );
    describe(
      "insert",
		  null,
		  function() {
	      it("delegates", function() {
	        return controller.insert();
	      });
	    }
	  );
  }
);