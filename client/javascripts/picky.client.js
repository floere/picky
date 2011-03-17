var Localization = {};

// The client handles parameters and
// offers an insert method.
//
var PickyClient = function(config) {
  
  // Params handling.
  //
  
  // This is used to generate the correct query strings, localized.
  //
  // e.g with locale it:
  // ['title', 'ulysses', 'Ulysses'] => 'titolo:ulysses'
  //
  // This needs to correspond to the parsing in the search engine.
  //
  Localization.qualifiers   = config.qualifiers || {};
  
  // This is used to explain the preceding word in the suggestion text.
  //
  // e.g. with locale it:
  // ['title', 'ulysses', 'Ulysses'] => 'Ulysses (titolo)'
  //
  Localization.explanations = config.explanations || {};
  
  // This is used to expain more complex combinations of categories
  // in the choices.
  //
  // e.g. with locale en:{'author,title': '%1$s, who wrote %2$s'}
  //
  Localization.choices = config.choices || {};
  
  // Delimiters for connecting explanations.
  //
  Localization.explanation_delimiters = { de:'und', fr:'et', it:'e', en:'and', ch:'und' };
  
  // Either you pass it a backends hash with full and live,
  // or you pass it full and live (urls), which will then
  // be wrapped in appropriate backends. 
  //
  var backends = config.backends;
  if (backends) {
    backends.live || alert('Both a full and live backend must be provided.');
    backends.full || alert('Both a full and live backend must be provided.');
  } else {
    config.backends = {
      live: config.live && new LiveBackend(config.live) || alert('A live backend path must be provided.'),
      full: config.full && new FullBackend(config.full) || alert('A live backend path must be provided.')
    };
  }
  
  // The central Picky controller.
  //
  var controller = config.controller && new config.controller(config) || new PickyController(config);
  
  // Insert a query into the client and run it.
  // Default is a full query.
  //
  this.insert = function(query, full) {
    controller.insert(query, full || true);
  };
  var insert = this.insert;
  
  // Takes a query or nothing as parameter.
  //
  // And runs a query with it (if $.address exists).
  // Can be overridden with a non-empty parameter. 
  //
  this.insertFromURL = function(override) {
    if (override && override != '') {
      insert(override);
    } else {
      var lastQuery = controller.lastQuery();
      lastQuery && insert(lastQuery);
    }
  };
  
  // Bind adapter to let the back/forward button start queries.
  //
  if (window.History) {
    window.History.Adapter.bind(window, 'statechange', function() {
      var state = window.History.getState();
      var query = controller.extractQuery(state.url);
      query && insert(query);
    });
  };
};