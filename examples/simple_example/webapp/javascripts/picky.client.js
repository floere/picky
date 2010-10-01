var PickyClient = function(config) {
  
  this.config = config;
  
  this.init = function() {
    this.controller     = new config.controller(this);
    this.searchBackends = config.backends;
  };
  
  this.focus = function() {
    this.controller.focus();
  };
  
  this.insert = function(query, people, companies, full, withoutHistory) {
    this.controller.insert(query, people, companies, full, withoutHistory);
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