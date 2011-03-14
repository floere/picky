var PickyController = function(config) {
  
  var view = new PickyView(this, config);
  
  var backends         = config.backends;
  var beforeCallback   = config.before || function(params, query, offset) {  };
  var successCallback  = config.success || function(data, query) {  };
  var afterCallback    = config.after || function(data, query) {  };
  
  // Extracts the query part from an URL.
  //
  var extractQuery = function(url) {
    var match = url && url.match(/q=([^&]+)/);
    return match && match[1];
  };
  this.extractQuery = extractQuery;
  
  // Very failsafe extraction of the last made query.
  //
  var lastQuery = function() {
    var state = window.History && window.History.getState();
    var url = state && state.url;
    return extractQuery(url);
  };
  this.lastQuery = lastQuery;
  
  // If the given backend cannot be found, ignore the search request.
  //
  var search = function(type, query, callback, offset, specificParams) {
    var currentBackend = backends[type];
    if (currentBackend) { currentBackend.search(query, callback, offset, specificParams); };
  };
  
  var liveSearchCallback = function(data, query) {
    data = successCallback(data, query) || data;
    
    view.liveResultsCallback(data);
    
    afterCallback(data, query);
  };
  var liveSearch = function(query, possibleParams) {
    var params = possibleParams || {};
    
    params = beforeCallback(params) || params;
    
    search('live', query, liveSearchCallback, 0);
  };
  
  // The timer is initially instantly stopped.
  //
  var liveSearchTimerInterval = 180;
  var liveSearchTimerId;
  var liveSearchTimerCallback = function() {
    liveSearch(view.text());
    clearInterval(liveSearchTimerId);
  };
  liveSearchTimerId = setInterval(liveSearchTimerCallback, liveSearchTimerInterval);
  clearInterval(liveSearchTimerId);
  
  var fullSearchCallback = function(data, query) {
    data = successCallback(data, query) || data;
    
    view.fullResultsCallback(data);
    
    afterCallback(data, query);
  };
  var fullSearch = function(query, possibleOffset, possibleParams) {
    var params = possibleParams || {};
    var offset = possibleOffset || 0;
    clearInterval(liveSearchTimerId);
    
    // Be extra cautious since not all browsers/histories offer pushState.
    //
    // Note: If this query is the same as the last, we do not save it in the history.
    //
    if (query != lastQuery()) {
      var url = "?q=" + query;
      window.History && window.History.getState() && window.History.pushState && window.History.pushState(null, null, url);
    }
      
    params = beforeCallback(params, query, offset) || params;
    
    search('full', query, fullSearchCallback, offset, params);
  };
  
  this.insert = function(query, full) {
    view.insert(query);
    
    if (full) { fullSearch(query); } // TODO
  };
  
  var clearButtonClicked = function() {
    clearInterval(liveSearchTimerId);
    // liveSearchTimer.stop();
  };
  this.clearButtonClicked = clearButtonClicked;
  
  var searchTextCleared  = function() {
    clearInterval(liveSearchTimerId);
    // liveSearchTimer.stop();
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
      if (event.keyCode == 13) { fullSearch(text); } else { clearInterval(liveSearchTimerId); liveSearchTimerId = setInterval(liveSearchTimerCallback, liveSearchTimerInterval);  /* liveSearchTimer.reset(); */ }
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
  
  // Move to a view object.
  var addinationClicked = function(text, event) {
    fullSearch(text, event.data.offset);
  };
  this.addinationClicked = addinationClicked;
};