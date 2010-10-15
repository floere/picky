// Add PickyResults?
var PickyView = function(picky_controller) {
  
  var self = this;
  var controller = picky_controller;
  // var config = controller.config;

  var searchField   = $('#picky input.query');
  var clearButton   = $('#picky div.reset');
  var searchButton  = $('#picky input.search_button');
  var resultCounter = $('#picky div.status');
  var dashboard     = $('#picky .dashboard');
  
  var results       = $('#picky .results');
  var noResults     = $('#picky .no_results');
  
  var allocations         = $('#picky .allocations');
  var shownAllocations    = allocations.find('.shown');
  var showMoreAllocations = allocations.find('.more');
  var hiddenAllocations   = allocations.find('.hidden');
  
  var init = function() {
    bindEventHandlers();
    focus();
  };
  
  // Resets the whole view to the inital state.
  //
  var reset = function(to_text) {
    searchField.val(to_text);
    hideClearButton();
    setSearchStatus('empty');
    resultCounter.empty();
    hideAllocationCloud();
    clearResults();
    hideEmptyResults();
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
    
    showMoreAllocations.click(function() {
      showMoreAllocations.hide();
      hiddenAllocations.show();
    });
  };
  
  // TODO Move to Controller.
  this.allocationsCloudClickEventHandler = function(event) {
    // TODO Callback?
    
    var text = event.data.query;
    
    searchField.val(text);
    hideAllocationCloud();
    
    controller.allocationChosen(text);
  };
  
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
  this.focus = focus;
  
  this.showEmptyResults = function() {
    reset();
    updateResultCounter(0);
    
    noResults.show();
    showClearButton();
  };

  var hideEmptyResults = function() {
    noResults.hide();
  };
  
  this.showResults = function(data) {
    reset();
    updateResultCounter(data.total);
    var renderer = new PickyResultsRenderer(controller, data);
    renderer.render();
    results.show();
    showClearButton();
  };
  
  this.appendResults = function(data) {
    results.find('.addination').remove();
    var renderer = new PickyResultsRenderer(controller, data);
    renderer.render();
    $.scrollTo('#picky .results div.info:last', { duration: 500, offset: -12 });
  };
  
  var clearResults = function() {
    results.empty();
  };
  
  this.showAllocationCloud = function(data) {
    reset();
    var renderer = new PickyAllocationsCloudRenderer(this, data);
    renderer.render();
    allocations.show();
    showClearButton();
  };
  var hideAllocationCloud = function() {
    allocations.hide();
  };
  this.clearAllocationCloud = function() {
    shownAllocations.empty();
    showMoreAllocations.hide();
    hiddenAllocations.empty().hide();
  };
  this.appendShownAllocation = function(item) {
    shownAllocations.append(item);
  };
  this.appendHiddenAllocation = function(item) {
    hiddenAllocations.append(item);
  };
  this.showMoreAllocations = function() {
    showMoreAllocations.show();
  };
  
  var showClearButton = function() {
    clearButton.fadeTo(166, 1.0);
  };
  var hideClearButton = function() {
    clearButton.fadeTo(166, 0.0);
  };
  
  var updateResultCounter = function(total) {
    resultCounter.text(total); // ((total > 999) ? '999+' : total); // TODO Decide on this.
    flashResultCounter(total);
  };
  this.updateResultCounter = updateResultCounter;
  
  var alertThreshold = 5;
  var flashResultCounter = function(total) {
    if (total > 0 && total <= alertThreshold) {
      resultCounter.fadeTo('fast', 0.5).fadeTo('fast', 1);
    }
  };
  
  setSearchStatus = function(statusClass) {
    dashboard.attr('class', 'dashboard ' + statusClass);
  };
  this.setSearchStatus = setSearchStatus;
  
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
  
  init();
};