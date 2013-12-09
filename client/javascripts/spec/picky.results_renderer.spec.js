var renderer;
describe(
  "Mocked controller",
  function() {
    var append = "";
    var results = {
      append: function(string) {
        append += string;
      },
      str: function() {
        return append;
      }  
    }
    
	  renderer = new PickyResultsRenderer(
		  {
		    render: function() { return "the_addination"; }
		  },
		  {
			  locale: 'en',
        nonPartial: ['nonPartialCategory'],
        results: results,
        explanations: {
          en: {
            cat1: 'done by',
            cat3: 'with m/z'
          }
        },
        explanationDelimiters: {
          en: 'annnd'
        }
		  }
	  );
  },
  function() {
    describe("asteriskifyLastToken", null,
		  function() {
	      it("is correct", function() {
	        return renderer.asteriskifyLastToken([]).compare([]);
	      });
	      it("is correct", function() {
	        return renderer.asteriskifyLastToken([['nonPartialCategory', 'Orig1', 'parsed1']]).compare([['nonPartialCategory', 'Orig1', 'parsed1']]);
	      });
	      it("is correct", function() {
	        return renderer.asteriskifyLastToken([['cat1', 'Orig1', 'parsed1']]).compare([['cat1', 'Orig1*', 'parsed1']]);
	      });
	      it("is correct", function() {
	        return renderer.asteriskifyLastToken([
            ['cat1', 'Orig1', 'parsed1'],
            ['cat2', 'Orig2', 'parsed2']
          ]).compare([
            ['cat1', 'Orig1', 'parsed1'],
            ['cat2', 'Orig2*', 'parsed2']
          ]);
	      });
	    }
	  );
    describe("explainCategory", null,
		  function() {
	      it("is correct", function() {
	        return renderer.explainCategory([
            ['cat1', 'Orig1', 'parsed1']
          ]).compare([
            ['done by', 'Orig1']
          ]);
	      });
	      it("is correct", function() {
	        return renderer.explainCategory([
            ['cat2', 'Orig1', 'parsed1']
          ]).compare([
            ['cat2', 'Orig1']
          ]);
	      });
	    }
	  );
    describe("strongify", null,
		  function() {
	      it("is correct", function() {
	        return renderer.strongify("cat1", 'joinedTokens') == "<strong>cat1</strong> joinedTokens";
	      });
	      it("is correct", function() {
	        return renderer.strongify("cät1", 'joinedTokens') == "<strong>cät1</strong> joinedTokens";
	      });
	      it("is correct", function() {
	        return renderer.strongify("cat1,cat2", 'joinedTokens') == "<strong>cat1,cat2</strong> joinedTokens";
	      });
	    }
	  );
    describe("explain", null,
		  function() {
	      it("is correct", function() {
	        return renderer.explain("type1", [
            ['cat1', 'Orig1', 'parsed1']
          ]) == '<span class="explanation">type1 <strong>done by</strong> Orig1*</span>';
	      });
	      it("is correct", function() {
	        return renderer.explain("type3", [
            ['cat3', 'Orig3', 'parsed3']
          ]) == '<span class="explanation">type3 <strong>with m/z</strong> Orig3*</span>';
	      });
	      it("is correct", function() {
	        return renderer.explain("type1", [
            ['cat1', 'Orig1', 'parsed1'],
            ['cat2', 'Orig2', 'parsed2']
          ]) == '<span class="explanation">type1 <strong>done by</strong> Orig1 annnd <strong>cat2</strong> Orig2*</span>';
	      });
	      it("is correct", function() {
	        return renderer.explain("type1", [
            ['cat1', 'cat1:Orig1', 'parsed1'],
            ['cat2', 'cat2:Orig2', 'parsed2']
          ]) == '<span class="explanation">type1 <strong>done by</strong> Orig1 annnd <strong>cat2</strong> Orig2*</span>';
	      });
	      it("is correct", function() {
	        return renderer.explain("type1", [
            ['cat1', 'cat1:Orig1', 'parsed1'],
            ['cat2', 'cat2,cat3:Orig2', 'parsed2']
          ]) == '<span class="explanation">type1 <strong>done by</strong> Orig1 annnd <strong>cat2</strong> Orig2*</span>';
	      });
	    }
	  );
    describe("renderHeader", null,
		  function() {
	      it("is correct", function() {
	        return renderer.renderHeader(
            { offset: 0 },
            { 
              type: 'type1',
              combination: [['cat1', 'Orig1', 'parsed1']]
            }
          ) == '<div class="header"><span class="explanation">type1 <strong>done by</strong> Orig1*</span></div>';
	      });
	      it("is correct", function() {
	        return renderer.renderHeader(
            { offset: 0 },
            { 
              type: 'type1',
              combination: [
                ['cat1', 'Orig1', 'parsed1'],
                ['cat2', 'Orig2', 'parsed2']
              ]
            }
          ) == '<div class="header"><span class="explanation">type1 <strong>done by</strong> Orig1 annnd <strong>cat2</strong> Orig2*</span></div>';
	      });
	    }
	  );
    // describe("render", null,
    //   function() {
    //     it("is correct", function() {
    //       return renderer.render(
    //         new PickyData({
    //           offset: 0,
    //           allocations: [
    //             ['type1', 3.14, 123, [['cat1', 'Orig1', 'parsed1']]]
    //           ]
    //         })) == '<div class="header"><span class="explanation">type1 <strong>done by</strong> Orig1*</span></div>';
    //     });
    //   }
    // );
  }
);
