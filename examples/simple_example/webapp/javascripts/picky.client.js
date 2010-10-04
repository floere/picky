var PickyClient = function(config) {
  
  this.config = config;
  
  this.init = function() {
    var controller      = config.controller;
    this.controller     = controller && new controller(this) || new PickyController(this);
    
    var backends        = config.backends;
    if (backends) {
      backends.live || alert('Both a full and live backend must be provided.');
      backends.full || alert("Both a full and live backend must be provided.");
    } else {
      backends = {
        live: config.live && new LiveBackend(config.live) || alert("A live backend path must be provided."),
        full: config.full && new FullBackend(config.full) || alert("A live backend path must be provided.")
      };
    }
    this.searchBackends = backends;
    
    Localization.qualifiers   = config.qualifiers;
    Localization.explanations = config.explanations;
  };
  
  this.focus = function() {
    this.controller.focus();
  };
  
  this.insert = function(query, full) {
    this.controller.insert(query, full || true);
  };
  
  // If the given backend cannot be found, ignore the search request.
  //
  this.search = function(type, query, callback, offset, specificParams) {
    var currentBackend = this.searchBackends[type];
    if (currentBackend) { currentBackend.search(query, callback, offset, specificParams); };
  };
  
  //
  this.highlight = function(text, klass) {
    this.controller.highlight(text, klass);
  };
  
  this.init();
  
};