var Localization = {};
var PickyI18n = { };

// Set the correct locale for all js code.
//
$(function() {
  PickyI18n.locale = $('html').attr('lang').split('-')[0] || 'en';
});

// The client handles parameters and
// offers an insert method.
//
var PickyClient = function(config) {
  
  // The following part handles all of the parameters.
  // jQuery selectors are executed.
  //
  
  // This is used to generate the correct query strings, localized.
  //
  // e.g with locale it:
  // ['title', 'ulysses', 'Ulysses'] => 'titolo:ulysses'
  //
  // This needs to correspond to the parsing in the search engine.
  //
  Localization.qualifiers   = config.qualifiers || {};
  
  // This is used to explain the preceding word in the suggestion text.
  //
  // e.g. with locale it:
  // ['title', 'ulysses', 'Ulysses'] => 'Ulysses (titolo)'
  //
  Localization.explanations = config.explanations || {};
  
  // This is used to expain more complex combinations of categories
  // in the choices.
  //
  // e.g. with locale en:{'author,title': '%1$s, who wrote %2$s'}
  //
  Localization.choices = config.choices || {};
  
  // Delimiters for connecting explanations.
  //
  Localization.explanation_delimiters = { de:'und', fr:'et', it:'e', en:'and', ch:'und' };
  
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
  var enclosingSelector = config['enclosingSelector'] || '#picky';
  
  // View config.
  //
  config['input']        = $(config['inputSelector']     || (enclosingSelector + ' input.query'));
  config['reset']        = $(config['resetSelector']     || (enclosingSelector + ' div.reset'));
  config['button']       = $(config['buttonSelector']    || (enclosingSelector + ' input.search_button'));
  config['counter']      = $(config['counterSelector']   || (enclosingSelector + ' div.status'));
  config['dashboard']    = $(config['dashboardSelector'] || (enclosingSelector + ' .dashboard'));
  config['results']      = $(config['resultsSelector']   || (enclosingSelector + ' div.results'));
  config['noResults']    = $(config['noResultsSelector'] || (enclosingSelector + ' .no_results'));
  config['moreSelector'] =   config['moreSelector']      ||  enclosingSelector + ' div.results div.addination:last';
  
  // Allocations cloud.
  //
  config['allocations']         = $(config['allocationsSelector'] || (enclosingSelector + ' .allocations'));
  config['shownAllocations']    = config['allocations'].find('.shown');
  config['showMoreAllocations'] = config['allocations'].find('.more');
  config['hiddenAllocations']   = config['allocations'].find('.hidden');
  
  // Results rendering.
  //
  config['results']     = $(config['resultsSelector'] || (enclosingSelector + ' div.results'));
  config['noAsterisks'] = config['noAsterisks'] || []; // e.g. ['category1', 'category2']
  config['wrapResults'] = config['wrapResults'] || '<ol class="results"></ol>';
  
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
  
  // Takes a query or nothing as parameter.
  //
  // And runs a query with it (if $.address exists).
  // Can be overridden with a non-empty parameter. 
  //
  this.insertFromURL = function(override) {
    if (override && override != '') {
      insert(override);
    } else {
      resend();
    }
  };
  
  // Resends the last query text.
  //
  // Note: Other variables apart from the text
  // could have changed.
  //
  this.resend = function() {
    var lastQuery = controller.lastQuery();
    lastQuery && insert(lastQuery);
  };
  
  // Bind adapter to let the back/forward button start queries.
  //
  if (window.History) {
    window.History.Adapter.bind(window, 'statechange', function() {
      var state = window.History.getState();
      var query = controller.extractQuery(state.url);
      query && insert(query);
    });
  };
};