require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'picky-client'

PickyBackend = Picky::Client::Full.new :host => 'localhost', :port => 4000, :path => '/books/full'

get '/javascripts/:file_name' do
  f = File.open("javascripts/#{params[:file_name]}")
  result = f.read
  f.close
  result
end
get '/stylesheets/:file_name' do
  f = File.open("stylesheets/#{params[:file_name]}")
  result = f.read
  f.close
  result
end

get '/' do
  PickyBackend.search :query => params[:query]
  
  wrap_in_html Picky::Helper.interface
end

get '/search/live' do
  # Return a fake result
  {
    :allocations => [
      ["book",25.22,203,[["title","Old","old"],["title","Man","man"]],[]],
      ["book",22.16,56,[["author","Old","old"],["title","Man","man"]],[]]
    ],
    :offset => 0,
    :total => rand(2000),
    :duration => rand(1)
  }.to_json
end

get '/search/full' do
  # Return a fake result
  {
    :allocations => [
      ["book",25.22,2,[["title","Old","old"],["title","Man","man"]],[],['<div class="item">Content Result a1</div>','<div class="item">Content Result a2</div>']],
      ["book",22.16,1,[["author","Old","old"],["title","Man","man"]],[],['<div class="item">Content Result b1</div>']],
      ["book",13.11,1,[["author","Old","old"],["author","Man","man"]],[],['<div class="item">Content Result c1</div>']],
      ["book",5.23,1,[["author","Man","man"],["author","Old","old"]],[],['<div class="item">Content Result d1</div>']],
    ].sort_by { rand },
    :offset => 0,
    :total => rand(20),
    :duration => rand(1)
  }.to_json
end

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
    <div id="picky">
      <div class="dashboard empty">
        <div class="feedback">
          <div class="status" title="# results" style="opacity: 1;"></div>
          <input type="text" autocorrect="off" class="query">
          <div class="reset" title="clear" style="opacity: 1;"></div>
        </div>
        <input type="button" class="search_button" value="search">
      </div>
      <ol style="display: none;" class="results">
        
      </ol>
      <div style="display: none;" class="no_results">
        Sorry!
      </div>
      <div style="display: none;" class="allocations">
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
        });
      //]]>
    </script>
  </body>
</html>
HTML
end