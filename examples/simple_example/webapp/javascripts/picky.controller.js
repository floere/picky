var PickyController = function(searchEngine) {
  
  var self = this;
  
  var searchEngine     = searchEngine;
  var view             = new PickyView(this);
  
  var config           = searchEngine.config;
  var showResultsLimit = config.showResultsLimit || 10;
  var beforeCallback   = config.before; // || ...
  var successCallback  = config.success; // || ...
  var afterCallback    = config.after; // || ...
  
  // TODO Move to view model?
  var mustShowAllocationCloud = function(data) {
    return data.total > showResultsLimit && data.allocations.length > 1;
  };
  // TODO Move to view model?
  var searchStatus = function(data) {
    if (data.isEmpty()) { return 'none'; };
    if (mustShowAllocationCloud(data)) { return 'support'; }
    return 'ok';
  };
  
  var fullSearchCallback = function(data, query) {
    data = successCallback(data, query) || data;
    
    if (data.isEmpty()) {
      view.setSearchStatus(searchStatus(data));
      view.showEmptyResults();
    } else if (mustShowAllocationCloud(data)) {
      view.showAllocationCloud(data);
      view.updateResultCounter(data.total);
    } else {
      if (data.offset == 0) {
        view.showResults(data);
      } else {
        view.appendResults(data);
      }
    };
    
    view.setSearchStatus(searchStatus(data));
    view.focus();
    
    afterCallback(data, query);
  };
  var fullSearch = function(query, offset, params) {
    var params = params || {};
    var offset = offset || 0;
    liveSearchTimer.stop();
    
    params = beforeCallback(params, query, offset) || params;
    
    searchEngine.search('full', query, fullSearchCallback, offset, params);
  };
  
  var liveSearchCallback = function(data, query) {
    data = successCallback(data, query) || data;
    
    view.updateResultCounter(data.total);
    view.setSearchStatus(searchStatus(data));
    
    afterCallback(data, query);
  };
  var liveSearch = function(query, params) {
    var params = params || {};
    
    params = beforeCallback(params) || params;
    
    searchEngine.search('live', query, liveSearchCallback, 0);
  };
  
  // The timer is initially instantly stopped.
  //
  var liveSearchTimer = $.timer(180, function(timer) {
    liveSearch(view.text());
    timer.stop();
  });
  liveSearchTimer.stop();
  
  this.highlight = view.highlight;
  
  this.insert = function(query, full) {
    view.insert(query);
    
    if (full) { fullSearch(query); } // TODO
  };
  
  var clearButtonClicked = function() {
    liveSearchTimer.stop();
  };
  this.clearButtonClicked = clearButtonClicked;
  
  var searchTextCleared  = function() {
    liveSearchTimer.stop();
  };
  this.searchTextCleared = searchTextCleared;
  
  var shouldTriggerSearch = function(event) {
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
  var searchTextEntered = function(text, event) {
    if (shouldTriggerSearch(event)) {
      if (event.keyCode == 13) { fullSearch(text); } else { liveSearchTimer.reset(); }
    }
  };
  this.searchTextEntered = searchTextEntered;
  
  var searchButtonClicked = function(text) {
    fullSearch(text);
  };
  this.searchButtonClicked = searchButtonClicked;
  
  var allocationChosen = function(text) {
    fullSearch(text);
  };
  this.allocationChosen = allocationChosen;
  
  var addinationClickEventHandler = function(event) {
    fullSearch(view.text(), event.data.offset);
  };
  this.addinationClickEventHandler = addinationClickEventHandler;
};