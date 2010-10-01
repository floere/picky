var PickyView = function(controller) {

  var controller = controller;
  var config = controller.config;

  this.searchField = $('#picky input.query');
  this.clearButton = $('#picky div.reset');
  this.searchButton = $('#picky input.search_button');
  this.resultCounter = $('#picky div.status');
  this.dashboard = $('#picky .dashboard');
  
  this.results = $('#picky .results');
  this.noResults = $('#picky .no_results');
  
  // TODO Remove somehow.
  //
  this.noResultsPerson = $('#picky .no_results .person');
  this.noResultsPersonLink = $('#picky .no_results .person a')
  this.noResultsCompany = $('#picky .no_results .company');
  this.noResultsCompanyLink = $('#picky .no_results .company a');
  this.noResultsNeither = $('#picky .no_results .neither');
  
  this.similar = $('#picky .similar');
  this.allocations = $('#picky .allocations');

  this.init = function() {
    this.bindEventHandlers();
    this.focus();
  };

  this.bindEventHandlers = function() {
    // search
    this.searchField.keyup(function(event) {
      controller.keyUpEventHandler(event);
    });

    // select all
    // this.searchField.focus(function(event) {
    //   controller.focusEventHandler(event);
    // });

    this.searchButton.click(function(event) {
      controller.searchButtonClickEventHandler(event);
    });

    this.clearButton.click(function(event) {
      controller.clearButtonClickEventHandler(event);
    });
    
    this.noResultsPersonLink.click(function(event) {
      controller.noResultsPersonClickEventHandler(event);
    });
    
    this.noResultsCompanyLink.click(function(event) {
      controller.noResultsCompanyClickEventHandler(event);
    });
    
    
    $.each(['person', 'company'], function(i, v) {
      $('#picky .allocations .' + v + ' .more li').click(function() { $(this).parent().hide().next().show();});
    });
  };

  this.focus = function() {
    this.searchField.focus();
  };

  this.select = function() {
    this.searchField.select();
  };

  this.hideTip = function() {
    Tip.hide();
  };

  this.currentSearchTerms = function() {
    return this.searchField.val();
  };

  this.showNoResults = function(person, company) {
    this.reset(false);
    this.updateResultCounter(0);

    if (person && !company) {
      this.noResultsPerson.show();
      this.noResultsCompany.hide();
      this.noResultsNeither.hide();
    }
    else if (!person && company) {
      this.noResultsPerson.hide();
      this.noResultsCompany.show();
      this.noResultsNeither.hide();
    }
    else {
      this.noResultsPerson.hide();
      this.noResultsCompany.hide();
      this.noResultsNeither.show();
    }

    this.noResults.show();
    this.showClearButton();
    this.hideTip();
  };

  this.hideNoResults = function(person, company) {
    this.noResults.hide();
    this.noResultsPerson.hide();
    this.noResultsCompany.hide();
    this.noResultsNeither.hide();
  };

  this.showResults = function(data) {
    this.reset(false);
    searchLayout();
    this.updateResultCounter(data.total);
    var renderer = new PickyResultsRenderer(controller, data);
    renderer.render();
    this.showTopEntries(data.top);
    this.results.show();
    this.showClearButton();
    this.hideTip();
  };

  this.appendResults = function(data) {
    $('#search_results .addination').remove();
    var renderer = new PickyResultsRenderer(controller, data);
    renderer.render();
    $.scrollTo('#search_results div.info:last', { duration: 500, offset: -12 });
  };

  this.clearResults = function() {
    this.results.empty();
    $('#detailed_entries').empty();
    $('#detailed_entries_header').hide();
  };

  this.showTopEntries = function(topEntries) {
    var html = (topEntries.length > 0) ? '<div class="top"><div class="header">' +  t('suggestions.top.header') + '</div>' + topEntries.join('') + '</div>' : '';
    this.results.prepend(html);
  };

  this.showAllocationCloud = function(data) {
    this.reset(false);
    var renderer = new PickyAllocationsCloudRenderer(controller, data);
    renderer.render();
    this.allocations.show();
    this.showClearButton();
    this.hideTip();
  };

  this.hideAllocationCloud = function() {
    this.allocations.hide();
  };

  this.clearAllocationCloud = function() {
    $.each(['person', 'company'], function(i, v) {
      $('#search .allocations .' + v + ' .shown').empty();
      $('#search .allocations .' + v + ' .more').hide();
      $('#search .allocations .' + v + ' .hidden').empty();
    });
  };

  // similar is a hash with person:[similar queries], company:[similar queries]
  //
  this.showSimilar = function(similar) {
    if (similar.person) {
      var suggestions = [];
      $.each(similar.person, function(i, string) {
        suggestions.push('<li onclick="javascript:searchEngine.insert(\'' + string + '\', true, false, true, false);"><a href="#">' + string + '</a></li>');
      });
      $('.suggestions .similar .person ul').html(suggestions.join(''));
      this.similar.find('.person').show();
    } else { this.similar.find('.person').hide(); }
    if (similar.company) {
      var suggestions = [];
      $.each(similar.company, function(i, string) {
        suggestions.push('<li onclick="javascript:searchEngine.insert(\'' + string + '\', false, true, true, false);"><a href="#">' + string + '</a></li>');
      });
      $('.suggestions .similar .company ul').html(suggestions.join(''));
      this.similar.find('.company').show();
    } else { this.similar.find('.company').hide(); }
    this.similar.show();
  };

  // Hides the similarity clouds.
  //
  this.hideSimilar = function() {
    this.similar.hide();
  };

  //
  //
  this.clearSimilar = function() {
    $.each(['person', 'company'], function(i, v) {
      $('#search .similar .' + v + ' ul').empty();
      $('#search .similar .' + v).hide();
    });
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
    if(clearSearchField) this.searchField.val('');
    this.hideClearButton();
    this.setSearchStatus('empty');
    this.resultCounter.empty();
    this.hideAllocationCloud();
    this.hideSimilar();
    this.clearResults();
    this.hideNoResults();
  };

  this.updateResultCounter = function(total) {
    this.resultCounter.text((total > 999) ? '999+' : total);
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

  this.renderDetailedEntry = function(data) {
    this.results.hide();
    this.providerHint.hide();
    if ($('#search_results .list_container:first').size() > 0) $('#detailed_entries_header').show();
    this.detailedEntries.show();
    this.detailedEntries.html(data.detailed);
  };

  this.init();
};