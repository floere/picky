def wrap_in_html interface
  javascripts = []
  javascripts << 'jquery-1.3.2.js'
  javascripts << 'jquery.timer.js'
  javascripts << 'picky.extensions.js'
  javascripts << 'picky.translations.js'
  javascripts << 'picky.data.js'
  javascripts << 'picky.view.js'
  javascripts << 'picky.backend.js'
  javascripts << 'picky.controller.js'
  javascripts << 'picky.client.js'
  javascripts << 'picky.results_renderer.js'
  javascripts << 'picky.allocation_renderer.js'
  javascripts << 'picky.allocations_cloud_renderer.js'
  javascripts = javascripts.map { |js_file| "<script src='javascripts/#{js_file}' type='text/javascript'></script>" }.join
  <<-HTML
<html>
  <head>
    <link type="text/css" rel="stylesheet" media="screen" href="stylesheets/stylesheet.css">
    #{javascripts}
  </head>
  <body>
    <img src="images/picky.png"/>
    <p>
      <a href="http://floere.github.com/picky">Back to the Picky documentation.</a>
    </p>
    #{Picky::Helper.cached_interface}
    <script type='text/javascript'>
      //<![CDATA[
        pickyClient = new PickyClient({
          locale: PickyI18n.locale,
          controller: PickyController,
          backends: {
            live: new LiveBackend('/search/live'),
            full: new FullBackend('/search/full')
          },
          showResultsThreshold: 10,
          showFeedback: true,
          before: function(params, query, offset) {  }, // Before Picky sends any data.
          success: function(data, query) {  }, // Just after Picky receives data. (Get a PickyData object)
          after: function(data, query) {  } // After Picky has handled the data and updated the view.
        });
        pickyClient.insert('enter something here :)');
      //]]>
    </script>
  </body>
</html>
HTML
end