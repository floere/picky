$(window).load(function() {
  pickyClient = new PickyClient({
    // A full query displays the rendered results.
    //
    full: '/search/full',
    // fullResults: 100, // Optional. Amount of ids to search for, default 20.

    // A live query just updates the count.
    //
    live: '/search/live',
    // liveResults: 0, // Optional. Amount of ids to search for, default 0.

    // showResultsLimit: 100, // Optional. Default is 10.

    // Wrap each li group (like author-title, or title-isbn etc.) of results
    // in this element.
    // Optional. Default is '<ol class="results"></ol>'.
    //
    // wrapResults: '<div class="hello"><ol class="world"></ol></div>',

    // before: function(query, params) {  }, // Optional. Before Picky sends any data. Return modified query.
    // success: function(data, query) {  }, // Optional. Just after Picky receives data. (Get a PickyData object)
    // after: function(data, query) {  }, // Optional. After Picky has handled the data and updated the view.

    // This is used to generate the correct query strings, localized. E.g. "subject:war".
    // Optional. If you don't give these, the field identifier given in the Picky server is used.
    //
    qualifiers: {
      en:{
        subjects:  'subject'
      }
    },

    // Use this to group the choices (those are used when Picky needs more feedback).
    // If a category is missing, it is appended in a virtual group at the end.
    // Optional. Default is [].
    //
    groups: [['author', 'title', 'subjects']],
    // This is used for formatting inside the choice groups.
    //
    // Use %n$s, where n is the position of the category in the key.
    // Optional. Default is {}.
    //
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

    // This is used to explain the preceding word in the suggestion text (if it
    // has not yet been defined by the choices above), localized. E.g. "Peter (author)".
    // Optional. Default are the field identifiers from the Picky server.
    //
    explanations: {
      en:{
        title:     'titled',
        author:    'written by',
        year:      'published in',
        publisher: 'published by',
        subjects:  'with subjects'
      }
    }
  });

  // An initial search text, prefilled
  // this one is passed through the query param q.
  //
  // Example: www.mysearch.com/?q=example
  //
  pickyClient.insertFromURL('#{@query}');
});