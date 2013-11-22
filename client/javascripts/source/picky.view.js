"use strict";

// Add PickyResults?
var PickyView = function(picky_controller, config) {
  
  var controller       = picky_controller;
  
  var showResultsLimit  = config.showResultsLimit  || 10;
  var alwaysShowResults = config.alwaysShowResults || false;
  
  var searchField    = config['input'];
  var clearButton    = config['reset'];
  var searchButton   = config['button'];
  var resultCounter  = config['counter'];
  var form           = config['form'];
  var moreSelector   = config['moreSelector']; // e.g. "#picky div.results div.addination:last"
	
  // Push into results.
  //
  var results        = config['results'];
  var noResults      = config['noResults'];
                     
  var addination = new PickyAddination(this, results); // Push into results.
  
  var allocationsCloud = new PickyAllocationsCloud(this, config);
  var resultsRenderer  = new PickyResultsRenderer(addination, config);
  
  // Toggle the clear button visibility.
  //
  var showClearButton = function() {
    clearButton.fadeTo(166, 1.0);
  };
  var hideClearButton = function() {
    clearButton.fadeTo(166, 0.0);
  };
  
  // TODO Move to results
  var clearResults = function() {
    results.empty();
  };
  var hideEmptyResults = function() {
    noResults.hide();
  };
  
  var focus = function() {
    searchField.focus();
  };
  var select = function() {
    searchField.select();
  };
  
  // Cleans the interface of any results or choices presented.
  //
  var clean = function() {
    allocationsCloud.hide();
    clearResults();
    hideEmptyResults();
  };
  
  // Resets the whole view to the inital state.
  //
  var reset = function(to_text) {
    searchField.val(to_text);
    hideClearButton();
    setSearchStatus('empty');
    resultCounter.empty();
    clean();
  };
  this.reset = reset;
  
  var bindEventHandlers = function() {
    searchField.keyup(function(event) {
      // TODO Move to controller.
      //
      if (isTextEmpty()) {
        reset();
        controller.searchTextCleared();
      } else {
        showClearButton();
      }
      controller.searchTextEntered(text(), event);
    });
    
    resultCounter.click(function(event) {
      controller.searchButtonClicked(text());
    });
    
    searchButton.click(function(event) {
      controller.searchButtonClicked(text());
    });
    
    clearButton.click(function() {
      reset();
      controller.clearButtonClicked();
      focus();
    });
  };
  
  var text = function() {
    return searchField.val();
  };
  this.text = text; // TODO Remove.
  var isTextEmpty = function() {
    return text() == '';
  };
  
  var showEmptyResults = function() {
    clean();
    updateResultCounter(0);
    noResults.show();
    showClearButton();
  };
  var showTooManyResults = function(data) {
    clean();
    showClearButton();
    updateResultCounter(data.total);
    if (alwaysShowResults) {
      resultsRenderer.render(results, data);
      results.show();
    }
    // FIXME data allocation is changed by rendering!
    allocationsCloud.show(data);
  };
  var showResults = function(data) {
    clean();
    showClearButton();
    updateResultCounter(data.total);
    resultsRenderer.render(results, data);
    results.show();
  };
  
  var scrollTo = function(position) {
    $("body").animate({scrollTop: position - 12}, 500);
  };
  
  var appendResults = function(data) {
    var position = $(moreSelector).position().top;
    
    addination.remove(); // TODO Where should this be?
    resultsRenderer.render(results, data);
    
    scrollTo(position);
  };
  
  var updateResultCounter = function(total) {
    // ((total > 999) ? '999+' : total); // TODO Decide on this.
    //
    resultCounter.text(total);
    flashResultCounter(total);
  };
  
  var alertThreshold = 5;
  var flashResultCounter = function(total) {
    if (total > 0 && total <= alertThreshold) {
      resultCounter.fadeTo('fast', 0.5).fadeTo('fast', 1);
    }
  };
  
  // TODO Extract part of this into data.
  //
  var tooManyResults = function(data) {
    return data.total > showResultsLimit && data.allocations.length > 1;
  };
  var resultStatusFor = function(data) {
    if (data.isEmpty()) { return 'none'; };
    if (tooManyResults(data)) { return 'support'; }
    return 'ok';
  };
  var setSearchStatus = function(statusClass) {
    form.attr('class', statusClass);
  };
  var setSearchStatusFor = function(data) {
    setSearchStatus(resultStatusFor(data));
  };
  
  // Insert a search text into the search field.
  // Field is always selected when doing that.
  //
  var insert = function(text) {
    searchField.val(text);
    select();
  };
  this.insert = insert;
  
  // Callbacks.
  // 
  
  // Full results handling.
  //
  var fullResultsCallback = function(data) {
    setSearchStatusFor(data);
    
    if (data.isEmpty()) {
      showEmptyResults();
    } else if (tooManyResults(data)) {
      showTooManyResults(data);
    } else {
      if (data.offset == 0) {
        showResults(data);
        focus();
      } else {
        appendResults(data);
      }
    };
  };
  this.fullResultsCallback = fullResultsCallback;
  
  // Live results handling.
  //
  var liveResultsCallback = function(data) {
    setSearchStatusFor(data);
    
    updateResultCounter(data.total);
  };
  this.liveResultsCallback = liveResultsCallback;
  
  // Callback for when an allocation has been chosen
  // in the allocation cloud.
  //
  var allocationChosen = function(event) {
    var query = event.data.query;
    
    controller.insert(query);
    
    controller.allocationChosen(query);
  };
  this.allocationChosen = allocationChosen;
  
  // Callback for when the addination has been clicked.
  //
  var addinationClicked = function(event) {
    controller.addinationClicked(text(), event);
  };
  this.addinationClicked = addinationClicked;
  
  // 
  //
  bindEventHandlers();
  focus();
};