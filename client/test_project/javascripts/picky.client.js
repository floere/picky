"use strict";

var PickyI18n = { };

// The client handles parameters and
// offers an insert method.
//
var PickyClient = function(config) {
  
  // The following part handles all of the parameters.
  // jQuery selectors are executed.
  //
  
  // The locale is by default extracted from the html attribute.
  //
  // TODO Remove.
  //
  PickyI18n.locale = $('html').attr('lang').split('-')[0] || 'en';
  config['locale'] = config['locale'] || PickyI18n.locale;
  
  // This is used to generate the correct query strings, localized.
  //
  // e.g with locale it:
  // ['title', 'ulysses', 'Ulysses'] => 'titolo:ulysses'
  //
  // This needs to correspond to the parsing in the search engine.
  //
  config['qualifiers'] = config.qualifiers || {};
  
  // This is used to explain the preceding word in the suggestion text.
  //
  // e.g. with locale it:
  // ['title', 'ulysses', 'Ulysses'] => 'Ulysses (titolo)'
  //
  config['explanations'] = config.explanations || {};
  
  // This is used to expain more complex combinations of categories
  // in the choices.
  //
  // e.g. with locale en:{'author,title': '%1$s, who wrote %2$s'}
  //
  config['choices'] = config.choices || {};
  
  // Delimiters for connecting explanations.
  //
  config['explanation_delimiters'] = {
	ch:'und',
    de:'und',
    en:'and',
    fr:'et',
    it:'e'
  };
  
  // Either you pass it a backends hash with full and live,
  // or you pass it full and live (urls), which will then
  // be wrapped in appropriate backends. 
  //
  var backends = config.backends;
  if (backends) {
    backends.live || alert('Both a full and live backend must be provided.');
    backends.full || alert('Both a full and live backend must be provided.');
  } else {
    config.backends = {
      live: new LiveBackend(config),
      full: new FullBackend(config)
    };
  }
  
  // Enclosing selector.
  //
  var enclosingSelector = config['enclosingSelector'] || '.picky';
  
  // Form selector.
  //
  var formSelector = config['formSelector'] || (enclosingSelector + ' form');

  // View config.
  //
  config['form']         = $(formSelector);
  
  config['input']        = $(config['inputSelector']     || (formSelector + ' input[type=search]'));
  config['reset']        = $(config['resetSelector']     || (formSelector + ' div.reset'));
  config['button']       = $(config['buttonSelector']    || (formSelector + ' input[type=button]'));
  config['counter']      = $(config['counterSelector']   || (formSelector + ' div.status'));
  
  config['results']      = $(config['resultsSelector']   || (enclosingSelector + ' div.results'));
  config['noResults']    = $(config['noResultsSelector'] || (enclosingSelector + ' div.no_results'));
  config['moreSelector'] =   config['moreSelector']      ||  enclosingSelector + ' div.results div.addination:last';
  
  // Allocations cloud.
  //
  config['allocations']         = $(config['allocationsSelector'] || (enclosingSelector + ' .allocations'));
  config['shownAllocations']    = $(config['shownAllocations'] || config['allocations'].find('.shown'));
  config['showMoreAllocations'] = $(config['showMoreAllocations'] || config['allocations'].find('.more'));
  config['hiddenAllocations']   = $(config['hiddenAllocations'] || config['allocations'].find('.hidden'));
  config['maxSuggestions']      = config['maxSuggestions'] || 3; // How many are shown directly?
  
  // Results rendering.
  //
  config['results']        = $(config['resultsSelector'] || (enclosingSelector + ' div.results'));
  config['resultsDivider'] = config['resultsDivider']    || '';
  config['nonPartial']     = config['nonPartial']        || []; // e.g. ['category1', 'category2']
  config['wrapResults']    = config['wrapResults']       || '<ol></ol>';
  
  // The central Picky controller.
  //
  var controller = config.controller && new config.controller(config) || new PickyController(config);
  
  // Insert a query into the client and run it.
  // Default is a full query.
  //
  this.insert = function(query, params, full) {
    controller.insert(query, params || {}, full || true);
  };
  var insert = this.insert;
  
  // Resends the last query text, full/live.
  //
  // Note: Other variables apart from the text
  // could have changed.
  //
  this.resend = controller.resend;
  
  // Takes a query or nothing as parameter.
  //
  // And runs a query with it (if $.address exists).
  // Can be overridden with a non-empty parameter. 
  //
  this.insertFromURL = function(override) {
    if (override) {
      insert(override);
    } else {
      var lastFullQuery = controller.lastFullQuery();
      lastFullQuery && insert(lastFullQuery);
    }
  };

};