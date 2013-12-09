var renderer;
describe(
  "AllocationRenderer",
  function() {
    renderer = new AllocationRenderer({
  	  locale: 'en',
      groups: [['invisible']], // Invisible is first, always.
      choices: {
        en:{
          'title': {
            format: "<strong>%1$s</strong>",
            filter: function(text) { return text.toUpperCase(); },
            ignoreSingle: false
          },
          'author': {
            format: "<em>%1$s</em>",
            filter: function(text) { return text.toLowerCase(); },
            ignoreSingle: true
          },
          'invisible': '', // Not visible.
          'title,author': '%2$s, who wrote %1$s',
          'title,invisible': 'only %1$s is visible',
          'invisible,title': 'only %2$s is visible'
        }
      }
  	});
  },
  function() {
    describe("makeUpMissingFormat", null, function() {
      it("is correct", function() {
        return renderer.makeUpMissingFormat(['title']) == '%1$s';
      });
      it("is correct", function() {
        return renderer.makeUpMissingFormat(['author', 'title']) == '%1$s %2$s';
      });
      it("is correct", function() {
        return renderer.makeUpMissingFormat(['author', 'title', 'something']) == '%1$s %2$s %3$s';
      });
    });
    describe("contract", null, function() {
      it("is correct", function() {
        return renderer.contract([
          ['cat1', 'Orig1', 'parsed1']
        ]).compare([
          ['cat1', 'Orig1', 'parsed1']
        ]);
      });
      it("is correct", function() {
        return renderer.contract([
          ['cat2', 'Orig1', 'parsed1'],
          ['cat1', 'Orig2', 'parsed2'],
          ['cat2', 'Orig3', 'parsed3']
        ]).compare([
          ['cat2', ['Orig1', 'Orig3'], ['parsed1', 'parsed3']],
          ['cat1', ['Orig2'], ['parsed2']]
        ]);
      });
      it("is correct", function() {
        return renderer.contract([
          ['cat2', 'Orig1', 'parsed1'],
          ['cat1', 'Orig2', 'parsed2'],
          ['cat2', 'Orig3', 'parsed3'],
          ['cat1', 'Orig4', 'parsed4']
        ]).compare([
          ['cat2', ['Orig1', 'Orig3'], ['parsed1', 'parsed3']],
          ['cat1', ['Orig2', 'Orig4'], ['parsed2', 'parsed4']]
        ]);
      });
    });
    describe("rendered", null, function() {
      it("is correct", function() {
        return renderer.rendered([
          ['cat1', 'Orig1', 'parsed1'],
          ['cat2', 'Orig2', 'parsed2']
        ]) == "parsed1 parsed2";
      });
      it("is correct", function() {
        return renderer.rendered(
          [
            ['cat1', 'Orig1', 'parsed1'],
            ['cat1', 'Orig2', 'parsed2']
          ]
        ) == "parsed1&nbsp;parsed2";
      });
      it("is correct", function() {
        return renderer.rendered([
          ['title', 'Title1', 'title1']
        ]) == "TITLE1&nbsp;(title)";
      });
      it("is correct", function() {
        return renderer.rendered([
          ['title', 'Title1', 'title1'],
          ['title', 'Title2', 'title2']
        ]) == "TITLE1&nbsp;TITLE2&nbsp;(title)";
      });
      it("is correct", function() {
        return renderer.rendered([
          ['author', 'Author1', 'author1']
        ]) == "<em>author1</em>";
      });
      it("is correct", function() {
        return renderer.rendered([
          ['author', 'Author1', 'author1'],
          ['author', 'Author2', 'author2']
        ]) == "<em>author1&nbsp;author2</em>";
      });
      it("is correct", function() {
        return renderer.rendered([
          ['title', 'Title1', 'title1'],
          ['author', 'Author1', 'author1']
        ]) == "author1, who wrote title1";
      });
      it("is correct", function() {
        return renderer.rendered([
          ['title', 'Title1', 'title:title1'],
          ['author', 'Author1', 'author:author1']
        ]) == "author1, who wrote title1";
      });
      it("is correct", function() {
        return renderer.rendered([
          ['invisible', 'Invisible1', 'invisible:invisible1'],
          ['title', 'Title1', 'title:title1']
        ]) == "only title1 is visible";
      });
      it("is correct", function() {
        return renderer.rendered([
          ['invisible', 'Invisible1', 'invisible:invisible1'],
          ['invisible', 'Invisible2', 'invisible:invisible2'],
          ['title', 'Title1', 'title:title1']
        ]) == "only title1 is visible";
      });
      it("is correct", function() {
        return renderer.rendered([
          ['title', 'Title1', 'title:title1'],
          ['invisible', 'Invisible1', 'invisible:invisible1'],
          ['invisible', 'Invisible2', 'invisible:invisible2']
        ]) == "only title1 is visible";
      });
    });
    describe("groupify", null, function() {
      it("is correct", function() {
        return renderer.groupify([
          ['cat1', 'Orig1', 'parsed1']
        ]).compare([
          ['cat1', 'Orig1*', 'parsed1']
        ]);
      });
      it("is correct", function() {
        return renderer.groupify([
          ['cat1', 'Orig1', 'parsed1'],
          ['cat2', 'Orig2', 'parsed2']
        ]).compare([
          [],
		      [
            ['cat1', 'Orig1',  'parsed1'], // Both in the second group.
		        ['cat2', 'Orig2*', 'parsed2']
          ]
		    ]);
      });
      it("is correct", function() {
        return renderer.groupify([
          ['cat1', 'Orig1', 'parsed1'],
          ['cat2', 'Orig2', 'parsed2'],
		      ['cat1', 'Orig3', 'parsed3']
        ]).compare([
          [],
          [
  		      ['cat1', 'Orig1',  'parsed1'], // All in the second group.
  		      ['cat2', 'Orig2',  'parsed2'],
		        ['cat1', 'Orig3*', 'parsed3']
          ]
	      ]);
      });
      it("is correct", function() {
        return renderer.groupify([
          ['cat1', 'Orig1', 'parsed1'],
          ['invisible', 'Invisible2', 'invisible2'],
		      ['cat1', 'Orig2', 'parsed2']
        ]).compare([
          [
            ['invisible', 'Invisible2', 'invisible2']
          ],
          [
  		      ['cat1', 'Orig1',  'parsed1'],
		        ['cat1', 'Orig2*', 'parsed2']
          ]
	      ]);
      });
    });    
    describe("querify", null, function() {
      it("is correct", function() {
        return renderer.querify([
          ['cat1', 'Orig1', 'parsed1']
        ]) == "cat1:parsed1";
      });
      it("is correct", function() {
        return renderer.querify([
          ['cat1', 'Orig1*', 'parsed1']
        ]) == "cat1:parsed1*";
      });
      it("is correct", function() {
        return renderer.querify([
          ['cat1', 'Orig1', 'parsed1'],
          ['cat2', 'Orig2', 'parsed2']
        ]) == "cat1:parsed1 cat2:parsed2";
      });
      it("is correct", function() {
        return renderer.querify([
          ['cat1', 'Orig1*', 'parsed1'],
          ['cat2', 'Orig2', 'parsed2']
        ]) == "cat1:parsed1* cat2:parsed2";
      });
    });
    describe("suggestify", null, function() {
      it("is correct", function() {
        return renderer.suggestify([
          ['cat1', 'Orig1', 'parsed1']
        ]) == "parsed1...";
      });
      it("is correct", function() {
        return renderer.suggestify([
          ['cat1', 'Orig1', 'parsed1'],
          ['cat2', 'Orig2', 'parsed2']
        ]) == "parsed1 parsed2...";
      });
      it("is correct", function() {
        return renderer.suggestify([
          ['cat1', 'Orig1 Orig3', 'parsed1 parsed3'],
          ['cat2', 'Orig2', 'parsed2']
        ]) == "parsed1 parsed3 parsed2...";
      });
      it("is correct", function() {
        return renderer.suggestify([
          ['title', 'Orig1', 'parsed1']
        ]) == "PARSED1...&nbsp;(title)";
      });
      it("is correct", function() {
        return renderer.suggestify([
          ['author', 'Orig1', 'parsed1']
        ]) == "<em>parsed1...</em>";
      });
    });
  }
);