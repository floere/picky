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
  
  var bindEventHandlers = function() {
    searchField.keyup(function(event) {
      if (isTextEmpty()) {
        controller.searchTextCleared();
      } else {
        controller.searchTextEntered(event);
        showClearButton();
      }
    });
    
    searchButton.click(function(event) {
      if (!isTextEmpty()) {
        controller.searchButtonClicked(text());
      }
    });
    
    clearButton.click(function(event) {
      controller.clearButtonClickEventHandler(event);
    });
    
    showMoreAllocations.click(function() {
      showMoreAllocations.hide();
      hiddenAllocations.show();
    });
  };
  
  // TODO Move to Controller.
  this.allocationsCloudClickEventHandler = function(event) {
    // TODO Callback?
    
    searchField.val(event.data.query);
    hideAllocationCloud();
    
    controller.fullSearch(event.data.query);
  };
  
  this.insert = function(text) {
    searchField.val(text);
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
  
  this.select = function() {
    searchField.select();
  };
  
  this.showEmptyResults = function(person, company) {
    reset();
    updateResultCounter(0);
    
    noResults.show();
    showClearButton();
  };

  var hideNoResults = function(person, company) {
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
  
  var highlight = function(text, klass) {
    var selector = 'span' + (klass ? '.' + klass : '');
    results.find(selector).highlight(text, { element:'em' });
  };
  this.highlight = highlight;
  
  // Resets the whole view to the inital state.
  //
  reset = function(clearSearchField) {
    if (clearSearchField) { searchField.val(''); }
    hideClearButton();
    setSearchStatus('empty');
    resultCounter.empty();
    hideAllocationCloud();
    clearResults();
    hideNoResults();
  };
  this.reset = function() { reset(true); }; // External calls always reset also the text.
  
  init();
};