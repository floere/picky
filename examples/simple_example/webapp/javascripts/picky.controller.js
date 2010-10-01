var PickyController = function(searchEngine) {
  
  var self = this;
  
  this.searchEngine    = searchEngine;
  this.config          = searchEngine.config;
  this.beforeCallback  = this.config.before; // || ...
  this.successCallback = this.config.success; // || ...
  this.afterCallback   = this.config.after; // || ...
  this.keyUpCallback   = this.config.keyUp; // || ...
  
  this.init = function() {
    this.view = new PickyView(this);
    
    this.liveSearchTimer = $.timer(180, function(timer) {
      self.liveSearch(self.view.searchField.val());
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
  
  this.insert = function(query, full) {
    self.view.searchField.val(query);
    self.select();
    
    self.fullSearch(query);
  };

  this.fullSearch = function(query, offset, params) {
    var params = params || {};
    var offset = offset || 0;
    this.liveSearchTimer.stop();
    
    params = this.beforeCallback(params) || params;
    
    this.searchEngine.search('full', query, this.fullSearchCallback, offset, params);
  };
  
  this.fullSearchCallback = function(data, query) {
    data = self.successCallback(data) || data;
    
    if (data.total == 0) {
      self.showNoResults(data);
    } else if (self.mustShowAllocationCloud(data)) {
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
    
    self.afterCallback(data, query, 'full');
  };

  this.liveSearch = function(query, params) {
    var params = params || {};
    
    params = this.beforeCallback(params) || params;
    
    this.searchEngine.search('live', query, this.liveSearchCallback, 0);
  };

  this.liveSearchCallback = function(data, query) {
    data = self.successCallback(data) || data;
    
    self.view.updateResultCounter(data.total);
    self.view.setSearchStatus(self.searchStatus(data));
    
    self.afterCallback(data, query, 'live');
  };
  
  this.keyUpEventHandler = function(event) {
    this.keyUpCallback(event);
    
    if (this.view.searchField.val() == '') {
      this.reset();
    } else {
      if (this.shouldTriggerSearch(event)) {
        if (event.keyCode == 13) { this.fullSearch(this.view.searchField.val()); } else { this.liveSearchTimer.reset(); }
      }
      
      this.view.showClearButton();
    }
  };
  
  this.clearButtonClickEventHandler = function(event) {
    this.reset();
    this.focus();
  };
  
  this.searchButtonClickEventHandler = function(event) {
    if (this.view.searchField.val() != '') {
      this.fullSearch(this.view.searchField.val());
    }
  };
  
  this.allocationsCloudClickEventHandler = function(event) {
    // TODO Callback?
    
    self.view.searchField.val(event.data.query);
    self.view.hideAllocationCloud();
    
    self.fullSearch(event.data.query);
  };
  
  this.addinationClickEventHandler = function(event) {
    self.fullSearch(self.view.searchField.val(), event.data.offset);
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
  
  this.showAllocationCloud = function(data) {
    this.view.showAllocationCloud(data);
  };
  
  this.showResults = function(data) {
    this.view.showResults(data);
  };
  
  this.appendResults = function(data) {
    this.view.appendResults(data);
  };
  
  this.showNoResults = function(data) {
    this.view.setSearchStatus(this.searchStatus(data));
    this.view.showNoResults(this.searchPeople, this.searchCompanies);
  };
  
  this.mustShowAllocationCloud = function(data) {
    return data.total > this.config.showResultsThreshold && data.allocations.length > 1;
  };
  
  this.searchStatus = function(data) {
    if (data.total == 0) { return 'none'; };
    if (this.mustShowAllocationCloud(data)) { return 'support'; }
    return 'ok';
  };
  
  this.highlight = function(text, klass) {
    this.view.highlight(text, klass);
  };
  
  this.reset = function() {
    this.liveSearchTimer.stop();
    this.view.reset(true);
  };
  
  this.init();
};