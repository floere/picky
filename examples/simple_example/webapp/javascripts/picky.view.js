// Add PickyResults?
var PickyView = function(controller) {
  
  var self = this;
  var controller = controller;
  // var config = controller.config;

  this.searchField   = $('#picky input.query');
  this.clearButton   = $('#picky div.reset');
  this.searchButton  = $('#picky input.search_button');
  this.resultCounter = $('#picky div.status');
  this.dashboard     = $('#picky .dashboard');
  
  this.results   = $('#picky .results');
  this.noResults = $('#picky .no_results');
  
  this.allocations         = $('#picky .allocations');
  this.shownAllocations    = this.allocations.find('.shown')
  this.showMoreAllocations = this.allocations.find('.more')
  this.hiddenAllocations   = this.allocations.find('.hidden')
  
  this.init = function() {
    this.bindEventHandlers();
    this.focus();
  };
  
  this.bindEventHandlers = function() {
    this.searchField.keyup(function(event) {
      controller.keyUpEventHandler(event);
    });
    
    this.searchButton.click(function(event) {
      controller.searchButtonClickEventHandler(event);
    });
    
    this.clearButton.click(function(event) {
      controller.clearButtonClickEventHandler(event);
    });
    
    this.showMoreAllocations.click(function() {
      self.showMoreAllocations.hide();
      self.hiddenAllocations.show();
    });
  };
  
  this.allocationsCloudClickEventHandler = function(event) {
    // TODO Callback?
    
    this.searchField.val(event.data.query);
    this.hideAllocationCloud();
    
    controller.fullSearch(event.data.query);
  };
  
  this.focus = function() {
    this.searchField.focus();
  };
  
  this.select = function() {
    this.searchField.select();
  };
  
  this.showNoResults = function(person, company) {
    this.reset(false);
    this.updateResultCounter(0);
    
    this.noResults.show();
    this.showClearButton();
  };

  this.hideNoResults = function(person, company) {
    this.noResults.hide();
  };
  
  this.showResults = function(data) {
    this.reset(false);
    this.updateResultCounter(data.total);
    var renderer = new PickyResultsRenderer(controller, data);
    renderer.render();
    this.results.show();
    this.showClearButton();
  };
  
  this.appendResults = function(data) {
    $('#picky .results .addination').remove();
    var renderer = new PickyResultsRenderer(controller, data);
    renderer.render();
    $.scrollTo('#picky .results div.info:last', { duration: 500, offset: -12 });
  };
  
  this.clearResults = function() {
    this.results.empty();
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
    this.shownAllocations.empty();
    this.showMoreAllocations.hide();
    this.hiddenAllocations.empty().hide();
  };
  this.appendShownAllocation = function(item) {
    this.shownAllocations.append(item);
  };
  this.appendHiddenAllocation = function(item) {
    this.hiddenAllocations.append(item);
  };
  
  this.showClearButton = function() {
    this.clearButton.fadeTo(166, 1.0);
  };
  this.hideClearButton = function() {
    this.clearButton.fadeTo(166, 0.0);
  };

  this.selectAll = function() {
    this.searchField.select();
  };

  this.reset = function(clearSearchField) {
    if (clearSearchField) { this.searchField.val(''); }
    this.hideClearButton();
    this.setSearchStatus('empty');
    this.resultCounter.empty();
    this.hideAllocationCloud();
    this.clearResults();
    this.hideNoResults();
  };
  
  this.updateResultCounter = function(total) {
    this.resultCounter.text(total); // ((total > 999) ? '999+' : total); // TODO Decide on this.
    this.flashResultCounter(total);
  };
  
  var alertThreshold = 5;
  this.flashResultCounter = function(total) {
    if (total > 0 && total <= alertThreshold) {
      this.resultCounter.fadeTo('fast', 0.5).fadeTo('fast', 1);
      //TODO: should this be the feedback_area? feedback is/was the feedback-link
      //this.feedback.fadeTo('fast', 0.9).fadeTo('fast', 1);
    }
  };
  
  this.setSearchStatus = function(statusClass) {
    this.dashboard.attr('class', 'dashboard ' + statusClass);
  };
  
  this.highlight = function(text, klass) {
    var selector = 'span' + (klass ? '.' + klass : '');
    this.results.find(selector).highlight(text, { element:'em' });
  };
  
  this.init();
};