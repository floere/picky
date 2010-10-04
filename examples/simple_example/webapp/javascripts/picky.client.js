var PickyClient = function(config) {
  
  this.config = config;
  
  this.init = function() {
    this.controller     = new config.controller(this);
    this.searchBackends = config.backends;
    Localization.qualifiers   = config.qualifiers;
    Localization.explanations = config.explanations;
  };
  
  this.focus = function() {
    this.controller.focus();
  };
  
  this.insert = function(query, full) {
    var full = full || true;
    this.controller.insert(query, full);
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