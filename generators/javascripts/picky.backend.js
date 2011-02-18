// Core search backend.
//
var PickyBackend = function(url) {
  
  // Get returns the data without handling timestamps and whatnot.
  //
  var get = function(query, controllerCallback, offset, specificParams) {
    var params = specificParams || {};
    params = $.extend({ query: query, offset: offset }, specificParams);
    
    // Wrap any data returned in a PickyData object.
    //
    var callback = function(data_hash) {
      if (controllerCallback) { controllerCallback(new PickyData(data_hash)); }
    };
    
    $.getJSON(url, params, callback);
  };
  
  var search = function(query, controllerCallback, offset, specificParams, specificTimestamps) {
    // Wrap the given callback.
    //
    var callback = function(data) {
      if (controllerCallback) { controllerCallback(specificTimestamps, data); }
    };
    
    get(query, callback, offset, specificParams);
  };
  this.search = search;
};

// Live search backend.
//
var LiveBackend = function(url, callback) {
  var backend = new PickyBackend(url);
  
  var search = function(query, controllerCallback, offset, specificParams, fullTimestamps) {
    var specificTimestamps = fullTimestamps || {};
    
    latestRequestTimestamp = new Date();
    specificTimestamps.live = latestRequestTimestamp;
    
    // Wrap the given callback.
    //
    // Note: Binds the latest request timestamp for later comparison.
    //
    var callback = function(timestamps, data) {
      if (!timestamps.live || timestamps.live == latestRequestTimestamp) {
        if (controllerCallback) { controllerCallback(data); }
      };
    };
    
    // Pass in the timestamp for later comparison.
    //
    backend.search(query, callback, offset, specificParams, specificTimestamps);
  };
  this.search = search;
};

// Full search backend.
//
var FullBackend = function(url) {
  var backend = new PickyBackend(url);
  
  var search = function(query, controllerCallback, offset, specificParams, givenTimestamps) {
    var specificTimestamps = givenTimestamps || {};
    
    latestRequestTimestamp = new Date();
    specificTimestamps.full = latestRequestTimestamp;
    
    // Wrap the given callback.
    //
    // Note: Binds the latest request timestamp for later comparison.
    //
    var callback = function(timestamps, data) {
      if (!timestamps.full || timestamps.full == latestRequestTimestamp) {
        if (controllerCallback) { controllerCallback(data); }
      };
    };
    
    // Pass in the timestamp for later comparison.
    //
    backend.search(query, callback, offset, specificParams, specificTimestamps);
  };
  this.search = search;
};