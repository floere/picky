// Core search backend.
//
var PickyBackend = function(url) {
  
  return {
    url: url || '/search',
    get: function(timestamp, query, engineCallback, offset, specificParams) {
      var params = specificParams || {};
      params = $.extend({ query: query, offset: offset }, specificParams);
      // wrap the data before returning it
      //
      var wrappedCallback = function(data, query) {
        return engineCallback(new Data(data), query);
      };
      $.ajax({ type: 'GET', url: this.url, data: params, success: this.callback(query, wrappedCallback, timestamp), dataType: 'json'});
    },
    // Override search in subclasses.
    //
    search: function(query, engineCallback, offset, specificParams) {
      get(query, engineCallback, offset, specificParams);
    },
    extend: function(properties) {
      return $.extend({}, this, properties);
    },
    callback: function(query, engineCallback, date) {
      return function(data) {
        engineCallback(data);
      };
    }
  };
};

// Live search backend.
//
var LiveBackend = function(url) {
  return new PickyBackend(url).extend({
    latestRequestTimestamp: new Date(),
    search: function(query, engineCallback, offset, specificParams) {
      latestRequestTimestamp = new Date();
      this.get(latestRequestTimestamp, query, engineCallback, offset, specificParams);
    },
    callback: function(query, engineCallback, date) {
      return function(data) {
        if (date == latestRequestTimestamp) { engineCallback(data, query); }
      };
    }
  });
}

// Full search backend.
//
var FullBackend = function(url) {
  return new LiveBackend(url).extend({
    latestFullRequestTimestamp: new Date(),
    search: function(query, engineCallback, offset, specificParams) {
      var requestTimestamp = new Date();
      latestFullRequestTimestamp = requestTimestamp;
      latestRequestTimestamp = requestTimestamp;
      this.get(requestTimestamp, query, engineCallback, offset, specificParams);
    },
    callback: function(query, engineCallback, date) {
      return function(data) {
        if (date == latestFullRequestTimestamp) { engineCallback(data, query); }
      };
    }
  });
}

// Some specialized backend.
//
// var SpecializedBackend = new FullBackend().extend({
//   url: '/search/specialized'
// });