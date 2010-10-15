// Add PickyResults?
var PickyView = function(picky_controller, config) {
  
  var controller       = picky_controller;
  var allocationsCloud = new PickyAllocationsCloud(this);
  
  var showResultsLimit = config.showResultsLimit || 10;
  
  var searchField   = $('#picky input.query');
  var clearButton   = $('#picky div.reset');
  var searchButton  = $('#picky input.search_button');
  var resultCounter = $('#picky div.status');
  var dashboard     = $('#picky .dashboard');
  
  var results       = $('#picky .results');
  var noResults     = $('#picky .no_results');
  
  var clearResults = function() {
    results.empty();
  };
  var showClearButton = function() {
    clearButton.fadeTo(166, 1.0);
  };
  var hideClearButton = function() {
    clearButton.fadeTo(166, 0.0);
  };
  
  // Cleans the interface of any results or choices presented.
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
  
  var bindEventHandlers = function() {
    searchField.keyup(function(event) {
      if (isTextEmpty()) {
        reset();
        controller.searchTextCleared();
      } else {
        controller.searchTextEntered(text(), event);
        showClearButton();
      }
    });
    
    searchButton.click(function(event) {
      if (!isTextEmpty()) {
        controller.searchButtonClicked(text());
      }
    });
    
    clearButton.click(function() {
      reset('');
      controller.clearButtonClicked();
      focus();
    });
  };
  
  this.allocationChosen = function(event) {
    var text = event.data.query;
    
    searchField.val(text);
    
    controller.allocationChosen(text);
  }
  
  var select = function() {
    searchField.select();
  };
  var text = function() {
    return searchField.val();
  };
  this.text = text; // TODO Remove.
  var isTextEmpty = function() {
    return text() == '';
  };
  
  var focus = function() {
    searchField.focus();
  };
  
  var showTooManyResults = function(data) {
    clean();
    showClearButton();
    allocationsCloud.show(data);
    updateResultCounter(data.total);
  }
  var showEmptyResults = function() {
    clean();
    updateResultCounter(0);
    noResults.show();
    showClearButton();
  };
  var hideEmptyResults = function() {
    noResults.hide();
  };
  var showResults = function(data) {
    clean();
    updateResultCounter(data.total);
    var renderer = new PickyResultsRenderer(controller, data);
    renderer.render();
    results.show();
    showClearButton();
  };
  
  var appendResults = function(data) {
    results.find('.addination').remove();
    var renderer = new PickyResultsRenderer(controller, data);
    renderer.render();
    $.scrollTo('#picky .results div.info:last', { duration: 500, offset: -12 });
  };
  
  var updateResultCounter = function(total) {
    resultCounter.text(total); // ((total > 999) ? '999+' : total); // TODO Decide on this.
    flashResultCounter(total);
  };
  
  var alertThreshold = 5;
  var flashResultCounter = function(total) {
    if (total > 0 && total <= alertThreshold) {
      resultCounter.fadeTo('fast', 0.5).fadeTo('fast', 1);
    }
  };
  
  // TODO Fix or remove.
  //
  var highlight = function(text, klass) {
    var selector = 'span' + (klass ? '.' + klass : '');
    results.find(selector).highlight(text, { element:'em' });
  };
  this.highlight = highlight;
  
  // Insert a search text into the search field.
  // Field is always selected when doing that.
  //
  this.insert = function(text) {
    searchField.val(text);
    select();
  };
  
  
  var tooManyResults = function(data) {
    return data.total > showResultsLimit && data.allocations.length > 1;
  };
  var resultStatusFor = function(data) {
    if (data.isEmpty()) { return 'none'; };
    if (tooManyResults(data)) { return 'support'; }
    return 'ok';
  };
  var setSearchStatus = function(statusClass) {
    dashboard.attr('class', 'dashboard ' + statusClass);
  };
  var setSearchStatusFor = function(data) {
    setSearchStatus(resultStatusFor(data));
  }
  
  var fullResultsCallback = function(data) {
    setSearchStatusFor(data);
    
    if (data.isEmpty()) {
      showEmptyResults();
    } else if (tooManyResults(data)) {
      showTooManyResults(data);
    } else {
      if (data.offset == 0) {
        showResults(data);
      } else {
        appendResults(data);
      }
    };
    
    focus();
  };
  this.fullResultsCallback = fullResultsCallback;
  
  var liveResultsCallback = function(data) {
    setSearchStatusFor(data);
    updateResultCounter(data.total);
  };
  this.liveResultsCallback = liveResultsCallback;
  
  bindEventHandlers();
  focus();
};