## JavaScript


[edit](http://github.com/floere/picky/blob/master/web/source/documentation/_javascript.html.md)

Picky offers a standard HTML interface that works well with its JavaScript. Render this into your HTML (needs the `picky-client` gem):

    Picky::Helper.cached_interface

Adding a JS interface (written in [jQuery](http://jquery.com) for brevity):

    $(document).ready(function() {
      pickyClient = new PickyClient({
        // A full query displays the rendered results.
        //
        full: '/search/full',
        
        // More options...
      
      });
    });

See the options described and listed below.

The variable pickyClient has the following functions:
  
    // Params are params for the controller action. Full is either true or false.
    //
    pickyClient.insert(query, params, full);
    
    // Resends the last query.
    //
    pickyClient.resend;
    
    // If not given a query, will use query from the URL (needs history.js).
    //
    pickyClient.insertFromURL(overrideQuery);

When creating the client itself, you have many more options, as described here:

### Javascript Options

#### Search options

Search options are about configuring the search itself.

There are four different callbacks that you can use. The part after the `||` describes the default, which is an empty function.

The `beforeInsert` is executed before a call to `pickyClient.beforeInsert`. Use this to sanitize queries coming from URLs:

    var beforeInsertCallback = config.beforeInsert || function(query) { };

The `before` is executed before a call to the server. Use this to add any filters you might have from radio buttons or other interface elements:

    var beforeCallback = config.before || function(query, params) { };

The `success` is executed just after a successful response. Use this to modify returned results before Picky renders them:

    var successCallback = config.success || function(data, query) { };

The `after` callback is called just after Picky has finished rendering results – use it to make any changes to the interface (like update an advertisement or similar).

    var afterCallback = config.after || function(data, query) { };

This will cause the interface to search even if the input field is empty:

    var searchOnEmpty = config.searchOnEmpty || false;

If you want to tell the server you need more than 0 live search results, use `liveResults`:

    var liveResults = config.liveResults || 0;

If the live results need to be rendered, set this to be true. Usually used when full results need to be rendered even for live searches (search as you type):

    var liveRendered = config.liveRendered || false;

After each keystroke, Picky waits for a designated interval (default is 180ms) for the next keystroke. If no key is hit, it will send a "live" query to the search server. This option lets you change that interval time:

    var liveSearchTimerInterval = config.liveSearchInterval || 180;

You can completely exchange the backend used to make calls to the server – in this case I trust you to read the JS code of Picky yourself:

    var backends = config.backends;

#### Text options

With these options, you can change the text that is displayed in the interface.

These options can be locale dependent.

Qualifiers are used when you have a category that uses a different qualifier name than the category. That is, if you have a category in the index that is named differently from its qualifiers. Eg. `category :application, qualifiers: ['app']`. You'd then have to tell the Picky interface to map the category correctly to a qualifier.

    qualifiers: {
      en:{
        application: 'app'
      }
    },

Remember that you only need this if you do funky stuff. Keep to the defaults and you'll be fine.

Explanations are the small headings over allocations (grouped results). Picky just writes "with author soandso" – if you want a better explanation, use the explanations option:

    explanations: {
      en:{
        title:     'titled',
        author:    'written by',
        year:      'published in',
        publisher: 'published by',
        subjects:  'with subjects'
      }
    }

Picky would now write "written by soandso", making it much nicer to read.
    
Choices describe the choices that are given to a user when Picky would like to know what the user was searching. This is done when Picky gets too many results in too many allocations, e.g. it is very unclear what the user was looking for.

An example for choices would be:
    
    choices: {
      en:{
        'title': {
          format: "Called <strong>%1$s</strong>",
          filter: function(text) { return text.toUpperCase(); },
          ignoreSingle: true
        },
        'author': 'Written by %1$s',
        'subjects': 'Being about %1$s',
        'publisher': 'Published by %1$s',
        'author,title':    'Called %1$s, written by %2$s',
        'title,author':    'Called %2$s, written by %1$s',
        'title,subjects':  'Called %1$s, about %2$s',
        'author,subjects': '%1$s who wrote about %2$s'
      }
    },
    
Was the user just looking for a title? (Displayed as eg. "ULYSSES – because of the filter and format) or was he looking for an author? (Displayed as "Written by Ulysses")

Multicategory combinations are possible. If the user searches for Ulysses Joyce, then Picky will most likely as if this is a title and an author: "Called Ulysses, written by Joyce".

This is a much nicer way to ask the user, don't you think?

The last option just describes which categories should not show ellipses `…` behind the text (eg. ) if the user searched for it in a partial way. Use this when the categories are not partially findable on the server.

    nonPartial: ['year', 'id']
    
When searching for "1977", this will result in the text being "written in 1977" instead of "written in 1977…", where the ellipses don't make much sense.

The last option describes how to group the choices in a text. Play with this to see the effects (I know, am tired ;) ).

    groups: ['title', 'author'];

#### Modifying the interface itself: Selectors

There are quite a few selector options – you only need those if you heavily customise the interface. You tell Picky where to find the div containing the results or the search form etc.

The selector that contains the search input and the result:

    config['enclosingSelector'] || '.picky';

The selector that describes the form the input field is in:

    var formSelector = config['formSelector'] || (enclosingSelector + ' form');
    
The `formSelector` (short `fs`) is used to find the input etc.:

    config['input']   = $(config['inputSelector']   || (fs + ' input[type=search]'));
    config['reset']   = $(config['resetSelector']   || (fs + ' div.reset'));
    config['button']  = $(config['buttonSelector']  || (fs + ' input[type=button]'));
    config['counter'] = $(config['counterSelector'] || (fs + ' div.status'));

The `enclosingSelector` (short `es`) is used to find the results
  
    config['results']      = $(config['resultsSelector']   || (es + ' div.results'));
    config['noResults']    = $(config['noResultsSelector'] || (es + ' div.no_results'));
    config['moreSelector'] =   config['moreSelector'] ||
      es + ' div.results div.addination:last';

The moreSelector refers to the clickable "more results" pagination/addination.

The result allocations are selected on by these options:

    config['allocations']         = $(config['allocationsSelector'] ||
      (es + ' .allocations'));
    config['shownAllocations']    = config['allocations'].find('.shown');
    config['showMoreAllocations'] = config['allocations'].find('.more');
    config['hiddenAllocations']   = config['allocations'].find('.hidden');
    config['maxSuggestions']      = config['maxSuggestions'] || 3;
      
Results rendering is controlled by:

    config['results']        = $(config['resultsSelector'] ||
      (enclosingSelector + ' div.results'));
    config['resultsDivider'] = config['resultsDivider']    || '';
    config['nonPartial']     = config['nonPartial']        || [];
      // e.g. ['category1', 'category2']
    config['wrapResults']    = config['wrapResults']       || '<ol></ol>';

The option `wrapResults` refers to what the results are wrapped in, by default `<ol></ol>`.