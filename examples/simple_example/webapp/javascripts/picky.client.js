var PickyClient = function(config) {
  
  // TODO A bit strange.
  //
  var controller      = config.controller && new config.controller(this, config) || new PickyController(this, config);
  
  // TODO Move to controller?
  var backends        = config.backends;
  if (backends) {
    backends.live || alert('Both a full and live backend must be provided.');
    backends.full || alert('Both a full and live backend must be provided.');
  } else {
    backends = {
      live: config.live && new LiveBackend(config.live) || alert('A live backend path must be provided.'),
      full: config.full && new FullBackend(config.full) || alert('A live backend path must be provided.')
    };
  }
  
  Localization.qualifiers   = config.qualifiers;
  Localization.explanations = config.explanations;
  
  // Insert a query into the client and run it.
  // Default is a full query.
  //
  this.insert = function(query, full) {
    controller.insert(query, full || true);
  };
  
  // Search directly. TODO Remove and only handle through insert?
  //
  // If the given backend cannot be found, ignore the search request.
  //
  this.search = function(type, query, callback, offset, specificParams) {
    // TODO Handle through controller.
    var currentBackend = backends[type];
    if (currentBackend) { currentBackend.search(query, callback, offset, specificParams); };
  };
  
};