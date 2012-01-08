var renderer;
describe(
  "AllocationRenderer",
  function() {
    renderer = new AllocationRenderer(function() {
  	  // 
  	}, {});
  },
  function() {
    describe("makeUpMissingFormat", function() {
      it("should be tasty", function() {
        expect(renderer.makeUpMissingFormat('someKey')).toMatch('');
      });
    });
  }
);