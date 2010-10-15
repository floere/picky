var PickyController = function(searchEngine) {
  
  var self = this;
  
  this.searchEngine    = searchEngine;
  this.config          = searchEngine.config;
  
  var showResultsLimit = this.config.showResultsLimit || 10;
  
  this.beforeCallback  = this.config.before; // || ...
  this.successCallback = this.config.success; // || ...
  this.afterCallback   = this.config.after; // || ...
  
  var mustShowAllocationCloud = function(data) {
    return data.total > showResultsLimit && data.allocations.length > 1;
  };
  
  this.init = function() {
    this.view = new PickyView(this);
    
    this.liveSearchTimer = $.timer(180, function(timer) {
      self.liveSearch(self.view.text());
      timer.stop();
    });
    // The timer is initially instantly stopped.
    //
    this.liveSearchTimer.stop();
  };
  
  this.focus = function() {
    self.view.focus();
  };
  this.select = function() {
    self.view.select();
  };
  this.highlight = function(text, klass) {
    this.view.highlight(text, klass);
  };
  
  this.showResults = function(data) {
    this.view.showResults(data);
  };
  this.appendResults = function(data) {
    this.view.appendResults(data);
  };
  this.showEmptyResults = function(data) {
    this.view.setSearchStatus(this.searchStatus(data));
    this.view.showEmptyResults();
  };
  
  this.insert = function(query, full) {
    self.view.insert(query);
    self.select();
    
    self.fullSearch(query);
  };

  this.fullSearch = function(query, offset, params) {
    var params = params || {};
    var offset = offset || 0;
    this.liveSearchTimer.stop();
    
    params = this.beforeCallback(params, query, offset) || params;
    
    this.searchEngine.search('full', query, this.fullSearchCallback, offset, params);
  };
  
  this.fullSearchCallback = function(data, query) {
    data = self.successCallback(data, query) || data;
    
    if (data.total == 0) {
      self.showEmptyResults(data);
    } else if (mustShowAllocationCloud(data)) {
      self.view.showAllocationCloud(data);
      self.view.updateResultCounter(data.total);
    } else {
      if (data.offset == 0) {
        self.showResults(data);
      } else {
        self.appendResults(data);
      }
    };
    self.view.setSearchStatus(self.searchStatus(data));
    
    self.focus();
    
    self.afterCallback(data, query);
  };

  this.liveSearch = function(query, params) {
    var params = params || {};
    
    params = this.beforeCallback(params) || params;
    
    this.searchEngine.search('live', query, this.liveSearchCallback, 0);
  };

  this.liveSearchCallback = function(data, query) {
    data = self.successCallback(data, query) || data;
    
    self.view.updateResultCounter(data.total);
    self.view.setSearchStatus(self.searchStatus(data));
    
    self.afterCallback(data, query);
  };
  
  this.clearButtonClicked = function() {
    this.liveSearchTimer.stop();
    this.focus();
  };
  
  this.searchTextCleared  = function() {
    this.liveSearchTimer.stop();
  };
  this.searchTextEntered   = function(event) {
    if (this.shouldTriggerSearch(event)) {
      if (event.keyCode == 13) { this.fullSearch(this.view.text()); } else { this.liveSearchTimer.reset(); }
    }
  };
  this.searchButtonClicked = function(text) {
    this.fullSearch(text);
  };
  
  this.addinationClickEventHandler = function(event) {
    self.fullSearch(self.view.text(), event.data.offset);
  };
  
  this.shouldTriggerSearch = function(event) {
    var validTriggerKeys = [
                  0,  // special char (ä ö ü etc...)
                  8,  // backspace
                  13, // enter
                  32, // space
                  46, // delete
                  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, // numbers
                  65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90 // a-z
                ];
                
    return $.inArray(event.keyCode, validTriggerKeys) > -1;
  };
  
  this.searchStatus = function(data) {
    if (data.isEmpty()) { return 'none'; };
    if (mustShowAllocationCloud(data)) { return 'support'; }
    return 'ok';
  };
  
  this.init();
};