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
    <div id="picky">
      <div class="dashboard empty">
        <div class="feedback">
          <div class="status" title="# results"></div>
          <input type="text" autocorrect="off" class="query"/>
          <div class="reset" title="clear"></div>
        </div>
        <input type="button" class="search_button" value="search">
      </div>
      <ol class="results"></ol>
      <div class="no_results">Sorry!</div>
      <div class="allocations">
        <ol class="shown"></ol>
        <ol class="more">More</ol>
        <ol class="hidden"></ol>
      </div>
    </div>
    <script type='text/javascript'>
      //<![CDATA[
        $(function() {
          pickyClient = new PickyClient({
            controller: PickyController,
            backends: {
              live: new LiveBackend('/search/live'),
              full: new FullBackend('/search/full')
            },
            locale: PickyI18n.locale,
            showResultsThreshold: 10,
            showFeedback: true,
            before: function(params) {  }, // mess with the params before sending. params['hello'] = 'blaaah'; return params
            success: function(data) {  },
            after: function(data) {  },
            keyUp: function(event) {  }
          });
          pickyClient.insert('enter something here :)', false);
        });
      //]]>
    </script>
  </body>
</html>
HTML
end