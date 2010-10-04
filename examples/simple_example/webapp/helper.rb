def wrap_in_html interface
  javascripts = []
  javascripts << 'jquery-1.3.2'
  javascripts << 'jquery.scrollTo-1.4.2'
  javascripts << 'jquery.timer'
  javascripts << 'picky.extensions'
  javascripts << 'picky.translations'
  javascripts << 'picky.data'
  javascripts << 'picky.view'
  javascripts << 'picky.backend'
  javascripts << 'picky.controller'
  javascripts << 'picky.client'
  javascripts << 'picky.results_renderer'
  javascripts << 'picky.allocation_renderer'
  javascripts << 'picky.allocations_cloud_renderer'
  javascripts = javascripts.map { |js_file| "<script src='javascripts/#{js_file}.js' type='text/javascript'></script>" }.join
  <<-HTML
<html>
  <head>
    <link type="text/css" rel="stylesheet" media="screen" href="stylesheets/stylesheet.css">
    #{javascripts}
  </head>
  <body>
    <img src="images/picky.png"/>
    <p><a href="http://floere.github.com/picky">Back to the Picky documentation.</a></p>
    <p>
      Try a few examples
      <span class="explanation">(on a simple book database with 540 examples)</span>:
    </p>
    <p>
      With qualifier, <a href="#" onclick="pickyClient.insert('title:women');">title:women</a>.
      <span class="explanation">(Finds "women*" in title)<span>
    </p>
    <p>
      With similarity, <a href="#" onclick="pickyClient.insert('woman~');">woman~</a>.
      <span class="explanation">(Finds "women", note: Only title with similarity)</span>
    </p>
    <p>
      With choice, <a href="#" onclick="pickyClient.insert('sp');">sp</a>.
      <span class="explanation">(Finds "sp*" in many categories)</span>
    </p>
    <p>
      More complex, <a href="#" onclick="pickyClient.insert('title:lyterature~ 2002');">title:lyterature~ 2002</a>.
      <span class="explanation">(Finds similar titles from 2002)</span>
    </p>
    #{Picky::Helper.cached_interface}
    <script type='text/javascript'>
      //<![CDATA[
        pickyClient = new PickyClient({
          locale: PickyI18n.locale, // TODO Remove?
          controller: PickyController, // TODO Remove?
          backends: { // TODO Hide implementation, but still allow this here.
            live: new LiveBackend('/search/live'), // 
            full: new FullBackend('/search/full')
          },
          showResultsThreshold: 10, // TODO Rename to showResultsIfLess ?
          showFeedback: true, // TODO What is this?
          before: function(params, query, offset) {  }, // Before Picky sends any data.
          success: function(data, query) {  }, // Just after Picky receives data. (Get a PickyData object)
          after: function(data, query) {  }, // After Picky has handled the data and updated the view.
          // This is used to generate the correct query strings, localized. E.g. "subject:war".
          // If you don't give these, the field identifier given in the Picky server is used.
          qualifiers: {
            en:{
              // title:     'title',
              // author:    'author',
              // isbn:      'isbn',
              // year:      'year',
              // publisher: 'publisher',
              subjects:  'subject'
            }
          },
          // This is used to explain the preceding word in the suggestion text. E.g. "Peter (author)".
          explanations: {
            en:{
              title:     'title',
              author:    'author',
              isbn:      'ISBN-13',
              year:      'published',
              publisher: 'publisher',
              subjects:  'topics'
            }
          }
        });
        pickyClient.insert('italy');
      //]]>
    </script>
  </body>
</html>
HTML
end