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
  
  this.allocations        = $('#picky .allocations');
  var shownAllocations    = this.allocations.find('.shown');
  var showMoreAllocations = this.allocations.find('.more');
  var hiddenAllocations   = this.allocations.find('.hidden');
  
  var init = function() {
    bindEventHandlers();
    focus();
  };
  
  var bindEventHandlers = function() {
    searchField.keyup(function(event) {
      controller.keyUpEventHandler(event);
    });
    
    searchButton.click(controller.searchButtonClickEventHandler);
    
    clearButton.click(function(event) {
      controller.clearButtonClickEventHandler(event);
    });
    
    showMoreAllocations.click(function() {
      showMoreAllocations.hide();
      hiddenAllocations.show();
    });
  };
  
  this.allocationsCloudClickEventHandler = function(event) {
    // TODO Callback?
    
    searchField.val(event.data.query);
    self.hideAllocationCloud();
    
    controller.fullSearch(event.data.query);
  };
  
  this.insert = function(text) {
    searchField.val(text);
  };
  this.text = function() {
    return searchField.val();
  };
  this.isTextEmpty = function() {
    return this.text() == '';
  };
  
  var focus = function() {
    searchField.focus();
  };
  this.focus = focus;
  
  this.select = function() {
    searchField.select();
  };
  
  this.showNoResults = function(person, company) {
    this.reset(false);
    updateResultCounter(0);
    
    noResults.show();
    this.showClearButton();
  };

  var hideNoResults = function(person, company) {
    noResults.hide();
  };
  
  this.showResults = function(data) {
    this.reset(false);
    updateResultCounter(data.total);
    var renderer = new PickyResultsRenderer(controller, data);
    renderer.render();
    results.show();
    this.showClearButton();
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
    this.reset(false);
    var renderer = new PickyAllocationsCloudRenderer(this, data);
    renderer.render();
    this.allocations.show();
    this.showClearButton();
  };
  this.hideAllocationCloud = function() {
    this.allocations.hide();
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
  
  this.showClearButton = function() {
    clearButton.fadeTo(166, 1.0);
  };
  this.hideClearButton = function() {
    clearButton.fadeTo(166, 0.0);
  };

  this.selectAll = function() {
    searchField.select();
  };

  this.reset = function(clearSearchField) {
    if (clearSearchField) { searchField.val(''); }
    this.hideClearButton();
    this.setSearchStatus('empty');
    resultCounter.empty();
    this.hideAllocationCloud();
    clearResults();
    hideNoResults();
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
  
  this.setSearchStatus = function(statusClass) {
    dashboard.attr('class', 'dashboard ' + statusClass);
  };
  
  var highlight = function(text, klass) {
    var selector = 'span' + (klass ? '.' + klass : '');
    results.find(selector).highlight(text, { element:'em' });
  };
  this.highlight = highlight;
  
  init();
};