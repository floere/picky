var PickyController = function(config) {
  
  var view = new PickyView(this, config);
  
  var backends             = config.backends;
  var beforeInsertCallback = config.beforeInsert || function(query) { };
  var beforeCallback       = config.before       || function(query, params) { };
  var successCallback      = config.success      || function(data, query) { };
  var afterCallback        = config.after        || function(data, query) { };
  
  var searchOnEmpty           = config.searchOnEmpty      || false;
  var liveRendered            = config.liveRendered       || false;
  var liveSearchTimerInterval = config.liveSearchInterval || 180;
  
  var lastQueryParams;
  
  // Extracts the query part from an URL.
  //
  var extractQuery = function(url) {
    var match = url && url.match(/q=([^&]+)/);
    return match && decodeURIComponent(match[1]).replace(/\+/g, ' ').replace(/#/g, '') || "";
  };
  this.extractQuery = extractQuery;
  
  // Returns the last saved query from
  // the saved params.
  //
  var lastQuery = function() {
    return lastQueryParams && lastQueryParams.length > 1 && lastQueryParams[1];
  }
  
  // Failsafe extraction of the last made query.
  //
  var lastFullQuery = function() {
    var state = window.History && window.History.getState();
    var url = state && state.url;
    return extractQuery(url);
  };
  this.lastFullQuery = lastFullQuery;
  
  // Saves the last query in history.
  //
  var saveInHistory = function(query) {
    // Be extra cautious since not all browsers/histories offer pushState.
    //
    // Note: If this query is the same as the last, we do not save it in the history.
    //
    if (query != lastFullQuery()) { // TODO Not full.
      var url;
      if (query == '') {
        url = '';
      } else {
        url = "?q=" + escape(query).replace(/\*/g,'%2A');
      }
      window.History && window.History.getState() && window.History.pushState && window.History.pushState(null, null, url);
    }
  }
  
  // If the given backend cannot be found, ignore the search request.
  //
  var search = function(type, query, callback, specificParams) {
    var beforeQuery = beforeCallback(query, specificParams);
    // If the before callback returns nothing, 
    // don't use the result.
    //
    if (beforeQuery != undefined) { query = beforeQuery; }
    
    lastQueryParams = [type, query, callback, specificParams];
    saveInHistory(query);
    
    // Only trigger a search if the text is not empty.
    //
    if (!searchOnEmpty && query == '') {
      view.reset();
    } else {
      var currentBackend = backends[type];
      if (currentBackend) { currentBackend.search(query, callback, specificParams); };
    }
  };
  
  // Resend the last query as it was.
  //
  var resend = function() {
    if (lastQueryParams) { search.apply(this, lastQueryParams); }
  };
  this.resend = resend;
  
  var fullSearchCallback = function(data, query) {
    data = successCallback(data, query) || data;
    
    view.fullResultsCallback(data);
    
    afterCallback(data, query);
  };
  var fullSearch = function(query, possibleParams) {
    clearInterval(liveSearchTimerId);
      
    search('full', query, fullSearchCallback, possibleParams || {});
  };
  
  var liveSearchCallback = function(data, query) {
    data = successCallback(data, query) || data;
    
    view.liveResultsCallback(data);
    
    afterCallback(data, query);
  };
  var liveCallbackUsed = liveRendered ? fullSearchCallback : liveSearchCallback;
  var liveSearch = function(query, possibleParams) {
    search('live', query, liveCallbackUsed, possibleParams || {});
  };
  
  // The timer is initially instantly stopped.
  //
  var liveSearchTimerId;
  var liveSearchTimerCallback = function() {
    liveSearch(view.text());
    clearInterval(liveSearchTimerId);
  };
  liveSearchTimerId = setInterval(liveSearchTimerCallback, liveSearchTimerInterval);
  clearInterval(liveSearchTimerId);
  
  // TODO Remove the full parameter?
  //
  var insert = function(query, params, full) {
    var beforeInsertQuery = beforeInsertCallback(query);
    
    // If the beforeInsert callback returns nothing, 
    // don't use the result.
    // Note: Can't use the comfy || since "" is falsy.
    //
    if (beforeInsertQuery != undefined) { query = beforeInsertQuery; }
    
    view.insert(query);
    
    if (full) { fullSearch(query, params); }
  };
  this.insert = insert;
  
  var clearButtonClicked = function() { clearInterval(liveSearchTimerId); };
  this.clearButtonClicked = clearButtonClicked;
  
  var searchTextCleared  = function() { clearInterval(liveSearchTimerId); };
  this.searchTextCleared = searchTextCleared;
  
  var shouldTriggerSearch = function(event) {
  var validTriggerKeys = [
      0,  // special char (ä ö ü etc...)
      8,  // backspace
      13, // enter
      32, // space
      46, // delete
      48, 49, 50, 51, 52, 53, 54, 55, 56, 57, // numbers
      65, 66, 67, 68, 69, 70, 71, 72, 73, 74, // a-z
      75, 76, 77, 78, 79, 80, 81, 82, 83, 84,
      85, 86, 87, 88, 89, 90
    ];
                
    return $.inArray(event.keyCode, validTriggerKeys) > -1;
  };
  var searchTextEntered = function(text, event) {
    if (shouldTriggerSearch(event)) {
      if (event.keyCode == 13) {
        fullSearch(text);
      } else {
        clearInterval(liveSearchTimerId);
        liveSearchTimerId = setInterval(liveSearchTimerCallback, liveSearchTimerInterval);
      }
    }
  };
  this.searchTextEntered = searchTextEntered;
  
  var searchButtonClicked = function(text) { fullSearch(text); };
  this.searchButtonClicked = searchButtonClicked;
  
  var allocationChosen = function(text) { fullSearch(text); };
  this.allocationChosen = allocationChosen;
  
  // Move to a view object.
  var addinationClicked = function(text, event) { fullSearch(text, { offset: event.data.offset }); };
  this.addinationClicked = addinationClicked;
  
  // Bind adapter to let the back/forward button start queries.
  //
  if (window.History) {
    window.History.Adapter.bind(window, 'statechange', function() {
      var state = window.History.getState();
      var query = extractQuery(state.url);
      
      // A back/forward is always a full query.
      //
      if (query != undefined && query != lastQuery()) { insert(query, {}, true); }
    });
  };
  
};