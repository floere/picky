// The client handles parameters and
// offers an insert method.
//
var PickyClient = function(config) {
  
  // Params handling.
  //
  
  Localization.qualifiers   = config.qualifiers;
  Localization.explanations = config.explanations;
  
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
  
};