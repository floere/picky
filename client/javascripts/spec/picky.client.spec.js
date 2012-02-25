// TODO Define $.
//

var client;
describe(
  "Mocked controller",
  function() {
	  client = new PickyClient({
		  controller: {
			  resend: function() { return true; }
			  insert: function() { return true; }
		  } 
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
